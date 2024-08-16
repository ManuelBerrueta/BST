
# Function to display usage message
display_usage() {
    echo "Usage: $0 -g <resourceGroup> -k <keyVaultName> -n <secretName> -v <secretValue> [-s <subscriptionId>]"
    echo "Create a secret in an Azure Key Vault using the Azure CLI."
    echo ""
    echo "Arguments:"
    echo "  -g, --resource-group   The name of the resource group."
    echo "  -k, --key-vault        The name of the Azure Key Vault."
    echo "  -n, --name             The name of the secret."
    echo "  -v, --value            The value of the secret."
    echo "  -s, --subscription     (Optional) The ID of the Azure subscription to use."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--subscription)
            subscriptionId="$2"
            shift 2
            ;;
        -g|--resource-group)
            resourceGroup="$2"
            shift 2
            ;;
        -k|--key-vault)
            keyVaultName="$2"
            shift 2
            ;;
        -n|--name)
            secretName="$2"
            shift 2
            ;;
        -v|--value)
            secretValue="$2"
            shift 2
            ;;
        *)
            echo "Invalid argument: $1"
            display_usage
            exit 1
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z $resourceGroup || -z $keyVaultName || -z $secretName || -z $secretValue ]]; then
    echo "Missing required arguments"
    display_usage
    exit 1
fi

# Create the secret in the specified Key Vault
if ! az keyvault secret set --vault-name "$keyVaultName" --name "$secretName" --value "$secretValue" --subscription "$subscriptionId"; then
    echo "Failed to create the secret in the Key Vault."
    exit 1
fi

echo "Secret created successfully"