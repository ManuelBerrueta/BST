#!/bin/bash

# Default values
DEFAULT_KEY_VAULT_NAME="bst-secret-utils-akv"
DEFAULT_RG_NAME="bst-secret-utils"
DEFAULT_LOCATION="westus"

# Function to display usage information
function show_usage() {
    echo "Usage: scopy.sh [options]"
    echo "Options:"
    echo "  -c, --copy <secret>          Copy the specified secret to the default key vault"
    echo "  -p, --paste <secret-name>    Retrieve and display the specified secret from the default key vault"
    echo "  -k, --key-vault <name>       Use the specified key vault instead of the default"
    echo "  -r, --resource-group <name>  Specify the resource group to use"
    echo "  -o, --location <location>    Specify the location for the key vault"
    echo "  -l, --list                   List all secrets in the default key vault"
    echo "  -a, --listkv                 List all key vaults the user has access to"

    echo "  -h, --help                   Show this help message"
}

# Function to handle the copy operation
function copy_secret() {
    local secret="$1"
    local key_vault="$2"

    # Check if a secret was passed in
    if [[ -z "$secret" ]]; then
        echo "\e[1;31mNo secret to copy provided\e[0m"
        exit 1
    fi

    # Check if resource group was passed in
    if [[ -n "$resource_group" ]]; then
        DEFAULT_RG_NAME="$resource_group"
    fi

    # Check if location was passed in
    if [[ -n "$location" ]]; then
        DEFAULT_LOCATION="$location"
    fi

    # Check if the key vault exists
    if az keyvault show --name "$key_vault" &>/dev/null; then
        echo "Using existing key vault: $key_vault"
    else
        # Check if the resource group exists
        if ! az group show --name "${DEFAULT_RG_NAME}" &>/dev/null; then
            echo -e "\e[1;31mResource group '${DEFAULT_RG_NAME}' does not exist\e[0m"
            echo "Creating resource group: ${DEFAULT_RG_NAME}"
            if ! az group create --name "${DEFAULT_RG_NAME}" --location "${DEFAULT_LOCATION}"; then
            echo -e "\e[1;31mFailed to create the resource group: ${DEFAULT_RG_NAME}\e[0m"
            exit 1
            fi
        fi

        echo "Creating key vault: $key_vault"
        if ! az keyvault create --name "$key_vault" --resource-group "${DEFAULT_RG_NAME}" --location "${DEFAULT_LOCATION}" --enabled-for-template-deployment true; then
            echo -e "\e[1;31mFailed to create the key vault: $key_vault\e[0m"
            exit 1
        fi
    fi

    # Generate a unique secret name if not provided
    if [[ -z "$secret_name" ]]; then
        secret_name=$(az keyvault secret list --vault-name "$key_vault" --query "[?starts_with(id, 'https://$key_vault.vault.azure.net/secrets/')].id" --output tsv | awk -F'/' '{print $NF}' | grep -E '^[0-9]+$' | sort -rn | head -n 1)
        if [[ -z "$secret_name" ]]; then
            secret_name="0"
        else
            secret_name=$((secret_name + 1))
        fi
    fi

    # Check if the secret name already exists
    if az keyvault secret show --vault-name "$key_vault" --name "$secret_name" &>/dev/null; then
        echo "Secret with name '$secret_name' already exists in key vault '$key_vault'"
        exit 1
    fi

    # Copy the secret to the key vault
    if az keyvault secret set --vault-name "$key_vault" --name "$secret_name" --value "$secret"; then
        echo -e "\e[1;32mSecret copied successfully\e[0m"
        exit 1
    else
        echo -e "\e[1;31mFailed to copy the secret to key vault '$key_vault'\e[0m"
        exit 1
    fi
}

# Function to handle the paste operation
function paste_secret() {
    local secret_name="$1"
    local key_vault="$2"

    # Use the default key vault if not provided
    if [[ -z "$key_vault" ]]; then
        key_vault="$DEFAULT_KEY_VAULT_NAME"
    fi

    # Check if the key vault exists
    if ! az keyvault show --name "$key_vault" &>/dev/null; then
        echo "\e[1;31mKey vault '$key_vault' does not exist\e[0m"
        exit 1
    fi

    # Retrieve and display the secret
    secret=$(az keyvault secret show --vault-name "$key_vault" --name "$secret_name" --query "value" --output tsv 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "Secret with name '$secret_name' does not exist in key vault '$key_vault'"
        echo ""
        list_secrets "$key_vault"

        exit 1
    fi
    # Copy the secret to the clipboard
    echo -n "$secret" | xclip -selection clipboard
    echo -e "\e[33mSecret copied to clipboard\e[0m"
    echo "\e[1;32mSecret:\e[0m"
    echo -e "\e[36m$secret\e[0m"
}

# Function to list all secrets in the default key vault
function list_secrets() {
    local key_vault="$1"

    echo -e "\e[1;32m[*] Secret list:\e[0m"

    # Use the default key vault if not provided
    if [[ -z "$key_vault" ]]; then
        key_vault="$DEFAULT_KEY_VAULT_NAME"
    fi

    # Check if the key vault exists
    if ! az keyvault show --name "$key_vault" &>/dev/null; then
        echo -e "\e[31m |---> Key vault '$key_vault' does not exist\e[0m"
        exit 1
    fi

    # List all secrets in the key vault
    az keyvault secret list --vault-name "$key_vault" --query "[].id" --output tsv
}

# Function to list all key vaults the user has access to
function list_key_vaults() {
    echo -e "\e[1;32m[*] Key Vault list:\e[0m"
    key_vaults=$(az keyvault list --query "[].name" --output tsv)
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to list key vaults"
        exit 1
    fi
    if [[ -z "$key_vaults" ]]; then
        echo -e "\e[33m |---> No Key Vaults Found\e[0m"
    else
        echo "$key_vaults"
    fi

    exit 1
}

# Function to set the tenant and subscription ID
function set_tenant_id() {
    local tenant_id="$1"
    # Check if tenant ID was passed in
    if [[ -n "$tenant_id" ]]; then
        az account set --tenant "$tenant_id"
    fi
}

function set_sub_id() {
    local subscription_id="$1"
    # Check if subscription ID was passed in
    if [[ -n "$subscription_id" ]]; then
        az account set --subscription "$subscription_id"
    fi
}




# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--copy)
            copy_secret "$2" "$DEFAULT_KEY_VAULT_NAME"
            shift 2
            ;;
        -p|--paste)
            paste_secret "$2" "$DEFAULT_KEY_VAULT_NAME"
            shift 2
            ;;
        -k|--key-vault)
            DEFAULT_KEY_VAULT_NAME="$2"
            shift 2
            ;;
        -t|--tenant)
            TENANT_ID="$2"
            set_tenant_id "$TENANT_ID"
            shift 2
            ;;
        -s|--subscription)
            SUBSCRIPTION_ID="$2"
            set_sub_id "$SUBSCRIPTION_ID"
            shift 2
            ;;
        -l|--list)
            list_secrets "$DEFAULT_KEY_VAULT_NAME"
            shift
            ;;
        -a|--listkv)
            list_key_vaults
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Show usage if no arguments provided
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

# Note: some of this is untested :/