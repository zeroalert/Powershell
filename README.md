Install-Module PnP.PowerShell -RequiredVersion 2.12.0 -Scope CurrentUser -Force
Get-Module PnP.PowerShell -ListAvailable | Select Version,ModuleBase
Import-Module PnP.PowerShell -RequiredVersion 2.12.0 -Force
$env:PSModulePath
