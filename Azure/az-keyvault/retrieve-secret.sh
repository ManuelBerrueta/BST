
# Function to display usage message
display_usage() {
    echo "Usage: $0 -g <resourceGroup> -k <keyVaultName> -n <secretName> [-s <subscriptionId>]"
    echo "Retrieve a secret from an Azure Key Vault using the Azure CLI."
    echo ""
    echo "Arguments:"
    echo "  -g, --resource-group   The name of the resource group."
    echo "  -k, --key-vault        The name of the Azure Key Vault."
    echo "  -n, --name             The name of the secret."
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
        *)
            echo "Invalid argument: $1"
            display_usage
            exit 1
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z $resourceGroup || -z $keyVaultName || -z $secretName ]]; then
    echo "Missing required arguments"
    display_usage
    exit 1
fi

# Retrieve the secret from the specified Key Vault
if [[ -z $subscriptionId ]]; then
    secretValue=$(az keyvault secret show --vault-name "$keyVaultName" --name "$secretName" --query "value" -o tsv)
else
    secretValue=$(az keyvault secret show --vault-name "$keyVaultName" --name "$secretName" --query "value" -o tsv --subscription "$subscriptionId")
fi

if [ $? -ne 0 ]; then
    echo "Failed to retrieve the secret from the Key Vault."
    exit 1
fi

echo "Secret Value: $secretValue"