Add-Type -AssemblyName PresentationFramework -PassThru | Out-Null

$colors = [System.Windows.Media.Colors] | Get-Member -static -Type Property |Select -Expand Name
Foreach ($col in $colors) { try { Write-Host "$col"  -ForegroundColor $col -BackgroundColor Black } catch {} }

# Source: https://stackoverflow.com/questions/20541456/list-of-all-colors-available-for-powershell