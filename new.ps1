<#
    .SYNOPSIS
        Creates an Entra ID App Registration with a self-signed certificate for 
        PnP PowerShell app-only authentication to SharePoint Online.

    .DESCRIPTION
        This script:
        1. Installs/imports required modules (PnP.PowerShell, Microsoft.Graph)
        2. Creates a self-signed certificate (or uses an existing one)
        3. Registers an Entra ID application with SharePoint API permissions
        4. Uploads the certificate to the app registration
        5. Grants admin consent for the API permissions
        6. Exports the PFX to the specified path for use by the build agent
        7. Outputs a connection test command

    .PARAMETER AppName
        Display name for the Entra ID App Registration.

    .PARAMETER CertOutputPath
        Directory to export the PFX certificate file. Defaults to current directory.

    .PARAMETER CertPassword
        Password to protect the PFX file. Will prompt if not provided.

    .PARAMETER CertValidityYears
        How many years the self-signed cert is valid. Default: 2.

    .PARAMETER SharePointUrl
        Your SharePoint site URL for the connection test.

    .PARAMETER TenantDomain
        Your tenant domain (e.g., wingsfinancialcu.onmicrosoft.com).

    .NOTES
        Run this script as a Global Admin or Application Administrator in Entra ID.
        The script requires interactive sign-in for Microsoft Graph and admin consent.

    .EXAMPLE
        .\Setup-PnPAppRegistration.ps1 `
            -AppName "PnP-OnCall-Automation" `
            -CertOutputPath "E:\Master_Files" `
            -SharePointUrl "https://wingsfinancialcu.sharepoint.com/sites/dr" `
            -TenantDomain "wingsfinancialcu.onmicrosoft.com"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$AppName = "PnP-OnCall-Automation",

    [Parameter(Mandatory = $false)]
    [string]$CertOutputPath = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [SecureString]$CertPassword,

    [Parameter(Mandatory = $false)]
    [int]$CertValidityYears = 2,

    [Parameter(Mandatory = $false)]
    [string]$SharePointUrl = "https://wingsfinancialcu.sharepoint.com/sites/dr",

    [Parameter(Mandatory = $false)]
    [string]$TenantDomain = "wingsfinancialcu.onmicrosoft.com"
)

$ErrorActionPreference = "Stop"

#region ── Helpers ──
function Write-Step {
    param([string]$Message)
    Write-Host "`n━━━ $Message ━━━" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "  ✓ $Message" -ForegroundColor Green
}

function Write-Info {
    param([string]$Message)
    Write-Host "  → $Message" -ForegroundColor Yellow
}
#endregion

#region ── Step 1: Prerequisites ──
Write-Step "Step 1: Checking prerequisites"

# PnP.PowerShell
if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
    Write-Info "Installing PnP.PowerShell module..."
    Install-Module -Name PnP.PowerShell -Scope CurrentUser -Force -AllowClobber -Confirm:$false
}
Import-Module PnP.PowerShell -Force
Write-Success "PnP.PowerShell loaded"

# Microsoft.Graph (for app registration + admin consent)
$graphModules = @("Microsoft.Graph.Authentication", "Microsoft.Graph.Applications")
foreach ($mod in $graphModules) {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Info "Installing $mod..."
        Install-Module -Name $mod -Scope CurrentUser -Force -AllowClobber -Confirm:$false
    }
    Import-Module $mod -Force
}
Write-Success "Microsoft.Graph modules loaded"
#endregion

#region ── Step 2: Generate self-signed certificate ──
Write-Step "Step 2: Generating self-signed certificate"

$certSubject = "CN=$AppName"
$certNotAfter = (Get-Date).AddYears($CertValidityYears)

# Prompt for PFX password if not provided
if (-not $CertPassword) {
    $CertPassword = Read-Host -Prompt "Enter a password to protect the PFX certificate" -AsSecureString
}

# Use PnP's certificate cmdlet (works natively in PS7)
$pfxPath = Join-Path $CertOutputPath "$AppName.pfx"
$cerPath = Join-Path $CertOutputPath "$AppName.cer"

$certResult = New-PnPAzureCertificate `
    -CommonName $AppName `
    -OutPfx $pfxPath `
    -OutCert $cerPath `
    -ValidYears $CertValidityYears `
    -CertificatePassword $CertPassword

$certThumbprint = $certResult.Certificate.Thumbprint
$certBase64 = $certResult.Certificate.GetRawCertDataString()
$certNotAfterDate = $certResult.Certificate.NotAfter
$certNotBeforeDate = $certResult.Certificate.NotBefore

Write-Success "Certificate created: $certThumbprint"
Write-Info "Valid until: $($certNotAfterDate.ToString('yyyy-MM-dd'))"
Write-Success "PFX exported to: $pfxPath"
Write-Success "CER exported to: $cerPath"
#endregion

#region ── Step 3: Connect to Microsoft Graph ──
Write-Step "Step 3: Connecting to Microsoft Graph (interactive sign-in)"
Write-Info "Sign in with a Global Admin or Application Administrator account."

Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All" -TenantId $TenantDomain
Write-Success "Connected to Microsoft Graph"
#endregion

#region ── Step 4: Create App Registration ──
Write-Step "Step 4: Creating Entra ID App Registration"

# SharePoint Online API - well-known ID
$sharepointResourceId = "00000003-0000-0ff1-ce00-000000000000"

# Permission: Sites.FullControl.All (application) — covers read/write to all site collections
# Use Sites.ReadWrite.All if you want narrower scope
$permissions = @(
    @{
        # Sites.FullControl.All (Application)
        Id   = "a82116e5-55eb-4c41-a434-62fe8a61c773"
        Type = "Role"
    },
    @{
        # Sites.ReadWrite.All (Application) — fallback / narrower option
        Id   = "fbcd29d2-fcca-4405-aded-518d457caae4"
        Type = "Role"
    }
)

$requiredResourceAccess = @(
    @{
        ResourceAppId  = $sharepointResourceId
        ResourceAccess = $permissions
    }
)

# Check if app already exists
$existingApp = Get-MgApplication -Filter "displayName eq '$AppName'" -ErrorAction SilentlyContinue
if ($existingApp) {
    Write-Info "App '$AppName' already exists (AppId: $($existingApp.AppId)). Updating..."
    $app = $existingApp
    
    # Update certificate
    $keyCredential = @{
        DisplayName = "$AppName Certificate"
        Type        = "AsymmetricX509Cert"
        Usage       = "Verify"
        Key           = [System.Convert]::FromBase64String($certBase64)
        StartDateTime = $certNotBeforeDate.ToUniversalTime()
        EndDateTime   = $certNotAfterDate.ToUniversalTime()
    }
    Update-MgApplication -ApplicationId $app.Id -KeyCredentials @($keyCredential)
    Write-Success "Updated certificate on existing app"
}
else {
    # Create new app
    $appParams = @{
        DisplayName            = $AppName
        SignInAudience         = "AzureADMyOrg"
        RequiredResourceAccess = $requiredResourceAccess
        KeyCredentials         = @(
            @{
                DisplayName   = "$AppName Certificate"
                Type          = "AsymmetricX509Cert"
                Usage         = "Verify"
                Key           = [System.Convert]::FromBase64String($certBase64)
                StartDateTime = $certNotBeforeDate.ToUniversalTime()
                EndDateTime   = $certNotAfterDate.ToUniversalTime()
            }
        )
    }

    $app = New-MgApplication @appParams
    Write-Success "App Registration created: $($app.DisplayName)"
}

Write-Info "Application (Client) ID: $($app.AppId)"
Write-Info "Object ID:               $($app.Id)"
#endregion

#region ── Step 5: Create Service Principal + Grant Admin Consent ──
Write-Step "Step 5: Creating Service Principal and granting admin consent"

# Create service principal if it doesn't exist
$sp = Get-MgServicePrincipal -Filter "appId eq '$($app.AppId)'" -ErrorAction SilentlyContinue
if (-not $sp) {
    $sp = New-MgServicePrincipal -AppId $app.AppId
    Write-Success "Service Principal created"
}
else {
    Write-Success "Service Principal already exists"
}

# Get the SharePoint resource service principal
$sharepointSP = Get-MgServicePrincipal -Filter "appId eq '$sharepointResourceId'"

if ($sharepointSP) {
    foreach ($perm in $permissions) {
        try {
            $existingGrant = Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id |
                Where-Object { $_.AppRoleId -eq $perm.Id }

            if (-not $existingGrant) {
                New-MgServicePrincipalAppRoleAssignment `
                    -ServicePrincipalId $sp.Id `
                    -PrincipalId $sp.Id `
                    -ResourceId $sharepointSP.Id `
                    -AppRoleId $perm.Id | Out-Null
                Write-Success "Admin consent granted for permission: $($perm.Id)"
            }
            else {
                Write-Success "Permission $($perm.Id) already consented"
            }
        }
        catch {
            Write-Warning "Could not grant permission $($perm.Id): $_"
            Write-Info "You may need to grant admin consent manually in the Azure Portal."
        }
    }
}
else {
    Write-Warning "Could not find SharePoint Online service principal. Grant consent manually."
}
#endregion

#region ── Step 6: Summary + Connection Test ──
Write-Step "Step 6: Setup Complete — Summary"

$summary = @"

╔══════════════════════════════════════════════════════════════╗
║  PnP App-Only Auth Setup Complete                           ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  App Name:        $AppName
║  Client ID:       $($app.AppId)
║  Tenant:          $TenantDomain
║  Cert Thumbprint: $certThumbprint
║  PFX Location:    $pfxPath
║  Cert Expires:    $($certNotAfterDate.ToString('yyyy-MM-dd'))
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

  ── Copy the PFX to your build agent ──
  Copy-Item "$pfxPath" -Destination "E:\Master_Files\$AppName.pfx"

  ── Test the connection ──
  Connect-PnPOnline -Url "$SharePointUrl" ``
      -ClientId "$($app.AppId)" ``
      -Tenant "$TenantDomain" ``
      -CertificatePath "E:\Master_Files\$AppName.pfx" ``
      -CertificatePassword (ConvertTo-SecureString "YOUR_PFX_PASSWORD" -AsPlainText -Force)

  Get-PnPListItem -List "I.S. Emergency Contacts" -PageSize 5

  ── Update your Sharepoint_OnCall.ps1 ──
  Replace the Connect-PnPOnline line and remove the Import-CliXml credential line.
  See the companion script update notes for exact changes.

"@

Write-Host $summary -ForegroundColor White

# Disconnect Graph
Disconnect-MgGraph -ErrorAction SilentlyContinue | Out-Null
#endregion

#region ── Step 7: Cleanup local cert store (optional) ──
Write-Step "Step 7: Cleanup"
Write-Info "The certificate was generated by PnP and exported to: $pfxPath"
Write-Info "No local cert store cleanup needed — the cert only exists as PFX/CER files."
#endregion
