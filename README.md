Install-Module PnP.PowerShell -Force -AllowClobber -Scope AllUsers   Uninstall-Module SharePointPnPPowerShellOnline -AllVersions -Force



PS C:\Windows\system32> Install-Module PnP.PowerShell -Force -AllowClobber -Scope AllUsers 
PackageManagement\Install-Package : Package 'PnP.PowerShell' failed to be installed because: End of Central 
Directory record could not be found.
At C:\Program Files\WindowsPowerShell\Modules\PowerShellGet\1.0.0.1\PSModule.psm1:1809 char:21
+ ...          $null = PackageManagement\Install-Package @PSBoundParameters
+                      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidResult: (PnP.PowerShell:String) [Install-Package], Exception
    + FullyQualifiedErrorId : Package '{0}' failed to be installed because: {1},Microsoft.PowerShell.Package 
   Management.Cmdlets.InstallPackage
 

PS C:\Windows\system32> 
