New-Item -ItemType Directory -Path C:\Temp\PnPModule -Force

Save-Module -Name PnP.PowerShell -Path C:\Temp\PnPModule -RequiredVersion 2.12.0






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























Log Started
VERBOSE: Performing the operation "Start-Transcript" on target "C:\Sharepoint_OnCall_0210260116.log".
Transcript started, output file is C:\\Sharepoint_OnCall_0210260116.log
WARNING: MSG:UnableToDownload «https://go.microsoft.com/fwlink/?LinkID=627338&clcid=0x409» «»
WARNING: Unable to download the list of available providers. Check your internet connection.
Importing Module
Import-Module : The version of Windows PowerShell on this computer is '5.1.17763.8276'. The module 
'C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\PnP.PowerShell.psd1' requires a minimum 
Windows PowerShell version of '7.4.6' to run. Verify that you have the minimum required version of Windows 
PowerShell installed, and then try again.
At line:61 char:1
+ Import-Module PnP.PowerShell -Force -WarningAction Ignore
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (C:\Program File...PowerShell.psd1:String) [Import-Module 
   ], InvalidOperationException
    + FullyQualifiedErrorId : Modules_InsufficientPowerShellVersion,Microsoft.PowerShell.Commands.ImportModu 
   leCommand
 
Running Function Sync
Connect-PnPOnline : A parameter cannot be found that matches parameter name 'CertificatePath'.
At line:880 char:2
+     -CertificatePath $CertPath `
+     ~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Connect-PnPOnline], ParameterBindingException
    + FullyQualifiedErrorId : NamedParameterNotFound,PnP.PowerShell.Commands.Base.ConnectOnline
 
Get-PnPListItem : There is currently no connection yet. Use Connect-PnPOnline to connect.
At line:884 char:14
+ $ListItems = Get-PnPListItem -List $ListName
+              ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Get-PnPListItem], InvalidOperationException
    + FullyQualifiedErrorId : System.InvalidOperationException,PnP.PowerShell.Commands.Lists.GetListItem
 
Get-PnPProperty : Cannot bind argument to parameter 'ClientObject' because it is null.
At line:888 char:52
+         $ListItem  = Get-PnPProperty -ClientObject $_ -Property Field ...
+                                                    ~~
    + CategoryInfo          : InvalidData: (:) [Get-PnPProperty], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationErrorNullNotAllowed,PnP.PowerShell.Commands.Base.En 
   sureProperty
 
Get-PnPField : There is currently no connection yet. Use Connect-PnPOnline to connect.
At line:891 char:9
+         Get-PnPField -List $ListName | ForEach-Object {
+         ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Get-PnPField], InvalidOperationException
    + FullyQualifiedErrorId : System.InvalidOperationException,PnP.PowerShell.Commands.Fields.GetField
 
Performing System Engineer Function
Performing DBA Function
Performing ASA Lending Function
Performing ASA Digital Function
Performing ASA BackOffice Function
Performing ASA Retail Function
Performing Network Engineer Function
Performing TeleAdm Function
Complete Exiting Now

PS C:\Users\3382z9> 
