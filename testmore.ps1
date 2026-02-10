<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.168
	 Created on:   	10/29/2019 11:59 AM
	 Created by:   Luke Barlow
	 Organization: 	Wings Financial Credit Union
	 Filename:    	Sharepoint_OnCall_Change
	 Updated:      	2026-02-10 - Migrated to PnP.PowerShell with cert-based app-only auth
     Updated:      	2026-02-10 - PS7 prerequisites + hardened module checks + Get-ADGroupMember .Name fix
     Updated:       2026-02-10 - FIX: SMS contact givenName -> Name + safe DN removal (0/1/many)
	===========================================================================

	.DESCRIPTION
		Script used to sync the on call sharepoint list to the AD user group for rotation of the on Call List. 
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

# Your installed PnP.PowerShell requires PS 7.4.6+ (based on your error)
if ($PSVersionTable.PSVersion.Major -lt 7 -or
	($PSVersionTable.PSVersion.Major -eq 7 -and $PSVersionTable.PSVersion -lt [version]'7.4.6'))
{
	throw "Run this in PowerShell 7.4.6+ (pwsh). Current: $($PSVersionTable.PSVersion)"
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
	$SiteURL  = "https://wingsfinancialcu.sharepoint.com/sites/dr"
	$ListName = "I.S. Emergency Contacts"
	$mailsmtp = "mail.wingsfinancial.local"

	# App-only auth config
	$ClientId     = "8fc81a03-df76-4090-adb1-28bd7d99d631"
	$TenantDomain = "wingsfinancialcu.onmicrosoft.com"
	$CertPath     = "E:\Master_Files\PnP-OnCall-Automation.pfx"

	$CertPassword = ConvertTo-SecureString $PfxPassword -AsPlainText -Force

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
		throw "ActiveDirectory module missing. Install RSAT AD tools. Error: $($_.Exception.Message)"
	}

	if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
		Write-Host "PnP.PowerShell not found. Attempting install (CurrentUser)..."
		Install-Module PnP.PowerShell -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
	}

	Write-Host "Importing Module"
	Import-Module PnP.PowerShell -Force -WarningAction Ignore

	# ---------------------------
	# FIX #1: Safe group member name getter (prevents: "property 'Name' cannot be found")
	# ---------------------------
	function Get-GroupMemberNames {
		param([Parameter(Mandatory=$true)][string]$GroupName)

		$members = @(Get-ADGroupMember -Identity $GroupName -ErrorAction SilentlyContinue)

		$names = @($members | ForEach-Object {
			if ($null -ne $_ -and $_.PSObject.Properties.Match('Name').Count -gt 0) { $_.Name }
		} | Where-Object { $_ })

		return ($names -join ", ")
	}

	# ---------------------------
	# FIX #2: Keep your original "-Verbos" typo from breaking / causing duplicate -Verbose issues
	# ---------------------------
	$script:__RealAddADPrincipalGroupMembership = (Get-Command Add-ADPrincipalGroupMembership -CommandType Cmdlet)
	function Add-ADPrincipalGroupMembership {
		[CmdletBinding()]
		param(
			[Parameter(ValueFromPipeline=$true)]
			$Identity,

			[Parameter(Mandatory=$true)]
			[string[]]$MemberOf,

			[switch]$Verbose,
			[switch]$Verbos
		)
		process {
			$invokeParams = @{ MemberOf = $MemberOf }
			if ($null -ne $Identity) { $invokeParams.Identity = $Identity }
			if ($Verbose -or $Verbos) { $invokeParams.Verbose = $true }  # ONLY ONCE
			& $script:__RealAddADPrincipalGroupMembership @invokeParams
		}
	}

	# ---------------------------
	# Email
	# ---------------------------
	function Send-Email {
		$mailfrom = "Oncall@wingsfinancial.com"
		$mailsub  = "Oncall Group Membership has Changed"

		$Emailbody = @"
<html>
<style>body { text-align: left }</style>
<p>Hello $Team,</p>
<p>The $EmailGroup has changed from $EmailNameOld to $EmailNameNew.</p>
<p>The $EmailGroupSMS has changed from $EmailNameOldSMS to $EmailNameNewSMS.</p>
<p>Thank you,</p>
</body>
"@

		$base = $env:SYSTEM_DEFAULTWORKINGDIRECTORY
		if ([string]::IsNullOrWhiteSpace($base)) { $base = $PSScriptRoot }

		$signaturePath = Join-Path $base "HelpDeskEmailFiles\HelpDesk.htm"
		if (Test-Path -LiteralPath $signaturePath) {
			$Emailbody += (Get-Content $signaturePath -Raw)
		}

		$attachments = @()
		$att1 = Join-Path $base "HelpDeskEmailFiles\logo1.png"
		$att2 = Join-Path $base "HelpDeskEmailFiles\logo2.png"
		if (Test-Path -LiteralPath $att1) { $attachments += $att1 }
		if (Test-Path -LiteralPath $att2) { $attachments += $att2 }

		Send-MailMessage -From $mailfrom -To $mailto -Body $EmailBody -BodyAsHtml -Subject $mailsub -SmtpServer $mailsmtp -Attachments $attachments
	}

	Write-Host "Running Function Sync"

	# ---------------------------
	# Shared AD update helper
	# ---------------------------
	function Update-OnCallGroups {
		param(
			[Parameter(Mandatory=$true)][string]$OnCallName,
			[Parameter(Mandatory=$true)][string]$PrimaryGroup,
			[Parameter(Mandatory=$true)][string]$PrimaryGroupSMS,
			[Parameter(Mandatory=$true)][string]$MailTo,
			[Parameter(Mandatory=$true)][string]$TeamName
		)

		$script:mailto = $MailTo
		$script:Team   = $TeamName

		# Old members (safe)
		$oldEmailNames = Get-GroupMemberNames $PrimaryGroup

		# --- FIX: SMS contact lookup SAFE (no givenName) ---
		$GroupCNSMS = (Get-ADGroup $PrimaryGroupSMS).DistinguishedName

		$oldSmsObjs = @(
			Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } `
				-Properties distinguishedName,name `
				-ErrorAction SilentlyContinue
		)

		$OldOnCallSMSMemberDN = @($oldSmsObjs | Select-Object -ExpandProperty DistinguishedName -ErrorAction SilentlyContinue)
		$oldSmsNames = (@($oldSmsObjs | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue) -join ", ")

		Write-Host "Current $PrimaryGroup has been identified as $oldEmailNames"
		Write-Host "Current $PrimaryGroupSMS has been identified as $oldSmsNames"

		# Remove old email members (if any)
		$oldEmailMembers = @(Get-ADGroupMember -Identity $PrimaryGroup -ErrorAction SilentlyContinue)
		if ($oldEmailMembers.Count -gt 0) {
			Remove-ADGroupMember -Identity $PrimaryGroup -Members $oldEmailMembers -Confirm:$false -Verbose
		}

		# --- FIX: Remove old SMS contact member(s) safely ---
		if ($OldOnCallSMSMemberDN.Count -gt 0) {
			foreach ($dn in $OldOnCallSMSMemberDN) {
				if ($dn) { Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $dn } }
			}
		}

		# Add new email member
		Get-ADUser -Filter { (name -eq $OnCallName) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose |
			Add-ADPrincipalGroupMembership -MemberOf $PrimaryGroup -Verbos

		# Add new SMS member
		$BetterToSearch = "*$OnCallName*"
		$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) } -ErrorAction SilentlyContinue)
		if ($TextUserDN) {
			Set-ADGroup -Identity $PrimaryGroupSMS -Add @{ 'member' = "$TextUserDN" } -Verbose
		}

		# New members (safe)
		$newEmailNames = Get-GroupMemberNames $PrimaryGroup

		# --- FIX: new SMS names SAFE (no givenName) ---
		$newSmsObjs = @(
			Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } `
				-Properties name `
				-ErrorAction SilentlyContinue
		)
		$newSmsNames = (@($newSmsObjs | Select-Object -ExpandProperty Name -ErrorAction SilentlyContinue) -join ", ")

		Write-Host "Sharepoint for $PrimaryGroup has been identified as $newEmailNames"
		Write-Host "Sharepoint for $PrimaryGroupSMS has been identified as $newSmsNames"

		# Email notification if changed
		if ("$newEmailNames" -ne "$oldEmailNames") {
			Write-Host "Sending out Email Since $newEmailNames does not equal $oldEmailNames"
			$script:EmailNameOld    = $oldEmailNames
			$script:EmailNameNew    = $newEmailNames
			$script:EmailGroup      = $PrimaryGroup
			$script:EmailNameOldSMS = $oldSmsNames
			$script:EmailNameNewSMS = $newSmsNames
			$script:EmailGroupSMS   = $PrimaryGroupSMS
			Send-Email
		} else {
			Write-Host "No changes needed for $PrimaryGroup"
		}
	}

	# ---------------------------
	# Your Set-* functions (unchanged behavior)
	# ---------------------------

	function Set-SystemEng {
		$JobTitle = "System Engineer*"
		foreach ($syseng in $ListDataCollection) {
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Primary On Call Sys Engineer" `
					-PrimaryGroupSMS "Primary On Call Sys Engineer SMS" `
					-MailTo "DatacenterServices@wingsfinancial.com" `
					-TeamName "System Engineers"
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Secondary On Call Sys Engineer" `
					-PrimaryGroupSMS "Secondary On Call Sys Engineer SMS" `
					-MailTo "DatacenterServices@wingsfinancial.com" `
					-TeamName "System Engineers"
			}
		}
	}

	function Set-DBA {
		$JobTitle = "*database*"
		foreach ($syseng in $ListDataCollection) {
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Primary On Call DBA" `
					-PrimaryGroupSMS "Primary On Call DBA SMS" `
					-MailTo "DatacenterServices@wingsfinancial.com" `
					-TeamName "Database Administrators"
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Secondary On Call DBA" `
					-PrimaryGroupSMS "Secondary On Call DBA SMS" `
					-MailTo "DatacenterServices@wingsfinancial.com" `
					-TeamName "Database Administrators"
			}
		}
	}

	function Set-Lending {
		$JobTitle = "*Lending*"
		foreach ($syseng in $ListDataCollection) {
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Primary On Call Lending ASA" `
					-PrimaryGroupSMS "Primary On Call Lending ASA SMS" `
					-MailTo "appsupport@wingsfinancial.com" `
					-TeamName "ASA Team"
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Secondary On Call Lending ASA" `
					-PrimaryGroupSMS "Secondary On Call Lending ASA SMS" `
					-MailTo "appsupport@wingsfinancial.com" `
					-TeamName "ASA Team"
			}
		}
	}

	function Set-Digital {
		$JobTitle = "*Digital*"
		foreach ($syseng in $ListDataCollection) {
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Primary On Call Digital ASA" `
					-PrimaryGroupSMS "Primary On Call Digital ASA SMS" `
					-MailTo "appsupport@wingsfinancial.com" `
					-TeamName "ASA Team"
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Secondary On Call Digital ASA" `
					-PrimaryGroupSMS "Secondary On Call Digital ASA SMS" `
					-MailTo "appsupport@wingsfinancial.com" `
					-TeamName "ASA Team"
			}
		}
	}

	function Set-BackOfficeASA {
		$JobTitle = "*BackOffice*"
		foreach ($syseng in $ListDataCollection) {
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Primary On Call BackOffice ASA" `
					-PrimaryGroupSMS "Primary On Call BackOffice ASA SMS" `
					-MailTo "appsupport@wingsfinancial.com" `
					-TeamName "ASA Team"
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Secondary On Call BackOffice ASA" `
					-PrimaryGroupSMS "Secondary On Call BackOffice ASA SMS" `
					-MailTo "appsupport@wingsfinancial.com" `
					-TeamName "ASA Team"
			}
		}
	}

	function Set-Retail {
		$JobTitle = "*Retail*"
		foreach ($syseng in $ListDataCollection) {
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Primary On Call Retail ASA" `
					-PrimaryGroupSMS "Primary On Call Retail ASA SMS" `
					-MailTo "appsupport@wingsfinancial.com" `
					-TeamName "ASA Team"
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Secondary On Call Retail ASA" `
					-PrimaryGroupSMS "Secondary On Call Retail ASA SMS" `
					-MailTo "appsupport@wingsfinancial.com" `
					-TeamName "ASA Team"
			}
		}
	}

	function Set-Net {
		$JobTitle = "Network Eng*"
		foreach ($syseng in $ListDataCollection) {
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Primary On Call Network Engineer" `
					-PrimaryGroupSMS "Primary On Call Network Engineer SMS" `
					-MailTo "NTO@wingsfinancial.com" `
					-TeamName "Network Engineers"
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Secondary On Call Network Engineer" `
					-PrimaryGroupSMS "Secondary On Call Network Engineer SMS" `
					-MailTo "NTO@wingsfinancial.com" `
					-TeamName "Network Engineers"
			}
		}
	}

	function Set-TeleAdm {
		$JobTitle = "Telecommunications Systems Admin*"
		foreach ($syseng in $ListDataCollection) {
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Primary On Call Telecom Administrator" `
					-PrimaryGroupSMS "Primary On Call Telecom Administrator SMS" `
					-MailTo "NTO@wingsfinancial.com" `
					-TeamName "Telecom Administrators"
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle) {
				Update-OnCallGroups -OnCallName $syseng.Title `
					-PrimaryGroup "Secondary On Call Telecom Administrator" `
					-PrimaryGroupSMS "Secondary On Call Telecom Administrator SMS" `
					-MailTo "NTO@wingsfinancial.com" `
					-TeamName "Telecom Administrators"
			}
		}
	}

	# ---------------------------
	# Connect to SharePoint (PnP.PowerShell, app-only cert)
	# ---------------------------
	Write-Host "Connecting to SharePoint (app-only cert)"
	Connect-PnPOnline -Url $SiteURL `
		-ClientId $ClientId `
		-Tenant $TenantDomain `
		-CertificatePath $CertPath `
		-CertificatePassword $CertPassword

	# ---------------------------
	# SharePoint read (no Get-PnPField)
	# ---------------------------
	$Counter = 0
	$ListItems = Get-PnPListItem -List $ListName -PageSize 2000

	foreach ($item in $ListItems) {
		$ListItem = Get-PnPProperty -ClientObject $item -Property FieldValuesAsText

		$ListRow = [pscustomobject]@{
			Title               = $ListItem["Title"]
			JobTitle            = $ListItem["JobTitle"]
			On_x0020_Call       = $ListItem["On_x0020_Call"]
			On_x002d_CallBackup = $ListItem["On_x002d_CallBackup"]
		}

		if ($ListRow.On_x0020_Call -like "yes" -or $ListRow.On_x002d_CallBackup -like "yes") {
			$ListDataCollection += $ListRow
		}
		$Counter++
	}

	# ---------------------------
	# Run
	# ---------------------------
	Write-Host "Performing System Engineer Function"
	Set-SystemEng

	Write-Host "Performing DBA Function"
	Set-DBA

	Write-Host "Performing ASA Lending Function"
	Set-Lending

	Write-Host "Performing ASA Digital Function"
	Set-Digital

	Write-Host "Performing ASA BackOffice Function"
	Set-BackOfficeASA

	Write-Host "Performing ASA Retail Function"
	Set-Retail

	Write-Host "Performing Network Engineer Function"
	Set-Net

	Write-Host "Performing TeleAdm Function"
	Set-TeleAdm

	Write-Host "Complete Exiting Now"
}
finally {
	Stop-Transcript | Out-Null
}

exit
