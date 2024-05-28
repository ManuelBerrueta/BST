import json
import requests
import boto3 # AWS SDK for Python (Boto3) 'pip install boto3'
import pyperclip
import sys

sts_client = boto3.Session(profile_name='default').client('sts')

arn_role = "" # Example "arn:aws:iam::532587168180:user/myuser"

assumed_role_object = sts_client.assume_role(
    RoleArn=arn_role,
    RoleSessionName="AssumeRoleSession",
)
url_credentials = {}
url_credentials['sessionId'] = assumed_role_object.get('Credentials').get('AccessKeyId')
url_credentials['sessionKey'] = assumed_role_object.get('Credentials').get('SecretAccessKey')
url_credentials['sessionToken'] = assumed_role_object.get('Credentials').get('SessionToken')
json_string_with_temp_credentials = json.dumps(url_credentials)


#request_parameters = "?Action=GetFederationToken"
request_parameters = "?Action=getSigninToken"
request_parameters += "&SessionDuration=43200"
request_parameters += "&Session=" + requests.utils.quote(json_string_with_temp_credentials)
request_url = "https://signin.aws.amazon.com/federation" + request_parameters

print(request_url)
r = requests.get(request_url)

try:
    signin_token = json.loads(r.text)
    print(r.text)
except ValueError:
    print("Failed to parse json response")
    print(f'Response code {r.status_code}')
    sys.exit(1)

#! Generate signed URL
request_parameters = "?Action=login" 
request_parameters += "&Issuer=Example.org"
request_parameters += "&Destination=" + requests.utils.quote("https://console.aws.amazon.com")
request_parameters += "&SigninToken=" + signin_token["SigninToken"]
request_url = "https://signin.aws.amazon.com/federation" + request_parameters

print(request_url)
pyperclip.copy(request_url)
print("URL copied to clipboard")
