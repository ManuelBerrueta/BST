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

bearer_token = 'Bearer ' + ''.join(token)

vm_url = "https://management.azure.com/subscriptions/" + subscriptionId + "/resourceGroups/" + resourceGroupName + "/providers/Microsoft.Compute/virtualMachines?api-version=2021-07-01"
payload={}
headers = {
  'Authorization': bearer_token
}
vm_response = requests.request("GET", vm_url, headers=headers, data=payload).json()

#pretty_json = json.loads(vm_response.text)
#print(json.dumps(pretty_json, indent=3, sort_keys=True))

# VM Private IP Enum
#vm_priv_ips = "https://management.azure.com/subscriptions/" + subscriptionId + "/resourceGroups/" + resourceGroupName + "/providers/Microsoft.Network/privateIPAddresses?api-version=2021-03-01"
# GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkInterfaces?api-version=2021-03-01
vm_priv_ips = "https://management.azure.com/subscriptions/" + subscriptionId + "/resourceGroups/" + resourceGroupName + "/providers/Microsoft.Network/networkInterfaces?api-version=2021-03-01"
vm_response_priv_ips = requests.request("GET", vm_priv_ips, headers=headers, data=payload)

pretty_json_priv_ips = json.loads(vm_response_priv_ips.text)
print("][ Private IP Addresses ][")
print(json.dumps(pretty_json_priv_ips, indent=3, sort_keys=True))
print("][ Private IP Addresses Filtered: ][")

print(pretty_json_priv_ips)

priv_ip_list = []
for machine in pretty_json_priv_ips['value']:
    machine_priv_ip = machine['properties']['ipConfigurations'][0]['properties']['privateIPAddress']
    priv_ip_list.append(machine_priv_ip)
    print(machine_priv_ip)

with open("VMPrivateIPs.txt", "w") as outfile:
    for eachIP in priv_ip_list:
        outfile.write("%s\n" % eachIP)
    outfile.close()


#GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/publicIPAddresses?api-version=2021-03-01

#vm_public_ips = "https://management.azure.com/subscriptions/" + subscriptionId + "/resourceGroups/" + resourceGroupName + "/providers/Microsoft.Network/publicIPAddresses?api-version=2021-03-01"
#vm_response_public_ips = requests.request("GET", vm_public_ips, headers=headers, data=payload)
#
#pretty_json_public_ips = json.loads(vm_response_public_ips.text)
#print("][ Public IP Addresses ][")
#print(json.dumps(pretty_json_public_ips, indent=3, sort_keys=True))


# Sample YAML CONFIG:
#azure:
#   subscription: xxx-xxx-x-xx-xxx
#   resource_group : myRG
#   token: ey........
#   vms:
#   - "myFavoriteVM"