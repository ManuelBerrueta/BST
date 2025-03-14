#!/bin/bash

# Function to display usage message
display_usage() {
    echo "Usage: $0 [-s <subscriptionId>] [--activate <roleName>]"
    echo "Check and optionally activate Azure PIM roles using the Azure CLI."
    echo ""
    echo "Arguments:"
    echo "  -s, --subscription     (Optional) The ID of the Azure subscription to use."
    echo "  --activate             (Optional) The name of the role to activate."
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--subscription)
            subscriptionId="$2"
            shift 2
            ;;
        --activate)
            roleNameToActivate="$2"
            echo "WIP"
            shift 2
            ;;
        *)
            echo "Invalid argument: $1"
            display_usage
            exit 1
            ;;
    esac
done

# List PIM roles assigned to the user
echo "Listing PIM roles assigned to the user..."
if [ -n "$subscriptionId" ]; then
    assignedRoles=$(az role assignment list --subscription "$subscriptionId" --query "[?principalType=='User' && principalName=='$(az ad signed-in-user show --query userPrincipalName -o tsv)']" -o table)
else
    assignedRoles=$(az role assignment list --query "[?principalType=='User' && principalName=='$(az ad signed-in-user show --query userPrincipalName -o tsv)']" -o table)
fi

if [ $? -ne 0 ]; then
    echo "Failed to list PIM roles."
    exit 1
fi

echo "$assignedRoles"
