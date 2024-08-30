# Function to display usage information
display_usage() {
    echo "Usage: $0 --subid <subscription_Id> [--access_token <access_token>]"
    echo "  --subid  : The subscription ID"
    echo "  --access_token     : The access token (optional)"
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --subid) subscription_Id="$2"; shift ;;
        --access_token) access_token="$2"; shift ;;
        -h|--help) display_usage; exit 0 ;;
        *) echo "Unknown parameter passed: $1"; display_usage; exit 1 ;;
    esac
    shift
done

# Check if subscription_Id is provided
if [ -z "$subscription_Id" ]; then
    echo "Error: --subid is required"
    display_usage
    exit 1
fi

# If access_token is not provided, get it using Azure CLI
if [ -z "$access_token" ]; then
    access_token=$(az account get-access-token --query accessToken --output tsv)
    if [ -z "$access_token" ]; then
        echo "Failed to obtain access token"
        exit 1
    fi
fi

response=$(curl "https://management.azure.com/subscriptions/$subscription_Id/providers/Microsoft.Authorization/roleDefinitions?api-version=2018-07-01&$filter=applicableToScope+eq+%27/subscriptions/$subscription_Id%27" \
  -H 'x-ms-client-session-id: 0' \
  -H 'x-ms-command-name: Microsoft_Azure_PIMCommon.' \
  -H 'Accept-Language: en' \
  -H "Authorization: Bearer $access_token" \
  -H 'x-ms-effective-locale: en.en-us' \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36 Edg/127.0.0.0' \
  -H 'Accept: */*' \
  -H 'Referer;' \
  -H 'x-ms-client-request-id: 0' \
)

echo $response | jq

# Filter out just the roleName
# jq '.value[].properties.roleName'

# Get the id for the role:
# jq '.value[] | select(.properties.roleName == "specificRoleName") | .name'
#   Exampl with "Owner" role:
#   jq '.value[] | select(.properties.roleName == "Owner") | .name'

# To get other useful properties:
# jq '.value[] | select(.properties.roleName == "Owner") | {name, id, type: .properties.type, description: .properties.description}'