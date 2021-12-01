#!/bin/bash

#* Example: az vm run-command invoke -g myResourceGroup -n myVm --command-id RunShellScript --scripts "apt-get update && apt-get install -y nginx"
echo "BST-AzCli Run Cmdr"
SUBSCRIPTION=$1
RESOURCE_GROUP=$2
SCRIPT_CMD_TO_RUN=$3
VM_LIST_FILE=$4
for VM in $(cat $VM_LIST_FILE) ; do
    echo $VM
    az vm run-command invoke --subscription $SUBSCRIPTION --resource-grou $RESOURCE_GROUP -n $VM --command-id RunShellScript --scripts $SCRIPT_CMD_TO_RUN
done

#az vm run-command invoke -s $SUBSCRIPTION -g $RESOURCE_GROUP -n $VM --command-id RunShellScript --scripts $SCRIPT-CMD_TO_RUN