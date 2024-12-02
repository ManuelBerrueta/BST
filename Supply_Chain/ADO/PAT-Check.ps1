param (
    [string]$pat,
    [string]$organization
)

# Function to check if a given PAT token is valid and identity data of the user
function Test-PATToken {
    param (
        [string]$patToken,
        [string]$organization
    )

    # Reference: https://developercommunity.visualstudio.com/t/validate-the-azure-devops-pat/378467
    $connectionDataUrl = "https://dev.azure.com/${organization}/_apis/connectionData"

    # Encode the PAT token to Base64
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$patToken"))

    # Create the HTTP request headers
    $headers = @{
        Authorization = "Basic $base64AuthInfo"
    }

    # Make the HTTP request to the Azure DevOps REST API
    try {
        $response = Invoke-WebRequest -Uri $connectionDataUrl -Method Get -Headers $headers -ErrorAction Stop
        $jsonObj = ConvertFrom-Json $([String]::new($response.Content))
        Write-Output "Response: $($jsonObj | ConvertTo-Json -depth 100)"
        Write-Host "PAT token is valid." -ForegroundColor Green
    }
    catch {
        Write-Host "PAT token is invalid." -ForegroundColor Red
    }
}

# Call the function to check the PAT token
Test-PATToken -patToken $pat -organization $organization