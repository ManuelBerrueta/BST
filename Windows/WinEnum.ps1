<#*
    Windows Enumeration Script by Manny Berrueta
    NOTE: I recommend redirecting the output using `> outFile.txt`
    Example: `.\WinEnum.ps1 > outFile.txt`
#>

$Separator = "============================"

Write-Host "`n$Separator[ Host Name ]$Separator" -ForegroundColor Magenta
$global:HostName = hostname
$HostName

Write-Host "`n$Separator[ User Privs ]$Separator" -ForegroundColor Green
$global:userPrivs = whoami /priv
$userPrivs

Write-Host "`n$Separator[ Net Users ]$Separator" - ForegroundColor Yellow
$global:netUsers = net users
$netUsers

Write-Host "`n$Separator[ qwinsta Output ]$Separator" -ForegroundColor Red
$global:Qwin = qwinsta.exe
$Qwin

Write-Host "`n$Separator[ Local Groups ]$Separator" -ForegroundColor Blue
$global:LocalGroups = net localgroup
$LocalGroups

Write-Host "`n$Separator[ List Admin Group Users ]$Separator" -ForegroundColor DarkMagenta
$global:AdminUsers = net localgroup Administrators
$AdminUsers

Write-Host "`n$Separator[ System Info ]$Separator" -ForegroundColor DarkGreen
$global:SystemInfo = systeminfo
$SystemInfo

Write-Host "`n$Separator[ OS info ]$Separator" -ForegroundColor DarkGreen
$OSVersion = systeminfo | findstr /B /C:"OS Name" /C:"OS Version"
$OSVersion

Write-Host "`n$Separator[ Patch Level ]$Separator" -ForegroundColor DarkRed
$global:PatchLevel = wmic qfe get Caption,Description,HotFixID,InstalledOn
$PatchLevel

Write-Host "`n$Separator[ Local Listening Ports ]$Separator" -ForegroundColor Cyan
$global:ListeningPorts = netstat -ano
$ListeningPorts

Write-Host "`n$Separator[ Scheduled Tasks ]$Separator" -ForegroundColor Gray
$global:ScheduledTasks = schtasks /query /fo LIST /v
$ScheduledTasks

Write-Host "`n$Separator[ Drivers ]$Separator" -ForegroundColor Yellow
$global:Drivers = driverquery.exe
$Drivers

Write-Host "`n$Separator[ Windows Defender Status ]$Separator" -ForegroundColor Green
$WinDefenderStatus = sc query WinDefend
if ($WinDefenderStatus) {
    
    Write-Host "sc query success"
} else {
    $WinDefenderStatus = Get-Service -DisplayName *Defender*
    $WinDefenderStatus
    Write-Host "Get-Service success"
}

Write-Host "`n$Separator[ List All Services ]$Separator" -ForegroundColor DarkGreen
$ServicesList = sc queryex type=service
$ServicesList

Write-Host