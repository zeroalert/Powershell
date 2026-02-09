# Remove all old versions and install matching set
Uninstall-Module Microsoft.Graph.Applications -AllVersions -Force
Uninstall-Module Microsoft.Graph.Authentication -AllVersions -Force
Install-Module Microsoft.Graph.Authentication -Force -Scope CurrentUser
Install-Module Microsoft.Graph.Applications -Force -Scope CurrentUser


PS C:\Users\3382> cd .\SharePoint%20Utilities\
PS C:\Users\3382\SharePoint%20Utilities>         .\Setup-PnPAppRegistration.ps1 `
>>             -AppName "PnP-OnCall-Automation" `
>>             -CertOutputPath "E:\Master_Files" `
>>             -SharePointUrl "https://wingsfinancialcu.sharepoint.com/sites/dr" `
>>             -TenantDomain "wingsfinancialcu.onmicrosoft.com"

━━━ Step 1: Checking prerequisites ━━━
  ✓ PnP.PowerShell loaded
  ✓ Microsoft.Graph modules loaded

━━━ Step 2: Generating self-signed certificate ━━━
Enter a password to protect the PFX certificate: **********
Setup-PnPAppRegistration.ps1: A parameter cannot be found that matches parameter name 'CertStoreLocation'.
PS C:\Users\3382\SharePoint%20Utilities>
