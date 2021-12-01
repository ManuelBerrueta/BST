#!/usr/bin/env python3
import requests
import json
import yaml
import argparse

sub_url = "https://management.azure.com/subscriptions?api-version=2020-01-01"

parser = argparse.ArgumentParser()

parser.add_argument('--config', type=str, required=False, default='./Azure/config.yaml', help='--config <AzureConfig.yaml')
parser.add_argument('--token', type=str, required=False, default='', help='--config <AzureConfig.yaml')
args = parser.parse_args()

with open(args.config, "r") as infile:
    azure_config = yaml.safe_load(infile)

token = azure_config["azure"]["token"]

bearer_token = 'Bearer ' + ''.join(token)

payload={}
headers = {
  'Authorization': bearer_token
}
response = requests.request("GET", sub_url, headers=headers, data=payload)

pretty_json = json.loads(response.text)
print(json.dumps(pretty_json, indent=3, sort_keys=True))
