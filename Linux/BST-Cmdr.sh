#!/bin/bash -e

SCRIPT_NAME=$1
VM_LIST=$2

for vm in $(cat $VM_LIST)
do
    # Run a command:
    #ssh -t ${USER}@${vm} sudo -- "sh -c 'uname -a'"
    
    SCRIPT=$(cat $SCRIPT_NAME)
    #TODO: Check distro
    #!Works on Red Hat:
    ssh -t ${USER}@${vm} $SCRIPT
done