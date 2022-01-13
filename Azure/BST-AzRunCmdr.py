#!/usr/bin/env python3
import requests
import json
from requests.models import Response
import yaml
import argparse
from azure.identity import AzureCliCredential
import time

parser = argparse.ArgumentParser()
parser.add_argument('--config', type=str, required=False,
                    default="", help='--config <AzureConfig.yaml')
parser.add_argument('--token', type=str, required=False,
                    default='', help='--config <AzureConfig.yaml')
parser.add_argument(
    "--auth", required=False, default=False, action="store_true", help="--auth"
)
parser.add_argument(
    "--sub", type=str, required=False, default="", help="--sub xxxx-xx-x-....."
)
parser.add_argument(
    "--rg", type=str, required=False, default="", help="--rg myResourceGroupName"
)
parser.add_argument(
    "--vms", required=False, nargs='+', default="", help="--vm myVmName"
)
parser.add_argument(
    "--cmds", required=True, default="", help="--cmds ls -lh /home/"
)
parser.add_argument('--windows', required=False, default=False,
                    action='store_true', help='--windows')

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
        cred_token = credential.get_token("https://management.azure.com")
        bearer_token = cred_token.token
        print("Credential:")
        print(credential)
        print("Credential Token:")
        print(cred_token)
        print("Bearer Token:")
        print(bearer_token)
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
        if args.sub == "" and args.rg == "" and not args.vms:
            print("If --config file is not passed, --sub, --rg and --vm are required!")
            exit(1)
        subscription_id = args.sub
        resource_group_name = args.rg
        vms = args.vms
        print("\nSUB:" + subscription_id + "\t|\tRG:" + resource_group_name)
        print(vms)

    #bearer_token = 'Bearer ' + ''.join(token)

    commands = args.cmds
    print("==[Commands]==")
    print(commands)

    if (args.windows):
        command_id = "RunPowerShellScript"
    command_id = "RunShellScript"

    payload = json.dumps({
        "commandId": command_id,
        "script": [
            commands
        ]
    })

    #! Working Example Payload
    # payload = json.dumps({
    #    "commandId": "RunShellScript",
    #    "script": [
    #        "ls -lh /home/"
    #    ]
    # })

    # Saved for additional option of formating
    # payload = json.dumps({
    #    "commandId": "RunShellScript",
    #    "script": [
    #        "cp $arg1 $arg2"
    #    ],
    #    "parameters": [
    #        {
    #            "name": "arg1",
    #            "value": "myFile"
    #        },
    #        {
    #            "name": "arg2",
    #            "value": "newFile"
    #        }
    #    ]
    # })

    headers = {"Authorization": "Bearer " +
               bearer_token, "Content-type": "application/json"}

    op_results = []

    for vm_name in vms:
        run_cmd_url = "https://management.azure.com/subscriptions/" + subscription_id + "/resourceGroups/" + \
            resource_group_name + "/providers/Microsoft.Compute/virtualMachines/" + \
            vm_name + "/runCommand?api-version=2021-07-01"

        response = requests.request(
            "POST", run_cmd_url, headers=headers, data=payload)
        # print(response.json())
        print("===[RESPONSE]===")
        print(response.text)
        print(response.headers)

        result_loc = response.headers
        print("==[RESULT LOC]==")
        print(result_loc["Location"])
        op_results.append(result_loc["Location"])

    time.sleep(15)
    empty_payload = {}

    response_text = ""
    for result_url in op_results:
        while response_text == "":
            response = requests.request(
                "GET", result_url, headers=headers, data=empty_payload)
            if response.text == "":
                print("Backend still processing result..")
                time.sleep(5)
            else:
                response_text = response.text
        print(response_text)
        response_text = ""


def response_parser(resp: Response):
    print("WIP")


if __name__ == "__main__":
    main()
