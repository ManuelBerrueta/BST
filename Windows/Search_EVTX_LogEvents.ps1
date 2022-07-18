<# Script to search through Windows Event Logs .evtx files
                            by 
#>                     Manuel Berrueta

# Change this to the path of the evtx file
$targetEvtxFile = "C:\temp\myEvents.evtx"

# The following events were sourced from DeepBlue (https://github.com/sans-blue-team/DeepBlueCLI)
$sys_events = @("7030", "7036", "7045", "7040", "104")
$sec_events = @("4688", "4672", "4720", "4728", "4732", "4756", "4625", "4673", "4674", "4648", "1102")
$app_events = @("2")
$applocker_events = @("8003", "8004", "8006", "8007")
$powershell_events = @("4103", "4104")
$sysmon_events = @("1", "7")
$testEventNum = @("1033", "1107")

$Events = Get-WinEvent -Path $targetEvtxFile

#!This is the string that will be matched in message
$interestedStr = "client"

#!This is a list of strings intersting to us
$interestingStrList = @("client", "user", "password")


ForEach ($Event in $Events) {
    $eventID = $Event.id
    $eventIDStr = "$eventID"

    #* Change this to match interested IDs
    if ( $eventIDStr | ? { $testEventNum -match $_ }  ) {
        $eventType = $Event.LogName
        #echo "$eventID is a $eventType event"
        #$Event.Properties
        #$Event.Message
    }

    #* Match 1 string of interests in the message
    if ( $Event.Message -like "*$interestedStr*") {
        Write-Host $Event.Message -ForegroundColor Green -BackgroundColor Black
    }
    
    # Match list of strings of interests in the message
    if ( $Event.Message | Select-String -Pattern $interestingStrList  ) {
        Write-Host $Event.Message -ForegroundColor Green -BackgroundColor Black
    }
}