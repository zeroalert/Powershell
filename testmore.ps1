<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.168
	 Created on:   	10/29/2019 11:59 AM
	 Created by:   Luke Barlow
	 Organization: 	Wings Financial Credit Union
	 Filename:    	Sharepoint_OnCall_Change
	 Updated:      	2026-02-10 - Migrated to PnP.PowerShell with cert-based app-only auth
	 Updated:      	2026-02-10 - PS7 prerequisites + hardened module checks + AD + env var fixes
	 Updated:      	2026-02-10 - Refactored 8 duplicate Set-* functions into single
	                              Set-OnCallRotation with config table + null guards
	===========================================================================
	.DESCRIPTION
		Script used to sync the on call sharepoint list to the AD user group
		for rotation of the On Call List.
#>

[CmdletBinding()]
param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[ValidateNotNullOrEmpty()]
	[string]$LogLocation,

	[Parameter(Mandatory = $true)]
	[string]$PfxPassword
)

# ---------------------------
# Prereqs / Guards
# ---------------------------
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($PSVersionTable.PSVersion.Major -lt 7 -or
	($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion -lt [version]'7.4.6'))
{
	throw "This script must be run in PowerShell 7.4.6+ (pwsh). Current: $($PSVersionTable.PSVersion)"
}

if (-not (Test-Path -LiteralPath $LogLocation)) {
	New-Item -ItemType Directory -Path $LogLocation -Force | Out-Null
}

# ---------------------------
# Logging
# ---------------------------
$Date = (Get-Date -Format 'MMddyyHHmm')
$LogFileName = "Sharepoint_OnCall_$Date.log"

Write-Host "Log Started"
Start-Transcript -Path (Join-Path $LogLocation $LogFileName) -Append -Force -Verbose

try {
	# ---------------------------
	# Config
	# ---------------------------
	$SiteURL       = "https://wingsfinancialcu.sharepoint.com/sites/dr"
	$ListName      = "I.S. Emergency Contacts"
	$mailsmtp      = "mail.wingsfinancial.local"

	# App-only auth
	$ClientId         = "8fc81a03-df76-4090-adb1-28bd7d99d631"
	$TenantDomain     = "wingsfinancialcu.onmicrosoft.com"
	$CertPath         = "E:\Master_Files\PnP-OnCall-Automation.pfx"
	$CertPassword     = ConvertTo-SecureString $PfxPassword -AsPlainText -Force

	if (-not (Test-Path -LiteralPath $CertPath)) {
		throw "PFX not found at: $CertPath"
	}

	$ListDataCollection = @()

	# ---------------------------
	# Modules
	# ---------------------------
	try {
		Import-Module ActiveDirectory -ErrorAction Stop
	} catch {
		throw "ActiveDirectory module not available. Install RSAT Active Directory tools. Error: $($_.Exception.Message)"
	}

	if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
		Write-Host "PnP.PowerShell not found. Attempting install (CurrentUser)..."
		try {
			Install-Module PnP.PowerShell -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
		} catch {
			throw "Unable to install PnP.PowerShell. Error: $($_.Exception.Message)"
		}
	}

	Write-Host "Importing Module"
	Import-Module PnP.PowerShell -Force -WarningAction Ignore

	# ---------------------------
	# Rotation config table — replaces 8 separate functions
	# ---------------------------
	$RotationConfigs = @(
		@{
			Label           = "System Engineer"
			PrimaryEmail    = "Primary On Call Sys Engineer"
			PrimarySMS      = "Primary On Call Sys Engineer SMS"
			SecondaryEmail  = "Secondary On Call Sys Engineer"
			SecondarySMS    = "Secondary On Call Sys Engineer SMS"
			MailTo          = "DatacenterServices@wingsfinancial.com"
			Team            = "System Engineers"
			JobTitle        = "System Engineer*"
		}
		@{
			Label           = "DBA"
			PrimaryEmail    = "Primary On Call DBA"
			PrimarySMS      = "Primary On Call DBA SMS"
			SecondaryEmail  = "Secondary On Call DBA"
			SecondarySMS    = "Secondary On Call DBA SMS"
			MailTo          = "DatacenterServices@wingsfinancial.com"
			Team            = "Database Administrators"
			JobTitle        = "*database*"
		}
		@{
			Label           = "Lending ASA"
			PrimaryEmail    = "Primary On Call Lending ASA"
			PrimarySMS      = "Primary On Call Lending ASA SMS"
			SecondaryEmail  = "Secondary On Call Lending ASA"
			SecondarySMS    = "Secondary On Call Lending ASA SMS"
			MailTo          = "appsupport@wingsfinancial.com"
			Team            = "ASA Team"
			JobTitle        = "*Lending*"
		}
		@{
			Label           = "Digital ASA"
			PrimaryEmail    = "Primary On Call Digital ASA"
			PrimarySMS      = "Primary On Call Digital ASA SMS"
			SecondaryEmail  = "Secondary On Call Digital ASA"
			SecondarySMS    = "Secondary On Call Digital ASA SMS"
			MailTo          = "appsupport@wingsfinancial.com"
			Team            = "ASA Team"
			JobTitle        = "*Digital*"
		}
		@{
			Label           = "Retail ASA"
			PrimaryEmail    = "Primary On Call Retail ASA"
			PrimarySMS      = "Primary On Call Retail ASA SMS"
			SecondaryEmail  = "Secondary On Call Retail ASA"
			SecondarySMS    = "Secondary On Call Retail ASA SMS"
			MailTo          = "appsupport@wingsfinancial.com"
			Team            = "ASA Team"
			JobTitle        = "*Retail*"
		}
		@{
			Label           = "BackOffice ASA"
			PrimaryEmail    = "Primary On Call BackOffice ASA"
			PrimarySMS      = "Primary On Call BackOffice ASA SMS"
			SecondaryEmail  = "Secondary On Call BackOffice ASA"
			SecondarySMS    = "Secondary On Call BackOffice ASA SMS"
			MailTo          = "appsupport@wingsfinancial.com"
			Team            = "ASA Team"
			JobTitle        = "*BackOffice*"
		}
		@{
			Label           = "Network Engineer"
			PrimaryEmail    = "Primary On Call Network Engineer"
			PrimarySMS      = "Primary On Call Network Engineer SMS"
			SecondaryEmail  = "Secondary On Call Network Engineer"
			SecondarySMS    = "Secondary On Call Network Engineer SMS"
			MailTo          = "NTO@wingsfinancial.com"
			Team            = "Network Engineers"
			JobTitle        = "Network Eng*"
		}
		@{
			Label           = "Telecom Administrator"
			PrimaryEmail    = "Primary On Call Telecom Administrator"
			PrimarySMS      = "Primary On Call Telecom Administrator SMS"
			SecondaryEmail  = "Secondary On Call Telecom Administrator"
			SecondarySMS    = "Secondary On Call Telecom Administrator SMS"
			MailTo          = "NTO@wingsfinancial.com"
			Team            = "Telecom Administrators"
			JobTitle        = "Telecommunications Systems Admin*"
		}
	)

	# ---------------------------
	# Email helper
	# ---------------------------
	function Send-OnCallEmail {
		param (
			[string]$MailTo,
			[string]$Team,
			[string]$EmailGroup,
			[string]$EmailGroupSMS,
			[string]$OldName,
			[string]$NewName,
			[string]$OldNameSMS,
			[string]$NewNameSMS
		)

		$mailfrom = "Oncall@wingsfinancial.com"
		$mailsub  = "Oncall Group Membership has Changed"
		$Emailbody = @"
<html>
<style>body { text-align: left }</style>
<p>Hello $Team,</p>
<p>The $EmailGroup has changed from $OldName to $NewName.</p>
<p>The $EmailGroupSMS has changed from $OldNameSMS to $NewNameSMS.</p>
<p>Thank you,</p>
</body>
"@

		$base = $env:SYSTEM_DEFAULTWORKINGDIRECTORY
		if ([string]::IsNullOrWhiteSpace($base)) { $base = $PSScriptRoot }

		$signaturePath = Join-Path $base "HelpDeskEmailFiles\HelpDesk.htm"
		if (Test-Path -LiteralPath $signaturePath) {
			$Emailbody += Get-Content $signaturePath -Raw
		}

		$att1 = Join-Path $base "HelpDeskEmailFiles\logo1.png"
		$att2 = Join-Path $base "HelpDeskEmailFiles\logo2.png"
		$attachments = @()
		if (Test-Path -LiteralPath $att1) { $attachments += $att1 }
		if (Test-Path -LiteralPath $att2) { $attachments += $att2 }

		Send-MailMessage -From $mailfrom -To $MailTo -Body $Emailbody -BodyAsHtml `
			-Subject $mailsub -SmtpServer $mailsmtp -Attachments $attachments
	}

	# ---------------------------
	# Generic rotation function (replaces Set-SystemEng, Set-DBA, etc.)
	# ---------------------------
	function Set-OnCallRotation {
		param (
			[string]$EmailGroup,
			[string]$SMSGroup,
			[string]$MailTo,
			[string]$Team,
			[string]$JobTitle,
			[string]$Label,
			[ValidateSet("Primary","Secondary")]
			[string]$Role,
			[array]$ListData
		)

		foreach ($row in $ListData) {

			# Skip rows that don't match this rotation's job title
			if ($row.JobTitle -notlike $JobTitle) { continue }

			# Only process the row that matches the role we're updating
			if ($Role -eq "Primary"   -and $row.On_x0020_Call      -notlike "yes") { continue }
			if ($Role -eq "Secondary" -and $row.On_x002d_CallBackup -notlike "yes") { continue }

			$oncall        = $row.Title
			$targetEmail   = $EmailGroup
			$targetSMS     = $SMSGroup
			$roleLabel     = $Role

			Write-Host "Processing $roleLabel $Label : $oncall"

			# ── Get OLD email group member (null-safe) ──
			$oldMember     = Get-ADGroupMember -Identity $targetEmail -ErrorAction SilentlyContinue
			$oldMemberName = if ($oldMember) { $oldMember.Name } else { $null }
			if (-not $oldMember) {
				Write-Host "  Email group '$targetEmail' has no current members"
			}

			# ── Get OLD SMS contact (null-safe) ──
			$smsDN         = (Get-ADGroup $targetSMS).DistinguishedName
			$oldSmsContact = Get-ADObject -Filter { (objectClass -eq "contact") -and (MemberOf -like $smsDN) } -Properties givenName, DistinguishedName -ErrorAction SilentlyContinue
			$oldSmsName    = if ($oldSmsContact) { $oldSmsContact.givenName } else { $null }
			$oldSmsDN      = if ($oldSmsContact) { $oldSmsContact.DistinguishedName } else { $null }
			if (-not $oldSmsContact) {
				Write-Host "  SMS group '$targetSMS' has no current contacts"
			}

			Write-Host "  Current email member : $oldMemberName"
			Write-Host "  Current SMS contact  : $oldSmsName"

			# ── Remove old members (only if they exist) ──
			if ($oldMember) {
				Remove-ADGroupMember -Identity $targetEmail -Members $oldMember -Confirm:$false -Verbose
			}
			if ($oldSmsDN) {
				Get-ADGroup $smsDN | Set-ADObject -Remove @{ 'member' = $oldSmsDN }
			}

			# ── Add new email member ──
			$newUser = Get-ADUser -Filter { (Name -eq $oncall) -and (EmailAddress -like "*@wingsfinancial.com") } -Properties * -ErrorAction SilentlyContinue
			if ($newUser) {
				Add-ADPrincipalGroupMembership -Identity $newUser -MemberOf $targetEmail -Verbose
			} else {
				Write-Warning "AD user not found for name '$oncall' — skipping email group add"
			}

			# ── Add new SMS contact ──
			$searchPattern  = "*$oncall*"
			$newSmsContact  = Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $searchPattern) } -ErrorAction SilentlyContinue
			if ($newSmsContact) {
				Set-ADGroup -Identity $targetSMS -Add @{ 'member' = "$($newSmsContact.DistinguishedName)" } -Verbose
			} else {
				Write-Warning "SMS contact not found for pattern '$searchPattern' — skipping SMS group add"
			}

			# ── Read back new members for logging / comparison ──
			$newMember     = Get-ADGroupMember -Identity $targetEmail -ErrorAction SilentlyContinue
			$newMemberName = if ($newMember) { $newMember.Name } else { $null }

			$newSmsResult  = Get-ADObject -Filter { (objectClass -eq "contact") -and (MemberOf -like $smsDN) } -Properties givenName -ErrorAction SilentlyContinue
			$newSmsName    = if ($newSmsResult) { $newSmsResult.givenName } else { $null }

			Write-Host "  New email member     : $newMemberName"
			Write-Host "  New SMS contact      : $newSmsName"

			# ── Send notification if membership changed ──
			if ("$newMember" -ne "$oldMember") {
				Write-Host "  Membership changed — sending email"
				Send-OnCallEmail `
					-MailTo       $MailTo `
					-Team         $Team `
					-EmailGroup   $targetEmail `
					-EmailGroupSMS $targetSMS `
					-OldName      $oldMemberName `
					-NewName      $newMemberName `
					-OldNameSMS   $oldSmsName `
					-NewNameSMS   $newSmsName
			} else {
				Write-Host "  No changes needed for $targetEmail"
			}
		}
	}

	# ---------------------------
	# Connect to SharePoint
	# ---------------------------
	Write-Host "Connecting to SharePoint (app-only cert)"
	Connect-PnPOnline -Url $SiteURL `
		-ClientId $ClientId `
		-Tenant $TenantDomain `
		-CertificatePath $CertPath `
		-CertificatePassword $CertPassword

	# ---------------------------
	# Read SharePoint list
	# ---------------------------
	$ListItems = Get-PnPListItem -List $ListName

	$ListItems | ForEach-Object {
		$ListItem = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsText
		$ListRow  = New-Object PSObject

		foreach ($FieldName in @("Title", "JobTitle", "On_x0020_Call", "On_x002d_CallBackup")) {
			$ListRow | Add-Member -MemberType NoteProperty -Name $FieldName -Value $ListItem[$FieldName]
		}

		if ($ListRow.On_x0020_Call -like "yes" -or $ListRow.On_x002d_CallBackup -like "yes") {
			$ListDataCollection += $ListRow
		}
	}

	# ---------------------------
	# Run all rotations from config table
	# ---------------------------
	foreach ($cfg in $RotationConfigs) {
		Write-Host "`n===== Performing $($cfg.Label) rotation ====="

		try {
			# Primary
			Set-OnCallRotation `
				-EmailGroup $cfg.PrimaryEmail `
				-SMSGroup   $cfg.PrimarySMS `
				-MailTo     $cfg.MailTo `
				-Team       $cfg.Team `
				-JobTitle   $cfg.JobTitle `
				-Label      $cfg.Label `
				-Role       "Primary" `
				-ListData   $ListDataCollection

			# Secondary
			Set-OnCallRotation `
				-EmailGroup $cfg.SecondaryEmail `
				-SMSGroup   $cfg.SecondarySMS `
				-MailTo     $cfg.MailTo `
				-Team       $cfg.Team `
				-JobTitle   $cfg.JobTitle `
				-Label      $cfg.Label `
				-Role       "Secondary" `
				-ListData   $ListDataCollection
		}
		catch {
			Write-Warning "Failed processing $($cfg.Label) rotation: $($_.Exception.Message)"
			continue
		}
	}

	Write-Host "`nComplete — Exiting Now"
}
finally {
	Stop-Transcript | Out-Null
}

exit
