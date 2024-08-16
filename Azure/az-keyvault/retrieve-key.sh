
# Function to display usage message
display_usage() {
    echo "Usage: $0 -g <resourceGroup> -k <keyVaultName> -n <keyName> [-s <subscriptionId>]"
    echo "Retrieve a key from an Azure Key Vault using the Azure CLI."
    echo ""
    echo "Arguments:"
    echo "  -g, --resource-group   The name of the resource group."
    echo "  -k, --key-vault        The name of the Azure Key Vault."
    echo "  -n, --name             The name of the key."
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
            keyName="$2"
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
if [[ -z $resourceGroup || -z $keyVaultName || -z $keyName ]]; then
    echo "Missing required arguments"
    display_usage
    exit 1
fi

# Retrieve the key from the specified Key Vault
if [[ -z $subscriptionId ]]; then
    keyValue=$(az keyvault key show --vault-name "$keyVaultName" --name "$keyName" --query "key.kid" -o tsv)
else
    keyValue=$(az keyvault key show --vault-name "$keyVaultName" --name "$keyName" --query "key.kid" -o tsv --subscription "$subscriptionId")
fi

if [ $? -ne 0 ]; then
    echo "Failed to retrieve the key from the Key Vault."
    exit 1
fi

echo "Key Value: $keyValue"