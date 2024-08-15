# Function to display help message
display_help() {
    echo "Usage: $0 -n <name> -l <location> [-s <subscription>]"
    echo "Create an Azure resource group."
    echo ""
    echo "Options:"
    echo "  -n, --name        The name of the resource group."
    echo "  -l, --location    The location of the resource group."
    echo "  -s, --subscription    The subscription ID or name. (optional)"
    echo "  -h, --help        Display this help message."
    echo ""
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -n|--name)
            name="$2"
            shift
            shift
            ;;
        -l|--location)
            location="$2"
            shift
            shift
            ;;
        -s|--subscription)
            subscription="$2"
            shift
            shift
            ;;
        -h|--help)
            display_help
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            display_help
            exit 1
            ;;
    esac
done

# Check if required parameters are provided
if [[ -z $name || -z $location ]]; then
    echo "Error: Missing required parameters."
    display_help
    exit 1
fi

# Create the resource group
if [[ -z $subscription ]]; then
    az group create --name "$name" --location "$location"
else
    az group create --name "$name" --location "$location" --subscription "$subscription"
fi