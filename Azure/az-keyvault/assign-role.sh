
# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
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
            exit 1
            ;;
    esac
done

# Check if required arguments are provided
if [[ -z $resourceGroup || -z $keyVaultName || -z $principalId || -z $roleName ]]; then
    echo "Missing required arguments"
    exit 1
fi

# Assign role to Key Vault
# Assign role to Key Vault and check for errors
if ! assignment_output=$(az role assignment create \
    --role "$roleName" \
    --assignee "$principalId" \
    --scope "/subscriptions/${subscriptionId:-}/resourceGroups/$resourceGroup/providers/Microsoft.KeyVault/vaults/$keyVaultName" \
    --output json); then
    echo "Failed to assign role to Key Vault"
    echo "$assignment_output"
    exit 1
fi