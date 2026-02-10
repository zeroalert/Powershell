ForEach-Object: C:\Users\3382z9\Documents\Test.ps1:975
Line |
 975 |          Get-PnPField -List $ListName | ForEach-Object {
     |                                         ~~~~~~~~~~~~~~~~
     | The property or field has not been initialized. It has not been requested or the request has not been executed.
     | It may need to be explicitly requested.
PS C:\Users\3382z9\Documents> .\Test.ps1 -LogLocation C:\logs -PfxPassword "Firewall1!"
Log Started
VERBOSE: Performing the operation "Start-Transcript" on target "C:\logs\Sharepoint_OnCall_0210261402.log".
Transcript started, output file is C:\logs\Sharepoint_OnCall_0210261402.log
Importing Module
Running Function Sync
Connecting to SharePoint (app-only cert)
Performing System Engineer Function
Current Primary On Call Sys Engineer has been identified as Dan Madigan
Current Primary On Call Sys Engineer SMS has been identified as Dan
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call Sys Engineer,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
Test.ps1: A parameter with the name 'Verbose' was defined multiple times for the command.
PS C:\Users\3382z9\Documents>
