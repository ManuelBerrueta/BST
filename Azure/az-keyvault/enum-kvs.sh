#!/bin/bash

# Function to display usage message
display_usage() {
    echo "Usage: $0 [-s <subscriptionId>] [-g <resourceGroup>] [--list-secrets]"
    echo "Enumerate Key Vaults and their details using the Azure CLI."
    echo ""
    echo "Arguments:"
    echo "  -s, --subscription     (Optional) The ID of the Azure subscription to use."
    echo "  -g, --resource-group   (Optional) The name of the resource group."
    echo "  --list-secrets         (Optional) List secrets in each Key Vault."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--subscription)
            subscription_id="$2"
            shift 2
            ;;
        -g|--resource-group)
            resource_group="$2"
            shift 2
            ;;
        --list-secrets)
            list_secrets=true
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            display_usage
            exit 1
            ;;
    esac
done

# Check if subscription ID is provided, if not use the current context subscription
if [ -z "$subscription_id" ]; then
    subscription_id=$(az account show --query id -o tsv)
fi

# Get the list of resource groups
if [ -z "$resource_group" ]; then
    resource_groups=$(az group list --subscription "$subscription_id" --query '[].name' -o tsv)
else
    resource_groups=$resource_group
fi

# Iterate over each resource group
while IFS=$'\t' read -r rg; do
    # List key vaults in the resource group
    key_vaults=$(az keyvault list --subscription "$subscription_id" --resource-group "$rg" --query '[].{Name:name, ResourceGroup:resourceGroup}' -o tsv)

    # Iterate over each key vault
    while IFS=$'\t' read -r name resource_group; do
        echo "Key Vault: $name"
        echo "Resource Group: $resource_group"

        # Check if secrets flag is provided, and list secrets if true
        if [[ $list_secrets == true ]]; then
            secrets=$(az keyvault secret list --vault-name "$name" --subscription "$subscription_id" --query '[].{Name:attributes.name}' -o tsv)
            echo "Secrets:"
            echo "$secrets"

            # List certificates in the key vault
            certificates=$(az keyvault certificate list --vault-name "$name" --subscription "$subscription_id" --query '[].{Name:attributes.name}' -o tsv)
            echo "Certificates:"
            echo "$certificates"

            # List keys in the key vault
            keys=$(az keyvault key list --vault-name "$name" --subscription "$subscription_id" --query '[].{Name:attributes.name}' -o tsv)
            echo "Keys:"
            echo "$keys"
        fi

        # Get access policies for the key vault
        access_policies=$(az keyvault show --name "$name" --resource-group "$resource_group" --subscription "$subscription_id" --query 'properties.accessPolicies[].{ObjectId:objectId, TenantId:tenantId, Permissions:permissions.keys[]}' -o json)
        echo "Access Policies:"
        echo "$access_policies"

        # Get role assignments for the key vault
        role_assignments=$(az role assignment list --scope "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.KeyVault/vaults/$name" --query '[].{PrincipalName:principalName, RoleDefinitionName:roleDefinitionName}' -o json)
        echo "Role Assignments for this SPN:"
        echo "$role_assignments"

        # Get all role assignments for the key vault
        all_role_assignments=$(az role assignment list --scope "/subscriptions/$subscription_id/resourceGroups/$resource_group/providers/Microsoft.KeyVault/vaults/$name" -o json)
        echo "All Role Assignments:"
        echo "$all_role_assignments"

        echo "----------------------------------------"

    done <<< "$key_vaults"
done <<< "$resource_groups"