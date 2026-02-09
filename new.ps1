<#
    .SYNOPSIS
        Creates an Entra ID App Registration with a self-signed certificate for 
        PnP PowerShell app-only authentication to SharePoint Online.

    .DESCRIPTION
        Uses Azure CLI (az) instead of Microsoft.Graph module to avoid MSAL conflicts.
        
        This script:
        1. Verifies Azure CLI is installed and logged in
        2. Generates a self-signed certificate (if not already present)
        3. Creates an Entra ID App Registration
        4. Uploads the certificate to the app registration
        5. Adds SharePoint API permissions
        6. Creates a service principal and grants admin consent
        7. Outputs connection details for the build agent

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
        Prerequisites:
        - Azure CLI installed (https://aka.ms/installazurecli)
        - Logged in as Global Admin or Application Administrator (az login)
        - Do NOT import PnP.PowerShell in this session

    .EXAMPLE
        .\Setup-PnPAppRegistration.ps1 `
            -AppName "PnP-OnCall-Automation" `
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

#region ── Step 1: Verify Azure CLI ──
Write-Step "Step 1: Verifying Azure CLI"

# Check az is installed
try {
    $azVersion = az version 2>$null | ConvertFrom-Json
    Write-Success "Azure CLI installed: $($azVersion.'azure-cli')"
}
catch {
    Write-Error "Azure CLI not found. Install from https://aka.ms/installazurecli"
    exit 1
}

# Check logged in
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Info "Not logged in. Opening browser for authentication..."
    az login --tenant $TenantDomain | Out-Null
    $account = az account show | ConvertFrom-Json
}
Write-Success "Logged in as: $($account.user.name)"
Write-Info "Tenant: $($account.tenantId)"
#endregion

#region ── Step 2: Generate or load certificate ──
Write-Step "Step 2: Certificate"

$pfxPath = Join-Path $CertOutputPath "$AppName.pfx"
$cerPath = Join-Path $CertOutputPath "$AppName.cer"

# Prompt for PFX password if not provided
if (-not $CertPassword) {
    $CertPassword = Read-Host -Prompt "Enter a password for the PFX certificate" -AsSecureString
}

if (Test-Path $pfxPath) {
    Write-Info "Found existing PFX at: $pfxPath — skipping generation."
}
else {
    Write-Info "Generating self-signed certificate using .NET..."

    $rsa = [System.Security.Cryptography.RSA]::Create(2048)
    $certRequest = [System.Security.Cryptography.X509Certificates.CertificateRequest]::new(
        "CN=$AppName",
        $rsa,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256,
        [System.Security.Cryptography.RSASignaturePadding]::Pkcs1
    )
    $certNotAfter = (Get-Date).AddYears($CertValidityYears)
    $generatedCert = $certRequest.CreateSelfSigned(
        [System.DateTimeOffset]::Now,
        [System.DateTimeOffset]::new($certNotAfter)
    )

    # Export PFX
    $pfxBytes = $generatedCert.Export(
        [System.Security.Cryptography.X509Certificates.X509ContentType]::Pfx,
        $CertPassword
    )
    [System.IO.File]::WriteAllBytes($pfxPath, $pfxBytes)
    Write-Success "PFX exported to: $pfxPath"

    # Export CER
    $cerBytes = $generatedCert.Export(
        [System.Security.Cryptography.X509Certificates.X509ContentType]::Cert
    )
    [System.IO.File]::WriteAllBytes($cerPath, $cerBytes)
    Write-Success "CER exported to: $cerPath"
}

# Load PFX to get details
$certObj = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
    $pfxPath,
    $CertPassword,
    [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable
)

$certThumbprint = $certObj.Thumbprint
Write-Success "Certificate thumbprint: $certThumbprint"
Write-Info "Valid until: $($certObj.NotAfter.ToString('yyyy-MM-dd'))"
#endregion

#region ── Step 3: Create App Registration ──
Write-Step "Step 3: Creating Entra ID App Registration"

# Check if app already exists
$existingApp = az ad app list --display-name $AppName --query "[0]" 2>$null | ConvertFrom-Json

if ($existingApp) {
    $appId = $existingApp.appId
    $objectId = $existingApp.id
    Write-Info "App '$AppName' already exists. AppId: $appId"
}
else {
    Write-Info "Creating new app registration..."
    $newApp = az ad app create `
        --display-name $AppName `
        --sign-in-audience AzureADMyOrg | ConvertFrom-Json

    $appId = $newApp.appId
    $objectId = $newApp.id
    Write-Success "App created: $AppName"
    Write-Info "Application (Client) ID: $appId"
}
#endregion

#region ── Step 4: Upload certificate ──
Write-Step "Step 4: Uploading certificate to app registration"

az ad app credential reset `
    --id $appId `
    --cert "@$cerPath" `
    --append | Out-Null

Write-Success "Certificate uploaded to app registration"
#endregion

#region ── Step 5: Add SharePoint API permissions ──
Write-Step "Step 5: Adding SharePoint API permissions"

# SharePoint Online API ID
$sharepointApiId = "00000003-0000-0ff1-ce00-000000000000"

# Sites.FullControl.All (Application) 
$sitesFullControl = "a82116e5-55eb-4c41-a434-62fe8a61c773"

# Sites.ReadWrite.All (Application)
$sitesReadWrite = "fbcd29d2-fcca-4405-aded-518d457caae4"

try {
    az ad app permission add `
        --id $appId `
        --api $sharepointApiId `
        --api-permissions "$sitesFullControl=Role" 2>$null | Out-Null
    Write-Success "Added Sites.FullControl.All"
}
catch {
    Write-Info "Sites.FullControl.All may already be added"
}

try {
    az ad app permission add `
        --id $appId `
        --api $sharepointApiId `
        --api-permissions "$sitesReadWrite=Role" 2>$null | Out-Null
    Write-Success "Added Sites.ReadWrite.All"
}
catch {
    Write-Info "Sites.ReadWrite.All may already be added"
}
#endregion

#region ── Step 6: Create Service Principal + Admin Consent ──
Write-Step "Step 6: Creating Service Principal and granting admin consent"

# Create service principal if it doesn't exist
$existingSP = az ad sp show --id $appId 2>$null | ConvertFrom-Json
if (-not $existingSP) {
    az ad sp create --id $appId | Out-Null
    Write-Success "Service Principal created"
}
else {
    Write-Success "Service Principal already exists"
}

# Grant admin consent
Write-Info "Granting admin consent (may take a moment)..."
Start-Sleep -Seconds 5  # Brief pause for propagation

try {
    az ad app permission admin-consent --id $appId 2>$null | Out-Null
    Write-Success "Admin consent granted"
}
catch {
    Write-Warning "Auto-consent may have failed. Grant manually in Azure Portal:"
    Write-Info "  Portal → Entra ID → App registrations → $AppName → API permissions → Grant admin consent"
}
#endregion

#region ── Step 7: Summary ──
Write-Step "Step 7: Setup Complete"

$summary = @"

╔══════════════════════════════════════════════════════════════╗
║  PnP App-Only Auth Setup Complete                           ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  App Name:        $AppName
║  Client ID:       $appId
║  Tenant:          $TenantDomain
║  Cert Thumbprint: $certThumbprint
║  PFX Location:    $pfxPath
║  Cert Expires:    $($certObj.NotAfter.ToString('yyyy-MM-dd'))
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

  ── Next Steps ──

  1. Copy the PFX to your build agent:
     Copy-Item "$pfxPath" -Destination "\\<agent-hostname>\E$\Master_Files\$AppName.pfx"

  2. Test the connection (in a PnP.PowerShell session):
     Import-Module PnP.PowerShell
     Connect-PnPOnline -Url "$SharePointUrl" ``
         -ClientId "$appId" ``
         -Tenant "$TenantDomain" ``
         -CertificatePath "E:\Master_Files\$AppName.pfx" ``
         -CertificatePassword (ConvertTo-SecureString "YOUR_PFX_PASSWORD" -AsPlainText -Force)

     Get-PnPListItem -List "I.S. Emergency Contacts" -PageSize 5

  3. Update Sharepoint_OnCall.ps1 on the build agent:
     - Replace 'sharepointpnppowershellonline' with 'PnP.PowerShell'
     - Remove the Import-CliXml credential line
     - Replace Connect-PnPOnline with the cert-based version above

"@

Write-Host $summary -ForegroundColor White
#endregion
