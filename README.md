Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module PowerShellGet -Force -AllowClobber


PS C:\Windows\system32> Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

WARNING: Unable to download from URI 'https://go.microsoft.com/fwlink/?LinkID=627338&clcid=0x409' to ''.
WARNING: Unable to download the list of available providers. Check your internet connection.
Install-PackageProvider : No match was found for the specified search criteria for the provider 'NuGet'. The 
package provider requires 'PackageManagement' and 'Provider' tags. Please check if the specified package has 
the tags.
At line:1 char:1
+ Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Power...PackageProvider:InstallPackageProvider) [I 
   nstall-PackageProvider], Exception
    + FullyQualifiedErrorId : NoMatchFoundForProvider,Microsoft.PowerShell.PackageManagement.Cmdlets.Install 
   PackageProvider
 
