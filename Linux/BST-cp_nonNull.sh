#!/bin/bash

counter=0
fileName=$1

Usage()
{
  cat << EOF
  Error: $1

  Use: $0 <Target_File_To_Copy>

EOF
    exit 1
}

if [ "$#" -ne 1 ]; then
    Usage "Requires path of target file to copy passed in as a parameter"
fi

while [ $counter -lt 5 ]
do
    if [ ! -f $fileName ]; then
        echo "$fileName not found | Count: $counter"
    elif [ ! -s $fileName ]; then
        echo "$fileName exist but size 0 | Count: $counter"
    else
        echo "$fileName exists | Count: $counter"
        cp $fileName ./${fileName}_${counter} -v
        echo "Copied $fileName as $fileName_$counter"
        (( counter++ ))
        sleep 3
    fi
done
