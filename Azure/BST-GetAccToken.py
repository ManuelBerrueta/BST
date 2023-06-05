#https://azsec.azurewebsites.net/2019/12/20/a-few-ways-to-acquire-azure-access-token-with-scripting-languages/
from azure.identity import AzureCliCredential
credential = AzureCliCredential()
azure_devops_appid = "499b84ac-1321-427f-aa17-267ca6975798"
# $token = az account get-access–token —resource $azureDevopsResourceId --output json | ConvertFrom-Json
bearer_jwt = credential.get_token(azure_devops_appid)