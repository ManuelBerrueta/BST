# Function to display usage message
display_usage() {
    echo "Usage: $0 -g <resourceGroup> -k <keyVaultName> -p <principalId> -r <roleName> [-s <subscriptionId>]"
    echo "Assign a role to an Azure Key Vault using the Azure CLI."
    echo ""
    echo "Arguments:"
    echo "  -g, --resource-group   The name of the resource group."
    echo "  -k, --key-vault        The name of the Azure Key Vault."
    echo "  -p, --principal        The principal ID to assign the role to."
    echo "  -r, --role             The role name to assign."
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
        -p|--principal)
            principalId="$2"
            shift 2
            ;;
        -r|--role)
            roleName="$2"
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
if [[ -z $resourceGroup || -z $keyVaultName || -z $principalId || -z $roleName ]]; then
    echo "Missing required arguments"
    display_usage
    exit 1
fi

# Set the active Azure subscription if provided
if [ -n "$subscriptionId" ]; then
    if ! az account set --subscription "$subscriptionId"; then
        echo "Failed to set the active Azure subscription."
        exit 1
    fi
fi

# Assign role to Key Vault and check for errors
if ! assignment_output=$(az role assignment create \
    --role "$roleName" \
    --assignee "$principalId" \
    --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resourceGroup/providers/Microsoft.KeyVault/vaults/$keyVaultName" \
    --output json); then
    echo "Failed to assign role to Key Vault"
    echo "$assignment_output"
    exit 1
fi

echo "Role assigned successfully"