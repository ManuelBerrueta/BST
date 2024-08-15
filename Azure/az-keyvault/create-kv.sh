# Function to display usage message
display_usage() {
    echo "Usage: $0 <key_vault_name> <resource_group_name> <location> [subscription_id]"
    echo "Create an Azure Key Vault using the Azure CLI."
    echo ""
    echo "Arguments:"
    echo "  <key_vault_name>       The name of the Azure Key Vault to create."
    echo "  <resource_group_name>  The name of the resource group to create the Azure Key Vault in."
    echo "  <location>             The Azure region where the Azure Key Vault should be created."
    echo "  [subscription_id]      (Optional) The ID of the Azure subscription to use."
}

# Check if at least the required arguments are provided
if [ $# -lt 3 ] || [ $# -gt 4 ]; then
    display_usage
    exit 1
fi

# Check if the user is logged in
if ! az account show &> /dev/null; then
    echo "Please log in to your Azure account using 'az login' command."
    exit 1
fi

# Assign command line arguments to variables
key_vault_name=$1
resource_group_name=$2
location=$3
subscription_id=${4:-}

# Set the active Azure subscription if provided
if [ -n "$subscription_id" ]; then
    if ! az account set --subscription $subscription_id; then
        echo "Failed to set the active Azure subscription."
        # List Azure subscriptions
        if ! az account list --output table; then
            echo "Failed to list Azure subscriptions."
            exit 1
        fi
        exit 1
    fi
fi


# Create Azure Key Vault
if ! az keyvault create --name $key_vault_name --resource-group $resource_group_name --location $location; then
    echo "Failed to create Azure Key Vault."
    exit 1
fi
