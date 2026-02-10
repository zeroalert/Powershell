2026-02-10T16:53:44.4234019Z ##[section]Starting: Delete SSIS Project Pre-Install
2026-02-10T16:53:44.4245730Z ==============================================================================
2026-02-10T16:53:44.4245854Z Task         : PowerShell
2026-02-10T16:53:44.4245924Z Description  : Run a PowerShell script on Linux, macOS, or Windows
2026-02-10T16:53:44.4246007Z Version      : 2.268.1
2026-02-10T16:53:44.4246065Z Author       : Microsoft Corporation
2026-02-10T16:53:44.4246146Z Help         : https://docs.microsoft.com/azure/devops/pipelines/tasks/utility/powershell
2026-02-10T16:53:44.4246233Z ==============================================================================
2026-02-10T16:53:45.7864872Z Generating script.
2026-02-10T16:53:45.8231152Z ========================== Starting Command Output ===========================
2026-02-10T16:53:45.8501760Z ##[command]"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Unrestricted -Command ". 'C:\agent\_work\_temp\a4ebebba-64a5-4bae-8ff6-277d42922efb.ps1'"
2026-02-10T16:53:48.4076791Z invoke-sqlcmd : Cannot find the project 'Wings_ODS' because it does not exist or you do not have sufficient 
2026-02-10T16:53:48.4077262Z permissions.
2026-02-10T16:53:48.4078168Z At C:\agent\_work\_temp\a4ebebba-64a5-4bae-8ff6-277d42922efb.ps1:4 char:1
2026-02-10T16:53:48.4078689Z + invoke-sqlcmd -query "EXEC [SSISDB].[catalog].[delete_project] @proje ...
2026-02-10T16:53:48.4079625Z + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
2026-02-10T16:53:48.4080181Z     + CategoryInfo          : InvalidOperation: (:) [Invoke-Sqlcmd], SqlPowerShellSqlExecutionException
2026-02-10T16:53:48.4080653Z     + FullyQualifiedErrorId : SqlError,Microsoft.SqlServer.Management.PowerShell.GetScriptCommand
2026-02-10T16:53:48.4080911Z  
2026-02-10T16:53:48.4991755Z ##[error]PowerShell exited with code '1'.
2026-02-10T16:53:48.5444500Z ##[section]Finishing: Delete SSIS Project Pre-Install
