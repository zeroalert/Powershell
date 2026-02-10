Install-Module PnP.PowerShell -RequiredVersion 2.12.0 -Scope CurrentUser -Force -AllowClobber

Remove-Module PnP.PowerShell -Force -ErrorAction SilentlyContinue
Import-Module PnP.PowerShell -RequiredVersion 2.12.0 -Force
Get-Module PnP.PowerShell | Select Name,Version,ModuleBase
Rename-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0" "3.1.0.PS7ONLY"




PS C:\Users\3382z9> Import-Module PnP.PowerShell -RequiredVersion 2.12.0 -Force

Import-Module : The version of Windows PowerShell on this computer is '5.1.17763.8276'. The module 
'C:\Users\3382z9\Documents\WindowsPowerShell\Modules\PnP.PowerShell\2.12.0\PnP.PowerShell.psd1' requires a 
minimum Windows PowerShell version of '7.2' to run. Verify that you have the minimum required version of 
Windows PowerShell installed, and then try again.
At line:1 char:1
+ Import-Module PnP.PowerShell -RequiredVersion 2.12.0 -Force
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (C:\Users\3382z9...PowerShell.psd1:String) [Import-Module 
   ], InvalidOperationException
    + FullyQualifiedErrorId : Modules_InsufficientPowerShellVersion,Microsoft.PowerShell.Commands.ImportModu 
   leCommand
 
Import-Module : The specified module 'PnP.PowerShell' with version '2.12.0' was not loaded because no valid 
module file was found in any module directory.
At line:1 char:1
+ Import-Module PnP.PowerShell -RequiredVersion 2.12.0 -Force
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (PnP.PowerShell:String) [Import-Module], FileNotFoundExce 
   ption
    + FullyQualifiedErrorId : Modules_ModuleWithVersionNotFound,Microsoft.PowerShell.Commands.ImportModuleCo 
   mmand
 
