PS C:\Users\3382z9> Save-Module -Name PnP.PowerShell -Path C:\Temp\PnPModule -RequiredVersion 2.12.0vvvv


Save-Module : Cannot process argument transformation on parameter 'RequiredVersion'. Cannot convert value 
"2.12.0vvvv" to type "System.Version". Error: "Input string was not in a correct format."
At line:1 char:75
+ ... me PnP.PowerShell -Path C:\Temp\PnPModule -RequiredVersion 2.12.0vvvv
+                                                                ~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Save-Module], ParameterBindingArgumentTransformationExceptio 
   n
    + FullyQualifiedErrorId : ParameterArgumentTransformationError,Save-Module
 



PS C:\Users\3382z9> Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0" -Recurse -Force


Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Common\Microsoft.ApplicationInsights.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.ApplicationInsights.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Common\PnP.PowerShell.ALC.dll: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.PowerShell.ALC.dll:FileInfo) [Remove-Item], ArgumentExce 
   ption
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Common\PnP.PowerShell.ALC.pdb: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.PowerShell.ALC.pdb:FileInfo) [Remove-Item], ArgumentExce 
   ption
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Common: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Common:DirectoryInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\AngleSharp.Css.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (AngleSharp.Css.dll:FileInfo) [Remove-Item], ArgumentExceptio 
   n
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\AngleSharp.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (AngleSharp.dll:FileInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Bcl.Cryptography.dll: Access to the path 
is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Bcl.Cryptography.dll:FileInfo) [Remove-Item], Argu 
   mentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Bcl.TimeProvider.dll: Access to the path 
is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Bcl.TimeProvider.dll:FileInfo) [Remove-Item], Argu 
   mentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Caching.Abstractions.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Exten...bstractions.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Caching.Memory.dll: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Extensions.Caching.Memory.dll:FileInfo) [Remove-It 
   em], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microso
ft.Extensions.Configuration.Abstractions.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Exten...bstractions.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Configuration.Binder.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Exten...tion.Binder.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Configuration.dll: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Extensions.Configuration.dll:FileInfo) [Remove-Ite 
   m], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microso
ft.Extensions.DependencyInjection.Abstractions.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Exten...bstractions.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.DependencyInjection.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Exten...cyInjection.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Diagnostics.Abstractions.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Exten...bstractions.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Diagnostics.dll: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Extensions.Diagnostics.dll:FileInfo) [Remove-Item] 
   , ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Http.dll: Access to the path 
is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Extensions.Http.dll:FileInfo) [Remove-Item], Argum 
   entException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Logging.Abstractions.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Exten...bstractions.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Logging.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Extensions.Logging.dll:FileInfo) [Remove-Item], Ar 
   gumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microso
ft.Extensions.Options.ConfigurationExtensions.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Exten...nExtensions.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Options.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Extensions.Options.dll:FileInfo) [Remove-Item], Ar 
   gumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Extensions.Primitives.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Extensions.Primitives.dll:FileInfo) [Remove-Item], 
    ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Graph.Core.dll: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Graph.Core.dll:FileInfo) [Remove-Item], ArgumentEx 
   ception
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Graph.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Graph.dll:FileInfo) [Remove-Item], ArgumentExcepti 
   on
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Identity.Client.Broker.dll: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Identity.Client.Broker.dll:FileInfo) [Remove-Item] 
   , ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Identity.Client.dll: Access to the path 
is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Identity.Client.dll:FileInfo) [Remove-Item], Argum 
   entException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Identity.Client.Extensions.Msal.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Ident...nsions.Msal.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Identity.Client.NativeInterop.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Ident...tiveInterop.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.IdentityModel.Abstractions.dll: Access 
to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.IdentityModel.Abstractions.dll:FileInfo) [Remove-I 
   tem], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.IdentityModel.JsonWebTokens.dll: Access 
to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Ident...onWebTokens.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.IdentityModel.Logging.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.IdentityModel.Logging.dll:FileInfo) [Remove-Item], 
    ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.IdentityModel.Tokens.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.IdentityModel.Tokens.dll:FileInfo) [Remove-Item],  
   ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Office.Client.Policy.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Office.Client.Policy.dll:FileInfo) [Remove-Item],  
   ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Office.Client.TranslationServices.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Offic...ionServices.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Office.SharePoint.Tools.dll: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Office.SharePoint.Tools.dll:FileInfo) [Remove-Item 
   ], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Online.SharePoint.Client.Tenant.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Onlin...ient.Tenant.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.ProjectServer.Client.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.ProjectServer.Client.dll:FileInfo) [Remove-Item],  
   ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.SharePoint.Client.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.SharePoint.Client.dll:FileInfo) [Remove-Item], Arg 
   umentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microso
ft.SharePoint.Client.DocumentManagement.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Share...tManagement.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.SharePoint.Client.Publishing.dll: Access 
to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Share....Publishing.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.SharePoint.Client.Runtime.dll: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.SharePoint.Client.Runtime.dll:FileInfo) [Remove-It 
   em], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microso
ft.SharePoint.Client.Search.Applications.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Share...pplications.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.SharePoint.Client.Search.dll: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.SharePoint.Client.Search.dll:FileInfo) [Remove-Ite 
   m], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.SharePoint.Client.Taxonomy.dll: Access 
to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.SharePoint.Client.Taxonomy.dll:FileInfo) [Remove-I 
   tem], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.SharePoint.Client.UserProfiles.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Share...serProfiles.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.SharePoint.Client.WorkflowServices.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Share...lowServices.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Microsoft.Win32.Registry.AccessControl.dll: Access 
to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Microsoft.Win32...cessControl.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Newtonsoft.Json.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Newtonsoft.Json.dll:FileInfo) [Remove-Item], ArgumentExcepti 
   on
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\PnP.Core.Admin.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.Core.Admin.dll:FileInfo) [Remove-Item], ArgumentExceptio 
   n
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\PnP.Core.Auth.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.Core.Auth.dll:FileInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\PnP.Core.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.Core.dll:FileInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\PnP.Framework.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.Framework.dll:FileInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\PnP.PowerShell.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.PowerShell.dll:FileInfo) [Remove-Item], ArgumentExceptio 
   n
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\PnP.PowerShell.pdb: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.PowerShell.pdb:FileInfo) [Remove-Item], ArgumentExceptio 
   n
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\Portable.Xaml.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Portable.Xaml.dll:FileInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.CodeDom.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.CodeDom.dll:FileInfo) [Remove-Item], ArgumentExceptio 
   n
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.Configuration.ConfigurationManager.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.Configur...tionManager.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.Diagnostics.EventLog.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.Diagnostics.EventLog.dll:FileInfo) [Remove-Item], Arg 
   umentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.DirectoryServices.dll: Access to the path 
is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.DirectoryServices.dll:FileInfo) [Remove-Item], Argume 
   ntException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.Formats.Asn1.dll: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.Formats.Asn1.dll:FileInfo) [Remove-Item], ArgumentExc 
   eption
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.IdentityModel.Tokens.Jwt.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.IdentityModel.Tokens.Jwt.dll:FileInfo) [Remove-Item], 
    ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.IO.Packaging.dll: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.IO.Packaging.dll:FileInfo) [Remove-Item], ArgumentExc 
   eption
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.Management.dll: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.Management.dll:FileInfo) [Remove-Item], ArgumentExcep 
   tion
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.Security.Cryptography.Pkcs.dll: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.Security.Cryptography.Pkcs.dll:FileInfo) [Remove-Item 
   ], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.Security.Cryptography.ProtectedData.dll: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.Security...otectedData.dll:FileInfo) [Remove-Item], A 
   rgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.Security.Permissions.dll: Access to the 
path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.Security.Permissions.dll:FileInfo) [Remove-Item], Arg 
   umentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\System.Windows.Extensions.dll: Access to the path 
is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (System.Windows.Extensions.dll:FileInfo) [Remove-Item], Argum 
   entException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\TextCopy.dll: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (TextCopy.dll:FileInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core\TimeZoneConverter.dll: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (TimeZoneConverter.dll:FileInfo) [Remove-Item], ArgumentExcep 
   tion
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Core: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Core:DirectoryInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Framework\PnP.PowerShell.dll: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.PowerShell.dll:FileInfo) [Remove-Item], ArgumentExceptio 
   n
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\Framework: 
Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (Framework:DirectoryInfo) [Remove-Item], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\PnP.PowerShell-Help.xml: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.PowerShell-Help.xml:FileInfo) [Remove-Item], ArgumentExc 
   eption
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\PnP.PowerShell.Format.ps1xml: Access to the path is 
denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.PowerShell.Format.ps1xml:FileInfo) [Remove-Item], Argume 
   ntException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\PnP.PowerShell.psd1: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PnP.PowerShell.psd1:FileInfo) [Remove-Item], ArgumentExcepti 
   on
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program 
Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0\PSGetModuleInfo.xml: Access to the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (PSGetModuleInfo.xml:FileInfo) [Remove-Item], ArgumentExcepti 
   on
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
Remove-Item : Cannot remove item C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0: Access to 
the path is denied.
At line:1 char:1
+ Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShel ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (C:\Program File...owerShell\3.1.0:DirectoryInfo) [Remove-Ite 
   m], ArgumentException
    + FullyQualifiedErrorId : RemoveFileSystemItemArgumentError,Microsoft.PowerShell.Commands.RemoveItemComm 
   and
