  ✓ Microsoft.Graph modules loaded

━━━ Step 2: Generating self-signed certificate ━━━
Enter a password to protect the PFX certificate: **********
Join-Path: C:\Users\3382\SharePoint%20Utilities\Setup-PnPAppRegistration.ps1:121
Line |
 121 |  $pfxPath = Join-Path $CertOutputPath "$AppName.pfx"
     |             ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | Cannot find drive. A drive with the name 'E' does not exist.
PS C:\Users\3382\SharePoint%20Utilities>         .\Setup-PnPAppRegistration.ps1 `
>>             -AppName "PnP-OnCall-Automation" `
>>             -SharePointUrl "https://wingsfinancialcu.sharepoint.com/sites/dr" `
>>             -TenantDomain "wingsfinancialcu.onmicrosoft.com"

━━━ Step 1: Checking prerequisites ━━━
  ✓ PnP.PowerShell loaded
  ✓ Microsoft.Graph modules loaded

━━━ Step 2: Generating self-signed certificate ━━━
Enter a password to protect the PFX certificate: **********
Setup-PnPAppRegistration.ps1: Method invocation failed because [System.String] does not contain a method named 'GetRawCertDataString'.
PS C:\Users\3382\SharePoint%20Utilities>
