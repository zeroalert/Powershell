<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.168
	 Created on:   	10/29/2019 11:59 AM
	 Created by:   Luke Barlow
	 Organization: 	Wings Financial Credit Union
	 Filename:    	Sharepoint_OnCall_Change
	 Updated:      	2026-02-10 - Migrated to PnP.PowerShell with cert-based app-only auth
     Updated:      	2026-02-10 - PS7 prerequisites + module checks + AD + Verbos shim + PnP list read fix
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

# Your earlier error showed PnP.PowerShell on your box required PS 7.4.6+
if ($PSVersionTable.PSVersion.Major -lt 7 -or $PSVersionTable.PSVersion -lt [version]'7.4.6') {
	throw "This script must be run in PowerShell 7.4.6+ (pwsh). Current: $($PSVersionTable.PSVersion)"
}

# Make sure log folder exists
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
	#Config Parameter for sharepoint list
	$SiteURL = "https://wingsfinancialcu.sharepoint.com/sites/dr"
	$ListName = "I.S. Emergency Contacts"
	$mailsmtp = "mail.wingsfinancial.local"

	# ── App-only auth config ──
	$ClientId = "8fc81a03-df76-4090-adb1-28bd7d99d631"
	$TenantDomain = "wingsfinancialcu.onmicrosoft.com"
	$CertPath = "E:\Master_Files\PnP-OnCall-Automation.pfx"
	$CertPasswordPlain = $PfxPassword
	$CertPassword = ConvertTo-SecureString $CertPasswordPlain -AsPlainText -Force

	if (-not (Test-Path -LiteralPath $CertPath)) {
		throw "PFX not found at: $CertPath"
	}

	$ListDataCollection= @()

	# ---------------------------
	# Modules
	# ---------------------------
	try {
		Import-Module ActiveDirectory -ErrorAction Stop
	} catch {
		throw "ActiveDirectory module not available. Install RSAT Active Directory tools on this machine. Error: $($_.Exception.Message)"
	}

	if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
		Write-Host "PnP.PowerShell not found. Attempting install (CurrentUser)..."
		try {
			# NuGet provider can fail if no internet/proxy; install best-effort.
			try { Install-PackageProvider -Name NuGet -Force -ErrorAction SilentlyContinue | Out-Null } catch {}
			Install-Module PnP.PowerShell -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
		} catch {
			throw "Unable to install PnP.PowerShell. Preinstall it or fix PowerShellGet/nuget/proxy. Error: $($_.Exception.Message)"
		}
	}

	Write-Host "Importing Module"
	Import-Module PnP.PowerShell -Force -WarningAction Ignore

	# ---------------------------
	# FIX: accept your existing typo "-Verbos" WITHOUT breaking -Verbose
	# (removes the 'Verbose defined multiple times' issue)
	# ---------------------------
	$script:__RealAddADPrincipalGroupMembership = Get-Command -Name Add-ADPrincipalGroupMembership -CommandType Cmdlet -ErrorAction Stop
	function Add-ADPrincipalGroupMembership {
		[CmdletBinding(DefaultParameterSetName='Default')]
		param(
			[Parameter(ValueFromPipeline=$true)]
			$Identity,

			[Parameter(Mandatory=$true)]
			[string[]]$MemberOf,

			[switch]$Verbos
		)
		process {
			# If -Verbos was used anywhere, force verbose output for this call
			$oldVP = $VerbosePreference
			if ($Verbos) { $VerbosePreference = 'Continue' }

			$invokeParams = @{ MemberOf = $MemberOf }
			if ($null -ne $Identity) { $invokeParams.Identity = $Identity }

			& $script:__RealAddADPrincipalGroupMembership @invokeParams

			$VerbosePreference = $oldVP
		}
	}

	function Send-Email
	{
		$mailfrom="Oncall@wingsfinancial.com"
		$mailsub= "Oncall Group Membership has Changed"
		$Emailbody = "  
<html>
<style>
body { text-align: left }
</style>
<p>Hello $Team,</p>
<p>The $EmailGroup has changed from $EmailNameOld to $EmailNameNew.</p>
<p>The $EmailGroupSMS has changed from $EmailNameOldSMS to $EmailNameNewSMS.</p>
<p>Thank you,</p>
</body>"

		$base = $env:SYSTEM_DEFAULTWORKINGDIRECTORY
		if ([string]::IsNullOrWhiteSpace($base)) { $base = $PSScriptRoot }

		$signaturePath = Join-Path $base "HelpDeskEmailFiles\HelpDesk.htm"
		if (Test-Path -LiteralPath $signaturePath) {
			$Signature = Get-Content $signaturePath -Raw
			$Emailbody += $Signature
		}

		$att1 = Join-Path $base "HelpDeskEmailFiles\logo1.png"
		$att2 = Join-Path $base "HelpDeskEmailFiles\logo2.png"
		$attachments = @()
		if (Test-Path -LiteralPath $att1) { $attachments += $att1 }
		if (Test-Path -LiteralPath $att2) { $attachments += $att2 }

		Send-MailMessage -From "$mailfrom" -To "$mailto" -Body "$EmailBody" -BodyAsHtml -Subject "$mailsub" -SmtpServer $mailsmtp -Attachments $attachments
	}

	Write-Host "Running Function Sync"

	#Fuction For SysEngineers Distribution list
	function Set-SystemEng
	{
		$oncallgroup = "Primary On Call Sys Engineer"
		$oncallgroupSMS = "Primary On Call Sys Engineer SMS"
		$bkponcallgroup = "Secondary On Call Sys Engineer"
		$bkponcallgroupSMS = "Secondary On Call Sys Engineer SMS"
		
		$mailto = "DatacenterServices@wingsfinancial.com"
		$Team = "System Engineers"
		$JobTitle = "System Engineer*"
		
		ForEach ($syseng in $ListDataCollection)
		{
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				
				$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				
				Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				
				Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
				
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				
				Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
				
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember")
				{
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $oncallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $oncallgroupSMS
					Send-Email
				}
				else { Write-Host "No changes needed for $oncallgroup" }
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
			
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				
				$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				
				Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				
				Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
				
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				
				Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
				
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember")
				{
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $bkponcallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $bkponcallgroupSMS
					Send-Email
				}
				else { Write-Host "No changes needed for $bkponcallgroup" }
			}
		}
	}

	#Fuction For DBA Distribution list
	function Set-DBA
	{
		$oncallgroup = "Primary On Call DBA"
		$oncallgroupSMS = "Primary On Call DBA SMS"
		$bkponcallgroup = "Secondary On Call DBA"
		$bkponcallgroupSMS = "Secondary On Call DBA SMS"
		
		$mailto = "DatacenterServices@wingsfinancial.com"
		$Team = "Database Administrators"
		$JobTitle = "*database*"
		
		ForEach ($syseng in $ListDataCollection)
		{
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $oncallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $oncallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $oncallgroup" }
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $bkponcallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $bkponcallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $bkponcallgroup" }
			}
		}
	}

	#Fuction For Lending ASA Distribution list
	function Set-Lending
	{
		$oncallgroup = "Primary On Call Lending ASA"
		$oncallgroupSMS = "Primary On Call Lending ASA SMS"
		$bkponcallgroup = "Secondary On Call Lending ASA"
		$bkponcallgroupSMS = "Secondary On Call Lending ASA SMS"
		
		$mailto = "appsupport@wingsfinancial.com"
		$Team = "ASA Team"
		$JobTitle = "*Lending*"
		
		ForEach ($syseng in $ListDataCollection)
		{
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $oncallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $oncallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $oncallgroup" }
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $bkponcallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $bkponcallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $bkponcallgroup" }
			}
		}
	}

	#Fuction For Digital ASA Distribution list
	function Set-Digital
	{
		$oncallgroup = "Primary On Call Digital ASA"
		$oncallgroupSMS = "Primary On Call Digital ASA SMS"
		$bkponcallgroup = "Secondary On Call Digital ASA"
		$bkponcallgroupSMS = "Secondary On Call Digital ASA SMS"

		$mailto = "appsupport@wingsfinancial.com"
		$Team = "ASA Team"
		$JobTitle = "*Digital*"
		
		ForEach ($syseng in $ListDataCollection)
		{
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $oncallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $oncallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $oncallgroup" }
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $bkponcallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $bkponcallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $bkponcallgroup" }
			}
		}
	}

	#Fuction For Retail ASA Distribution list
	function Set-Retail
	{
		$oncallgroup = "Primary On Call Retail ASA"
		$oncallgroupSMS = "Primary On Call Retail ASA SMS"
		$bkponcallgroup = "Secondary On Call Retail ASA"
		$bkponcallgroupSMS = "Secondary On Call Retail ASA SMS"
		
		$mailto = "appsupport@wingsfinancial.com"
		$Team = "ASA Team"
		$JobTitle = "*Retail*"
		
		ForEach ($syseng in $ListDataCollection)
		{
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $oncallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $oncallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $oncallgroup" }
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $bkponcallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $bkponcallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $bkponcallgroup" }
			}
		}
	}

	#Fuction For BackOffice ASA Distribution list
	function Set-BackOfficeASA
	{
		$oncallgroup = "Primary On Call BackOffice ASA"
		$oncallgroupSMS = "Primary On Call BackOffice ASA SMS"
		$bkponcallgroup = "Secondary On Call BackOffice ASA"
		$bkponcallgroupSMS = "Secondary On Call BackOffice ASA SMS"
		
		$mailto = "appsupport@wingsfinancial.com"
		$Team = "ASA Team"
		$JobTitle = "*BackOffice*"
		
		ForEach ($syseng in $ListDataCollection)
		{
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $oncallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $oncallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $oncallgroup" }
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $bkponcallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $bkponcallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $bkponcallgroup" }
			}
		}
	}

	function Set-Net
	{
		$oncallgroup = "Primary On Call Network Engineer"
		$oncallgroupSMS = "Primary On Call Network Engineer SMS"
		$bkponcallgroup = "Secondary On Call Network Engineer"
		$bkponcallgroupSMS = "Secondary On Call Network Engineer SMS"
		
		$mailto = "NTO@wingsfinancial.com"
		$Team = "Network Engineers"
		$JobTitle = "Network Eng*"
		
		ForEach ($syseng in $ListDataCollection)
		{
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $oncallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $oncallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $oncallgroup" }
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $bkponcallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $bkponcallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $bkponcallgroup" }
			}
		}
	}

	function Set-TeleAdm
	{
		$oncallgroup = "Primary On Call Telecom Administrator"
		$oncallgroupSMS = "Primary On Call Telecom Administrator SMS"
		$bkponcallgroup = "Secondary On Call Telecom Administrator"
		$bkponcallgroupSMS = "Secondary On Call Telecom Administrator SMS"
		
		$mailto = "NTO@wingsfinancial.com"
		$Team = "Telecom Administrators"
		$JobTitle = "Telecommunications Systems Admin*"
		
		ForEach ($syseng in $ListDataCollection)
		{
			if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $oncallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $oncallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $oncallgroup" }
			}
			elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
			{
				$oncall = $syseng.Title
				$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
				$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
				Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
				Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
				Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
				Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
				$BetterToSearch = "*$oncall*"
				$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
				Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
				$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
				$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
				$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
				$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
				Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
				Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
				If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember") {
					Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
					$EmailNameOld = $OLDoncallgroupmemberName
					$EmailNameNew = $NEWoncallgroupmembeName
					$EmailGroup = $bkponcallgroup
					$EmailNameOldSMS = $OldOnCallSMSMemberName
					$EmailNameNewSMS = $NewOnCallSMSMemberName
					$EmailGroupSMS = $bkponcallgroupSMS
					Send-Email
				} else { Write-Host "No changes needed for $bkponcallgroup" }
			}
		}
	}

	# ---------------------------
	# Connect to SharePoint (PnP, app-only cert)
	# ---------------------------
	Write-Host "Connecting to SharePoint (app-only cert)"
	Connect-PnPOnline -Url $SiteURL `
		-ClientId $ClientId `
		-Tenant $TenantDomain `
		-CertificatePath $CertPath `
		-CertificatePassword $CertPassword

	# ---------------------------
	# FIX: DO NOT enumerate fields with Get-PnPField (caused "not initialized")
	# Pull only the fields you use.
	# ---------------------------
	$Counter = 0
	$ListItems = Get-PnPListItem -List $ListName -PageSize 2000

	$ListItems | ForEach-Object {
		$ListItem  = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsText
		$ListRow = New-Object PSObject
		$Counter++

		foreach ($FieldName in @("Title","JobTitle","On_x0020_Call","On_x002d_CallBackup")) {
			$ListRow | Add-Member -MemberType NoteProperty -Name $FieldName -Value $ListItem[$FieldName]
		}

		if ($ListRow.On_x0020_Call -like "yes" -or $ListRow.On_x002d_CallBackup -like "yes") {
			$ListDataCollection += $ListRow
		}
	}

	# Add Members to distribution group functions
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
