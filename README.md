PS C:\Windows\system32> Save-Module -Name PnP.PowerShell -Path C:\Temp\PnPModule -RequiredVersion 2.12.0


Save-Module : Cannot find the path 'C:\Temp\PnPModule' because it does not exist.
At line:1 char:1
+ Save-Module -Name PnP.PowerShell -Path C:\Temp\PnPModule -RequiredVer ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [Save-Module], InvalidOperationException
    + FullyQualifiedErrorId : PathNotFound,Save-Module
 







Save-Module -Name PnP.PowerShell -Path C:\Temp\PnPModule -RequiredVersion 2.12.0


# make sure module isn't loaded in THIS session
Remove-Module PnP.PowerShell -Force -ErrorAction SilentlyContinue

# kill any leftover pwsh/powershell that might have it loaded
Get-Process pwsh,powershell -ErrorAction SilentlyContinue | Stop-Process -Force

# now delete the folder
Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0" -Recurse -Force



Rename-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0" "3.1.0.DELETE"
Restart-Computer
Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0.DELETE" -Recurse -Force


Install-Module PnP.PowerShell -RequiredVersion 2.12.0 -Scope CurrentUser -Force


Get-Module PnP.PowerShell -ListAvailable | Select Version,ModuleBase
