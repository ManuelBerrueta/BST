#!/bin/bash -e

FILE_TO_TRANSFER=$1
VM_LIST=$2

for vm in $(cat $VM_LIST)
do
    scp $FILE_TO_TRANSFER ${USER}@${vm}:/home/${USER}/
done