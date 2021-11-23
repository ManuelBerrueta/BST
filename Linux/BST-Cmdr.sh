#!/bin/bash -e

script_name=$1
vm_list=$2

for vm in $(cat $vm_list)
do
    # Run a command:
    #ssh -t ${USER}@${vm} sudo -- "sh -c 'uname -a'"
    # Run a script:
    
    script=$(cat $script_name)
    ssh -t ${USER}@${vm} sudo -- $script
done