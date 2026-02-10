# Write-Host "Performing Security Engineer Function"
# Set-sec
Write-Host "Performing TeleAdm Function"
Set-TeleAdm
Write-Host "Complete Exiting Now"

Exit
cmdlet  at command pipeline position 1
Supply values for the following parameters:
LogLocation: C:\
PfxPassword: Firewall1!
Log Started
VERBOSE: Performing the operation "Start-Transcript" on target "C:\Sharepoint_OnCall_0210260936.log".
Transcript started, output file is C:\\Sharepoint_OnCall_0210260936.log
WARNING: MSG:UnableToDownload «https://go.microsoft.com/fwlink/?LinkID=627338&clcid=0x409» «»
WARNING: Unable to download the list of available providers. Check your internet connection.
WARNING: Unable to download from URI 'https://go.microsoft.com/fwlink/?LinkID=627338&clcid=0x409' to ''.
WARNING: Unable to download the list of available providers. Check your internet connection.
Importing Module
Import-Module : The specified module 'PnP.PowerShell' was not loaded because no valid module file was found 
in any module directory.
At line:61 char:1
+ Import-Module PnP.PowerShell -Force -WarningAction Ignore
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ResourceUnavailable: (PnP.PowerShell:String) [Import-Module], FileNotFoundExce 
   ption
    + FullyQualifiedErrorId : Modules_ModuleNotFound,Microsoft.PowerShell.Commands.ImportModuleCommand
 
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
