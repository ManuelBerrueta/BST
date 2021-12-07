#!/usr/bin/env python3
import argparse

#! WIP - CLI Shell of program

parser = argparse.ArgumentParser(prog='BST Azure Python',
                                 usage='%(prog)s [options to be]',
                                 description='Interact with Azure')
parser.add_argument('Command1', metavar='command1',
                    type=str, help='Provide first command')
parser.add_argument('Command2', metavar='command2',
                    type=str, help='Provide second command')

args = parser.parse_args()

comm1 = args.Command1
comm2 = args.Command2

print('comm1=%s comm2=%s' % (comm1, comm2))


# Packages required
#   azure-mgmt-resource>=18.0.0
#   azure-identity>=1.5.0
# https://stackoverflow.com/questions/51546073/how-to-run-azure-cli-commands-using-python
# https://docs.microsoft.com/en-us/azure/developer/python/configure-local-development-environment?tabs=cmd
# https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-example-list-resource-groups\
# https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-authenticate
