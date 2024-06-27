#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for jq
if ! command_exists jq; then
    echo "Error: jq is not installed. Please install jq to run this script."
    exit 1
fi

# Check for pygmentize
PYGMENTIZE_INSTALLED=true
if ! command_exists pygmentize; then
    echo "Warning: pygmentize is not installed. Output will not be syntax highlighted."
    PYGMENTIZE_INSTALLED=false
fi

# Check if JWT is provided
if [ -z "$1" ]; then
    echo "Error: No JWT provided. Usage: $0 <your_jwt_here>"
    exit 1
fi

# The JWT token you want to decode
JWT=$1

# Extract the parts of the JWT
HEADER=$(echo $JWT | cut -d "." -f 1)
PAYLOAD=$(echo $JWT | cut -d "." -f 2)
SIGNATURE=$(echo $JWT | cut -d "." -f 3)

# Function to decode base64 URL-safe string
base64_url_decode() {
    local input=$1
    local len=$((${#input} % 4))
    if [ $len -eq 2 ]; then input="$input"'=='
    elif [ $len -eq 3 ]; then input="$input"'='
    fi
    echo "$input" | base64 --decode 2>/dev/null
}

# Decode and print the header
echo "Header:"
HEADER_JSON=$(base64_url_decode $HEADER | jq .)
if [ "$PYGMENTIZE_INSTALLED" = true ]; then
    echo "$HEADER_JSON" | pygmentize -l json
else
    echo "$HEADER_JSON"
fi

# Decode and print the payload
echo "Payload:"
PAYLOAD_JSON=$(base64_url_decode $PAYLOAD | jq .)
if [ "$PYGMENTIZE_INSTALLED" = true ]; then
    echo "$PAYLOAD_JSON" | pygmentize -l json
else
    echo "$PAYLOAD_JSON"
fi

# Print the signature (not decoded, as it's binary data)
echo "Signature:"
echo $SIGNATURE
