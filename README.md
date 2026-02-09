━━━ Step 2: Generating self-signed certificate ━━━
Enter a password to protect the PFX certificate: **********
  ✓ Certificate created: 65E57CA5D8E2CA293A92E91190A02E4A06A1512B
  → Valid until: 2028-02-09
  ✓ PFX exported to: C:\Users\3382\SharePoint%20Utilities\PnP-OnCall-Automation.pfx
  ✓ CER exported to: C:\Users\3382\SharePoint%20Utilities\PnP-OnCall-Automation.cer

━━━ Step 3: Connecting to Microsoft Graph (device code sign-in) ━━━
  → A device code will be displayed — open a browser, go to https://microsoft.com/devicelogin, and enter the code.
  → Sign in with a Global Admin or Application Administrator account.
Connect-MgGraph: C:\Users\3382\SharePoint%20Utilities\Setup-PnPAppRegistration.ps1:154
Line |
 154 |  Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignme …
     |  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | DeviceCodeCredential authentication failed: Could not load type
     | 'Microsoft.Identity.Client.IMsalSFHttpClientFactory' from assembly 'Microsoft.Identity.Client, Version=4.70.2.0,
     | Culture=neutral, PublicKeyToken=0a613f4dd989e8ae'.
PS C:\Users\3382\SharePoint%20Utilities>
