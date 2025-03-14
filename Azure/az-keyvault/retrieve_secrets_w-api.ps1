# Get the access token for Key Vault or provide your own token
# If you have a specific token, you can set it directly
$token = (Get-AzAccessToken -ResourceUrl "https://vault.azure.net").Token 
$keyVaultName = "TargetKeyVaultName" # Replace with your Key Vault name
$secretNames = "secretName1", "secretName2", "secretName3" # Replace with your secret names
$outputFileName = "kv_secrets_dump.txt" # Output file name

foreach ($secretName in $secretNames) {
    $uri = "https://$($keyVaultName).vault.azure.net/secrets/$($secretName)?api-version=7.3"

    $headers = @{
        Authorization = "Bearer $token"
    }

    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

    # The secret value is stored in the "value" field
    $secretValue = $response.value
    Write-Output "$($secretName) : $($secretValue)" | out-file $outputFileName -append
    Write-Output "" | out-file $outputFileName -append # Add a blank line for readability
}