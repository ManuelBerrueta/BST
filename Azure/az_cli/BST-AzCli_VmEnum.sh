#!/bin/bash

SUBSCRIPTION=$1
RESOURCE_GROUP=$2

#az vm list --subscription $SUBSCRIPTION --resource-group $RESOURCE_GROUP
#az vm list-ip-addresses --subscription $SUBSCRIPTION --resource-group $RESOURCE_GROUP --query "[].virtualMachine" -o table
#az vm list-ip-addresses --subscription $SUBSCRIPTION  --resource-group $RESOURCE_GROUP -o table
#az vm list-ip-addresses --query "[].virtualMachine.[name,network.privateIpAddresses,resourceGroup]" -o table
az vm list-ip-addresses --subscription $SUBSCRIPTION --resource-group $RESOURCE_GROUP -o table --query "[].virtualMachine.[network.privateIpAddresses]"