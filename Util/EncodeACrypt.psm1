# My approach here is to create one module for a generic solution that can be used for a file, text, or whatvever

function ConvertStrTo-Base64 {
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [String[]]$InputStr
    )
    try {
        $EncodedBase64String = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($InputStr))
        Write-Host $EncodedBase64String  -ForegroundColor Green
        return $EncodedBase64String
    }
    catch {
        { 1:Write-Warning -Message "Error Processing Input String" }
    }
}

function ConvertFrom-Base64 {
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [String[]]$InputStr
    )
    try {
        $DecodedBase64String = [System.Text.Encoding]::Unicode.GetString([Convert]::FromBase64String($EncodedString))
        Write-Host $DecodedBase64String -ForegroundColor Green
        return $DecodedBase64String
    }
    catch {
        { 1:Write-Warning -Message "Error Processing Input String" }
    }
}

function ConvertFileTo-Base64 {
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [String[]]$InpuFilePath,
        [Parameter(Mandatory = $False, ValueFromPipeline = $True)]
        [String[]]$OutputFilePath
    )
    try {
        $fileBytes = [System.IO.File]::ReadAllBytes($InpuFilePath);
        $EncodedBase64FileString = [Convert]::ToBase64String($fileBytes)
        Write-Host $EncodedBase64FileString  -ForegroundColor Green

        # TODO:
        #if ($OutputFilePath) {
        #    try {
        #        Write-Host "I should be outputing file!"
        #        Out-File -FilePath $OutputFilePath -InputObject $EncodedBase64FileString
        #    }
        #    catch {
        #        { 1:Write-Warning -Message "Failed to write file" }
        #    }            
        #}
        return $EncodedBase64FileString
    }
    catch {
        { 1:Write-Warning -Message "Error Processing Input String" }
    }
}

function ConvertFileFrom-Base64 {
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [String[]]$EncodedInputFileStr,
        
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [String[]]$OutputFilePath
    )
    try {
        $DecodedBase64FileString = [Convert]::FromBase64String($EncodedInputFileStr)
        [System.IO.File]::WriteAllBytes($OutputFilePath, $DecodedBase64FileString)
    }
    catch {
        { 1:Write-Warning -Message "Error Processing Input String" }
    }
}

function Use-Base64EncodedCmd {
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]
        [ValidateNotNullOrEmpty()]
        [String[]]$InputCmd
    )
    try {
        powershell -EncodedCommand $InputCmd
    }
    catch {
        { 1:Write-Warning -Message "Error Running Base64 String as Command" }
    }
    finally {
        Write-Host "Encoded command run attempt finished" -ForegroundColor Green
    }
    
}

Function Encrypt-Asymmetric {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Position = 0, Mandatory = $true)][ValidateNotNullOrEmpty()][System.String]
        $ClearText,
        [Parameter(Position = 1, Mandatory = $true)][ValidateNotNullOrEmpty()][ValidateScript({ Test-Path $_ -PathType Leaf })][System.String]
        $PublicCertFilePath
    )
    # Encrypts a string with a public key extracted from local Cert
    $PublicCert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($PublicCertFilePath)
    #$PublicCert = Get-ChildItem Pu
    $ByteArray = [System.Text.Encoding]::UTF8.GetBytes($ClearText)
    #$EncryptedByteArray = $PublicCert.PublicKey.Key.Encrypt($ByteArray, $true)
    $EncryptedByteArray = $PublicCert.PublicKey.Key.Encrypt($ByteArray, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA256)
    $EncryptedBase64String = [Convert]::ToBase64String($EncryptedByteArray)
    
    Return $EncryptedBase64String 
}

Function Decrypt-Asymmetric {
    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        [Parameter(Position = 0, Mandatory = $true)][ValidateNotNullOrEmpty()][System.String]
        $CertPath,        
        [Parameter(Position = 1, Mandatory = $true)][ValidateNotNullOrEmpty()][System.String]
        $EncryptedBase64String,
        [Parameter(Position = 2, Mandatory = $true)][ValidateNotNullOrEmpty()][System.String]
        $CertThumbprint
    )
    # Decrypts text using the private key from local system cert store
    $Cert = Get-ChildItem $CertPath | Where-Object { $_.Thumbprint -eq $CertThumbprint } #* This returns the X509Certificate2 object
    if ($Cert) {
        $EncryptedByteArray = [Convert]::FromBase64String($EncryptedBase64String)
        #$ClearText = [System.Text.Encoding]::UTF8.GetString($Cert.PrivateKey.Decrypt($EncryptedByteArray, $true)) #* Older PWSH versions use this
        $ClearText = [System.Text.Encoding]::UTF8.GetString($Cert.PrivateKey.Decrypt($EncryptedByteArray, [System.Security.Cryptography.RSAEncryptionPadding]::OaepSHA256))
    }
    Else { Write-Error "Certificate with thumbprint: $CertThumbprint not found!" }

    Return $ClearText
}

#! For this encrypt and decrypt functions I found them @ https://stackoverflow.com/questions/16994452/powershell-asymmetric-encrypt-decrypt-functions
#* No need to reinvent the wheel!
#* Some fixes: https://github.com/PowerShell/PowerShell/issues/12572

# To execute a Base64 encoded command pwsh -e
#   $my_ls = "ls"
#   $Base64EncodedStr = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($my_ls))
#   pwsh -e $Base64EncodedStr 

# To create a new cert to Encrypt/Decrypt:
#  New-SelfSignedCertificate -DnsName MyCertToEncryptDecrypt -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsage KeyEncipherment,DataEncipherment, KeyAgreement -Type DocumentEncryptionCert

#Exporting the private and public keys from a cert:
#  https://stackoverflow.com/questions/55284511/generating-an-rsa-key-pair-in-powershell
# Example: 
#  Export-PfxCertificate -FilePath myPrivateKey -Cert Cert:\LocalMachine\My\13x..34 -Password $("password" | ConvertTo-SecureString -AsPlainText -Force)
#  Export-Certificate -FilePath myPublicKey -Cert Cert:\LocalMachine\My\13x..34

#* Useful reference(s): 
#*  https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/10-script-modules?view=powershell-7.2
#*  https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.2

# Future Explorations 
#  https://stackoverflow.com/questions/40016624/powershell-asymmetric-encryption
#  https://stackoverflow.com/questions/63523447/decrypt-file-using-rsacryptoserviceprovider-in-powershell
#  https://stackoverflow.com/questions/34613479/rsacryptoserviceprovider-encrypt-and-decrypt-using-own-public-and-private-key