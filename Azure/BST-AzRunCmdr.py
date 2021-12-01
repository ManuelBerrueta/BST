#!/usr/bin/env python3
import requests
import json
import yaml
import argparse

parser = argparse.ArgumentParser()

parser.add_argument('--config', type=str, required=False, default='./Azure/config.yaml', help='--config <AzureConfig.yaml')
parser.add_argument('--token', type=str, required=False, default='', help='--config <AzureConfig.yaml')
args = parser.parse_args()

with open(args.config, "r") as infile:
    azure_config = yaml.safe_load(infile)

subscriptionId = azure_config["azure"]["subscription"]
resourceGroupName = azure_config["azure"]["resource_group"]
vms = azure_config["azure"]["vms"]
token = azure_config["azure"]["token"]

for vm_name in vms:
  run_cmd_url = "https://management.azure.com/subscriptions/" + subscriptionId + "/resourceGroups/" + resourceGroupName + "/providers/Microsoft.Compute/virtualMachines/" + vm_name + "/runCommand?api-version=2021-07-01"

bearer_token = 'Bearer ' + ''.join(token)

payload = json.dumps({
  "commandId": "RunShellScript",
  "script": [
    "ls $arg1 $arg2"
  ],
  "parameters": [
    {
      "name": "arg1",
      "value": "-lh"
    },
    {
      "name": "arg2",
      "value": "~"
    }
  ]
})
headers = {
  'Authorization': bearer_token
}
response = requests.request("POST", run_cmd_url, headers=headers, data=payload)

print(response.json())
