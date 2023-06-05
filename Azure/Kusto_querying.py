from azure.kusto.data import KustoClient, KustoConnectionStringBuilder
from azure.kusto.data.exceptions import KustoServiceError
from azure.kusto.data.helpers import dataframe_from_result_table
import datetime
from azure.identity import AzureCliCredential
# Reference: https://learn.microsoft.com/en-us/azure/data-explorer/python-query-data
# Check authorization_endpoint @ https://login.microsoftonline.com/<YourDomain>/.well-known/openid-configuration/

AAD_TENANT_ID = ""
KUSTO_CLUSTER = "https://help.kusto.windows.net/"
KUSTO_DATABASE = "Samples"

KCSB = KustoConnectionStringBuilder.with_az_cli_authentication(KUSTO_CLUSTER)
KCSB.authority_id = AAD_TENANT_ID

KUSTO_CLIENT = KustoClient(KCSB)
KUSTO_QUERY = """
StormEvents 
| sort by StartTime desc 
| take 10
"""

date = datetime.datetime.utcnow()
print(f"UTC Timestamp: {date}")
RESPONSE = KUSTO_CLIENT.execute(KUSTO_DATABASE, KUSTO_QUERY)

df = dataframe_from_result_table(RESPONSE.primary_results[0])
df
print(df)
print("="*100)

kusto_query_results = df.to_dict('list')

for each in kusto_query_results:
    print(each)
    for each_obj in kusto_query_results[each]:
        print(f"\t{each_obj}")
    print("-"*80)