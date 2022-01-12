#!/usr/bin/env python3
import requests
import json
import yaml
import argparse
import subprocess
import csv
from azure.identity import AzureCliCredential

#! You can create a Config YAML file following this schema:
# azure:
#   subscription: xxx-xxx-x-xx-xxx
#   resource_group : myRG
#   token: ey........
#   vms:
#   - "myFavoriteVM"

parser = argparse.ArgumentParser()

parser.add_argument(
    "--config",
    type=str,
    required=False,
    default="",
    help="--config <AzureConfig.yaml",
)
parser.add_argument(
    "--token", type=str, required=False, default="", help="--token eyJ..."
)
parser.add_argument(
    "--auth", required=False, default=False, action="store_true", help="--auth"
)
parser.add_argument(
    "--out", type=str, required=False, default="", help="--out <fileNameToSaveTo.csv>"
)
parser.add_argument(
    "--sub", type=str, required=False, default="", help="--sub xxxx-xx-x-....."
)
parser.add_argument(
    "--rg", type=str, required=False, default="", help="--rg myResourceGroupName"
)

args = parser.parse_args()


def main():
    subscription_id = ""
    resource_group_name = ""
    vms = []
    bearer_token = ""

    if args.config == "" and args.token == "" and args.auth is False:
        print(
            "Auth option is required: --config <config.yaml>, --token <token>, or --auth"
        )
        exit(1)
    elif args.token:
        bearer_token = args.token
        print("Running Default")
    elif args.auth:
        credential = AzureCliCredential()
        # cred_token = credential.get_token("https://graph.microsoft.com/.default")
        # cred_token = credential.get_token("https://management.azure.com/.default")
        # cred_token = credential.get_token("https://login.microsoft.com/.default")
        cred_token = credential.get_token("https://management.azure.com")
        bearer_token = cred_token.token
        print("Credential:")
        print(credential)
        print("Credential Token:")
        print(cred_token)
        print("Bearer Token:")
        print(bearer_token)
        # exit(1)
    elif args.config != "":
        with open(args.config, "r") as infile:
            azure_config = yaml.safe_load(infile)
            subscription_id = azure_config["azure"]["subscription"]
            resource_group_name = azure_config["azure"]["resource_group"]
            vms = azure_config["azure"]["vms"]
            token = azure_config["azure"]["token"]
            bearer_token = "Bearer " + "".join(token)
    else:
        print("Error with Auth!")
        exit(1)

    if args.config == "":
        if args.sub == "" and args.rg == "":
            print("If --config file is not passed, --sub and --rg are required!")
            exit(1)

        subscription_id = args.sub
        resource_group_name = args.rg
        print("\nSUB:" + subscription_id + "\t|\tRG:" + resource_group_name)

    vm_url = (
        "https://management.azure.com/subscriptions/"
        + subscription_id
        + "/resourceGroups/"
        + resource_group_name
        + "/providers/Microsoft.Compute/virtualMachines?api-version=2021-07-01"
    )

    payload = {}
    headers = {"Authorization": "Bearer " + bearer_token}
    vm_response = requests.request("GET", vm_url, headers=headers, data=payload).json()
    print(vm_response)
    # print("SUCCES?!")

    # pretty_json = json.loads(vm_response.text)
    # print(json.dumps(pretty_json, indent=3, sort_keys=True))

    # VM Private IP Enum
    # vm_priv_ips_url = "https://management.azure.com/subscriptions/" + subscription_id + "/resourceGroups/" + resource_group_name + "/providers/Microsoft.Network/privateIPAddresses?api-version=2021-03-01"
    # GET https://management.azure.com/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.Network/networkInterfaces?api-version=2021-03-01
    # TODO: This requires a machine name
    vm_priv_ips_url = (
        "https://management.azure.com/subscriptions/"
        + subscription_id
        + "/resourceGroups/"
        + resource_group_name
        + "/providers/Microsoft.Network/networkInterfaces?api-version=2021-03-01"
    )
    print(vm_priv_ips_url)
    print(headers)
    vm_response_priv_ips = requests.request(
        "GET", vm_priv_ips_url, headers=headers, data=payload
    )
    print(vm_response_priv_ips.text)

    pretty_json_priv_ips = json.loads(vm_response_priv_ips.text)
    print("][ Private IP Addresses ][")
    print(json.dumps(pretty_json_priv_ips, indent=3, sort_keys=True))
    print("][ Private IP Addresses Filtered: ][")

    print(pretty_json_priv_ips)

    priv_ip_list = []
    for machine in pretty_json_priv_ips["value"]:
        machine_priv_ip = machine["properties"]["ipConfigurations"][0]["properties"][
            "privateIPAddress"
        ]
        priv_ip_list.append(machine_priv_ip)
        print(machine_priv_ip)

    if args.out != "":
        with open(args.out, "w") as outfile:
            writer = csv.writer(outfile)
            writer.writerow(priv_ip_list)
            # for eachIP in priv_ip_list:
            #    outfile.write("%s\n" % eachIP)
        outfile.close()

    # GET https://management.azure.com/subscriptions/{subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.Network/publicIPAddresses?api-version=2021-03-01

    # vm_public_ips = "https://management.azure.com/subscriptions/" + subscription_id + "/resourceGroups/" + resource_group_name + "/providers/Microsoft.Network/publicIPAddresses?api-version=2021-03-01"
    # vm_response_public_ips = requests.request("GET", vm_public_ips, headers=headers, data=payload)
    #
    # pretty_json_public_ips = json.loads(vm_response_public_ips.text)
    # print("][ Public IP Addresses ][")
    # print(json.dumps(pretty_json_public_ips, indent=3, sort_keys=True))


if __name__ == "__main__":
    main()
