Write-Warning -Message "Access Control List (ACL) Adjuster"

$Yes = 1
$Counter = 0

$HowManyACLs = Read-Host "How many ACL(s) would you like to set?"
while($Counter -ne $HowManyACLs)
{
    $ObjecToModifyPath = Read-Host "What is the path of the target object's ACL that you would like to change :> "
    $CopyACLFromObject = Read-Host "Would you like to copy the ACL from another object? (1)Yes (0)No (Manually) :> "
    if ($CopyACLFromObject -eq 1)
    {
        $SourcePathOfObjectACL_To_Copy = Read-Host "What is the path of the object with the ACL you would like to copy? :> "
        $CheckWhatIf = Read-Host "What If Check? (1)Yes (2)No :>"
        if ($CheckWhatIf -eq $Yes)
        {
            $ACLToBeCopied = Get-Acl $SourcePathOfObjectACL_To_Copy
            Set-Acl -Path $ObjecToModifyPath -AclObject $ACLToBeCopied -WhatIf -Verbose
        }
        else 
        {
            $ACLToBeCopied = Get-Acl $SourcePathOfObjectACL_To_Copy
            Set-Acl -Path $ObjecToModifyPath -AclObject $ACLToBeCopied -Confirm -Verbose
        }
    }
    else
    {
        #Note permission type for ACL is as follows: "Domain\User","ControlType1,ControlType2,etc..","InheritanceType","Allow/Deny"
        $PermissionTypeForACL = Read-Host "Enter new ACL permission type for target object :> "
        $NewACL_Rule = New-Object System.Security.AccessControl.FileSystemAccessRule $PermissionTypeForACL
        $NewACL_Rule | Set-Acl -Path $ObjecToModifyPath -Confirm
    }
    $Counter++
}