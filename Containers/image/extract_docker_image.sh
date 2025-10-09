#!/bin/bash

# Script to extract Docker image tarball filesystem
# Usage: ./extract_docker_image.sh <path-to-tarball>
# Example: ./extract_docker_image.sh docker_images/official_image/remote-support.tar

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

# Check if argument is provided
if [ $# -eq 0 ]; then
    print_error "No tarball path provided"
    echo "Usage: $0 <path-to-tarball>"
    echo "Example: $0 docker_images/official_image/remote-support.tar"
    exit 1
fi

TARBALL_PATH="$1"

# Check if tarball exists
if [ ! -f "$TARBALL_PATH" ]; then
    print_error "Tarball not found: $TARBALL_PATH"
    exit 1
fi

# Check if Docker is installed
print_info "Checking Docker availability..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    echo ""
    echo "To install Docker:"
    echo "  - On Ubuntu/Debian: sudo apt update && sudo apt install docker.io"
    echo "  - On WSL2: Enable Docker Desktop WSL integration"
    echo "  - See: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker daemon is running and accessible
print_info "Checking Docker daemon status..."
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running or not accessible"
    echo ""
    echo "Possible solutions:"
    echo "  - Start Docker Desktop (if using Docker Desktop)"
    echo "  - Start Docker service: sudo systemctl start docker"
    echo "  - Add user to docker group: sudo usermod -aG docker \$USER"
    echo "  - In WSL2: Enable Docker Desktop WSL integration"
    echo "  - Check Docker status: sudo systemctl status docker"
    exit 1
fi

print_success "Docker is available and running"

# Get the directory containing the tarball
TARBALL_DIR=$(dirname "$TARBALL_PATH")
EXTRACTION_DIR="${TARBALL_DIR}/extracted_fs"

print_info "Tarball: $TARBALL_PATH"
print_info "Extraction directory: $EXTRACTION_DIR"

# Create extraction directory
print_info "Creating extraction directory..."
mkdir -p "$EXTRACTION_DIR"

# Load the Docker image
print_info "Loading Docker image from tarball..."
IMAGE_OUTPUT=$(docker load -i "$TARBALL_PATH")
echo "$IMAGE_OUTPUT"

# Extract the image name/ID from the output
# Output format is typically: "Loaded image: <image_name:tag>" or "Loaded image ID: sha256:..."
if [[ "$IMAGE_OUTPUT" =~ "Loaded image: "(.+) ]]; then
    IMAGE_NAME="${BASH_REMATCH[1]}"
    print_info "Image loaded: $IMAGE_NAME"
elif [[ "$IMAGE_OUTPUT" =~ "Loaded image ID: sha256:"([a-f0-9]+) ]]; then
    IMAGE_NAME="sha256:${BASH_REMATCH[1]}"
    print_info "Image ID loaded: $IMAGE_NAME"
else
    # Fallback: get the most recently created image
    IMAGE_NAME=$(docker images --format "{{.Repository}}:{{.Tag}}" | head -1)
    print_info "Using most recent image: $IMAGE_NAME"
fi

# Create a temporary container and export filesystem
print_info "Creating temporary container and extracting filesystem..."
CONTAINER_ID=$(docker create "$IMAGE_NAME")
print_info "Temporary container created: $CONTAINER_ID"

print_info "Exporting filesystem to $EXTRACTION_DIR..."
docker export "$CONTAINER_ID" | tar -x -C "$EXTRACTION_DIR"

# Clean up temporary container
print_info "Cleaning up temporary container..."
docker rm "$CONTAINER_ID" > /dev/null

print_success "Filesystem extraction complete!"
print_info "Extracted to: $EXTRACTION_DIR"

# Show summary of extracted files
FILE_COUNT=$(find "$EXTRACTION_DIR" -type f | wc -l)
DIR_COUNT=$(find "$EXTRACTION_DIR" -type d | wc -l)
print_info "Extracted: $FILE_COUNT files, $DIR_COUNT directories"
