Install-Module PnP.PowerShell -RequiredVersion 2.12.0 -Scope CurrentUser -Force -AllowClobber

Remove-Module PnP.PowerShell -Force -ErrorAction SilentlyContinue
Import-Module PnP.PowerShell -RequiredVersion 2.12.0 -Force
Get-Module PnP.PowerShell | Select Name,Version,ModuleBase
Rename-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0" "3.1.0.PS7ONLY"
