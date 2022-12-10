<# 
    Script to search through Windows Event Logs .evtx files
                            by
                      Manuel Berrueta
#>

[CmdletBinding()]
param(
    [string] $TargetEvtxFile
)

# The following events were sourced from DeepBlueCLI (https://github.com/sans-blue-team/DeepBlueCLI)
$sys_events = @("7030", "7036", "7045", "7040", "104")
$sec_events = @("4688", "4672", "4720", "4728", "4732", "4756", "4625", "4673", "4674", "4648", "1102")
$app_events = @("2")
$applocker_events = @("8003", "8004", "8006", "8007")
$powershell_events = @("4103", "4104")
$sysmon_events = @("1", "7")
$testEventNum = @("1033", "1107")

$TargetEvtxFile = "C:\Users\0siris\Downloads\2022_KringleCon\powershell.evtx"
$Events = Get-WinEvent -Path $TargetEvtxFile

#!This is the string that will be matched in message
$interestedStr = "client"

#!This is a list of strings intersting to us
$interestingStrList = @("admin", "password", "secret")

ForEach ($Event in $Events) {
    $eventID = $Event.id
    $eventIDStr = "$eventID"

    #* Change this to match interested IDs
    if ( $eventIDStr | ? { $testEventNum -match $_ }  ) {
        $eventType = $Event.LogName
        #echo "$eventID is a $eventType event"

        #! Uncomment whatever properties you would like to see
        $Event.Properties
        $Event.Message
        #$Event.MachineName
        $Event.TimeCreated
        #$Event.UserId
        #$Event.ProcessId
        #$Event.ThreadId
    }

    #* Match 1 string of interests in the message
    #if ( $Event.Message -like "*$interestedStr*") {
    #    Write-Host $Event.Message -ForegroundColor Green -BackgroundColor Black
    #}
    
    #* Match list of strings of interests in the message
    if ( $Event.Message | Select-String -Pattern $interestingStrList  ) {
        Write-Host "`n" -BackgroundColor DarkBlue -n
        Write-Host
        Write-Host " $($Event.TimeCreated) " -ForegroundColor White -BackgroundColor Magenta -n
        Write-Host "| EVENT ID: $($Event.Id) " -ForegroundColor Blue -n
        Write-Host "| Machine: $($Event.MachineName) " -ForegroundColor Blue -n
        Write-Host "| User: $($Event.UserId) " -ForegroundColor Blue -n
        Write-Host "| PID: $($Event.ProcessId)" -ForegroundColor Blue -n
        Write-Host
        Write-Host "TASK: $($Event.TaskDisplayName)" -ForegroundColor Yellow
        Write-Host $Event.Message -ForegroundColor Green -BackgroundColor Black
        Write-Host "Event Properties:`n$($Event.Properties[0].Value)" -ForegroundColor Red
        Write-Host "`n" -BackgroundColor DarkBlue -n
        Write-Host ""
    }
}