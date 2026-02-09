# Powershell

Starting: PowerShell
==============================================================================
Task         : PowerShell
Description  : Run a PowerShell script on Linux, macOS, or Windows
Version      : 2.268.1
Author       : Microsoft Corporation
Help         : https://docs.microsoft.com/azure/devops/pipelines/tasks/utility/powershell
==============================================================================
Generating script.
Formatted command: . 'E:\Agent_SVC_Devops_GMSA_1\_work\53\s\SharePoint Utilities\Sharepoint_OnCall.ps1' -LogLocation "E:\Agent_SVC_Devops_GMSA_1\_work\53\a"
========================== Starting Command Output ===========================
"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Unrestricted -Command ". 'E:\Agent_SVC_Devops_GMSA_1\_work\_temp\c0deee3d-0df8-4587-893c-b79207f908c9.ps1'"
Log Started
VERBOSE: Performing the operation "Start-Transcript" on target 
"E:\Agent_SVC_Devops_GMSA_1\_work\53\a\Sharepoint_OnCall_029261200.log".
Transcript started, output file is E:\Agent_SVC_Devops_GMSA_1\_work\53\a\Sharepoint_OnCall_029261200.log
WARNING: MSG:UnableToDownload «https://go.microsoft.com/fwlink/?LinkID=627338&clcid=0x409» «»
WARNING: Unable to download the list of available providers. Check your internet connection.
Importing Module
WARNING: The names of some imported commands from the module 'sharepointpnppowershellonline' include unapproved verbs 
that might make them less discoverable. To find the commands with unapproved verbs, run the Import-Module command again
 with the Verbose parameter. For a list of approved verbs, type Get-Verb.
Running Function Sync
WARNING: 
                                                                                                                     
 You are running the legacy version of PnP PowerShell.                                                               
                                                                                                                     
 This version will be archived soon which means that while staying available, no updates or fixes will be released.  
 Consider installing the newer prereleased cross-platform version of PnP PowerShell.                                 
 This version has numerous improvements and many more cmdlets available.                                             
 To install the new version:                                                                                         
                                                                                                                     
 Uninstall-Module -Name SharePointPnPPowerShellOnline -AllVersions -Force                                            
 Install-Module -Name PnP.PowerShell                                                                                 
                                                                                                                     
 Read more about the new cross-platform version of PnP PowerShell at                                                 
                                                                                                                     
 https://pnp.github.io/powershell                                                                                    
                                                                                                                     
 To hide this message set the environment variable PNPLEGACYMESSAGE to "false"                                       
 In PowerShell add $env:PNPLEGACYMESSAGE='false' to your profile. Alternatively use 'Connect-PnPOnline -Url          
 [yoururl] -WarningAction Ignore'                                                                                    

Connect-PnPOnline : The remote server returned an error: (403) Forbidden.
At E:\Agent_SVC_Devops_GMSA_1\_work\53\s\SharePoint Utilities\Sharepoint_OnCall.ps1:1326 char:1
+ Connect-PnPOnline -Url $SiteURL -Credentials $cred
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Connect-PnPOnline], WebException
    + FullyQualifiedErrorId : System.Net.WebException,PnP.PowerShell.Commands.Base.ConnectOnline
 
##[error]PowerShell exited with code '1'.
Finishing: PowerShell
