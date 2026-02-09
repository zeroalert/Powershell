<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.168
	 Created on:   	10/29/2019 11:59 AM
	 Created by:   Luke Barlow
	 Organization: 	Wings Financial Credit Union
	 Filename:    	Sharepoint_OnCall_Change
	===========================================================================
	.DESCRIPTION
		Script used to sync the on call sharepoint list to the AD user group for rotation of the on Call List. 
#>

[CmdletBinding()]
param (
	[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
	[ValidateNotNullOrEmpty()]
	[string]$LogLocation
)

$Date = (Get-Date -Format MMdyhhmm)
$LogFileName = "Sharepoint_OnCall_$Date.log"

Write-Host "Log Started"
$Step = "Log Started"

Start-Transcript -Path $LogLocation\$LogFileName -Append -Force -Verbose

#Steve Armstrong
#5/7/2020
#Oncall Automation
#Config Parameter foe sharepoint list
$SiteURL = "https://wingsfinancialcu.sharepoint.com/sites/dr"
$ListName = "I.S. Emergency Contacts"
$mailsmtp = "mail.wingsfinancial.local"
$cred = Import-CliXml -Path E:\Master_Files\GL_Creds.xml

#$CSVPath = "C:\winstall\ListData.csv"
$ListDataCollection= @()

#Installing Module if not Found. 

If (-not (Get-InstalledModule sharepointpnppowershellonline -ErrorAction silentlycontinue))
{
	Install-PackageProvider -Name NuGet -Confirm:$false -Force -ErrorAction silentlycontinue
	Install-Module sharepointpnppowershellonline -Confirm:$false -AllowClobber -Force -ErrorAction silentlycontinue
}

Write-Host "Importing Module"
import-module sharepointpnppowershellonline -Force

function Send-Email
{
	$mailfrom="Oncall@wingsfinancial.com"
	$mailsub= "Oncall Group Membership has Changed"
	$Emailbody = "  
<html>
<style>
body {
  text-align: left
}
</style>
<p>Hello $Team,</p>
<p>The $EmailGroup has changed from $EmailNameOld to $EmailNameNew.</p>
<p>The $EmailGroupSMS has changed from $EmailNameOldSMS to $EmailNameNewSMS.</p>
<p>Thank you,</p>
</body>"
	
	$Signature = Get-Content "$env:System_DefaultWorkingDirectory\HelpDeskEmailFiles\HelpDesk.htm"
	
	$Emailbody += $Signature
	
	Send-MailMessage -From "$mailfrom" -To "$mailto" -Body "$EmailBody" -BodyAsHtml -Subject "$mailsub" -SmtpServer $mailsmtp -Attachments $env:System_DefaultWorkingDirectory\HelpDeskEmailFiles\logo1.png, $env:System_DefaultWorkingDirectory\HelpDeskEmailFiles\logo2.png
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
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Primary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering old Primary SMS User
			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into primary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
			#Adding into primary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Primary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering New Primary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $oncallgroup"
			}
		}
		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
		{
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
		
			#Gathering old Secondary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering old Secondary SMS User
			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into Secondary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
			#Adding into Secondary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Secondary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering New Secondary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $bkponcallgroup"
			}
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
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Primary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering old Primary SMS User
			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into primary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
			#Adding into primary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Primary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering New Primary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $oncallgroup"
			}
		}
		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
		{
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Secondary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering old Secondary SMS User
			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into Secondary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
			#Adding into Secondary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Secondary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering New Secondary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $bkponcallgroup"
			}
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
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Primary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering old Primary SMS User
			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into primary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
			#Adding into primary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Primary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering New Primary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $oncallgroup"
			}
		}
		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
		{
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Secondary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering old Secondary SMS User
			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into Secondary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
			#Adding into Secondary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Secondary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering New Secondary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $bkponcallgroup"
			}
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
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Primary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering old Primary SMS User
			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into primary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
			#Adding into primary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Primary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering New Primary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $oncallgroup"
			}
		}
		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
		{
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Secondary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering old Secondary SMS User
			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into Secondary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
			#Adding into Secondary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Secondary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering New Secondary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $bkponcallgroup"
			}
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
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Primary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering old Primary SMS User
			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into primary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
			#Adding into primary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Primary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering New Primary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $oncallgroup"
			}
		}
		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
		{
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Secondary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering old Secondary SMS User
			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into Secondary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
			#Adding into Secondary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Secondary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering New Secondary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $bkponcallgroup"
			}
		}
	}
}

#Fuction For Retail ASA Distribution list
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
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Primary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering old Primary SMS User
			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into primary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
			#Adding into primary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Primary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering New Primary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $oncallgroup"
			}
		}
		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
		{
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Secondary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering old Secondary SMS User
			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into Secondary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
			#Adding into Secondary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Secondary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering New Secondary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $bkponcallgroup"
			}
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
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Primary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering old Primary SMS User
			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into primary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
			#Adding into primary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Primary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering New Primary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $oncallgroup"
			}
		}
		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
		{
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
		
			#Gathering old Secondary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering old Secondary SMS User
			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into Secondary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
			#Adding into Secondary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Secondary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering New Secondary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $bkponcallgroup"
			}
		}
	}
}

# function Set-Sec
# {
# 	$oncallgroup = "Primary On Call Security Engineer"
# 	# $oncallgroupSMS = "Primary On Call Security Engineer SMS"
# 	$bkponcallgroup = "Secondary On Call Security Engineer"
# 	# $bkponcallgroupSMS = "Secondary On Call Security Engineer SMS"
	
# 	$mailto = "cybersecurityoperations@wingsfinancial.com"
# 	$Team = "Cybersecurity Engineers"
# 	$JobTitle = "Cybersecurity Eng*"
	
# 	ForEach ($syseng in $ListDataCollection)
# 	{
# 		if ($syseng.On_x0020_Call -like "yes" -and $syseng.JobTitle -like $JobTitle)
# 		{
# 			#Setting On Call Group like Title in Sharepoint Site
# 			$oncall = $syseng.Title
			
# 			#Gathering old Primary Email User
# 			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
# 			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
# 			#Gathering old Primary SMS User
# 			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
# 			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
# 			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
# 			#Writing to Log file Info
# 			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
# 			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
# 			#Removing Memebers of the Email and SMS Group
# 			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
# 			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
# 			#Adding in Current Sharepoint site Users to group
			
# 			#Adding into primary Email Group
# 			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
# 			#Adding into primary SMS Group
# 			$BetterToSearch = "*$oncall*"
# 			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
# 			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
# 			#Gathering New Primary Email User
# 			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
# 			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
# 			#Gathering New Primary SMS User
# 			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
# 			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
# 			#Writing to Log file Info
# 			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
# 			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
# 			#Sends email if group membership has changed
# 			If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember")
# 			{
# 				Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
# 				$EmailNameOld = $OLDoncallgroupmemberName
# 				$EmailNameNew = $NEWoncallgroupmembeName
# 				$EmailGroup = $oncallgroup
# 				$EmailNameOldSMS = $OldOnCallSMSMemberName
# 				$EmailNameNewSMS = $NewOnCallSMSMemberName
# 				$EmailGroupSMS = $oncallgroupSMS
# 				Send-Email
# 			}
# 			else
# 			{
# 				Write-Host "No changes needed for $oncallgroup"
# 			}
# 		}
# 		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
# 		{
# 			#Setting On Call Group like Title in Sharepoint Site
# 			$oncall = $syseng.Title
		
# 			#Gathering old Secondary Email User
# 			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
# 			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
# 			#Gathering old Secondary SMS User
# 			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
# 			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
# 			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
# 			#Writing to Log file Info
# 			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
# 			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
# 			#Removing Memebers of the Email and SMS Group
# 			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
# 			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
# 			#Adding in Current Sharepoint site Users to group
			
# 			#Adding into Secondary Email Group
# 			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
# 			#Adding into Secondary SMS Group
# 			$BetterToSearch = "*$oncall*"
# 			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
# 			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
# 			#Gathering New Secondary Email User
# 			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
# 			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
# 			#Gathering New Secondary SMS User
# 			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
# 			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
# 			#Writing to Log file Info
# 			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
# 			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
# 			#Sends email if group membership has changed
# 			If ("$NEWoncallgroupmember" -ne "$OLDoncallgroupmember")
# 			{
# 				Write-Host "Sending out Email Since $NEWoncallgroupmember does not equal $OLDoncallgroupmember"
# 				$EmailNameOld = $OLDoncallgroupmemberName
# 				$EmailNameNew = $NEWoncallgroupmembeName
# 				$EmailGroup = $bkponcallgroup
# 				$EmailNameOldSMS = $OldOnCallSMSMemberName
# 				$EmailNameNewSMS = $NewOnCallSMSMemberName
# 				$EmailGroupSMS = $bkponcallgroupSMS
# 				Send-Email
# 			}
# 			else
# 			{
# 				Write-Host "No changes needed for $bkponcallgroup"
# 			}
# 		}
# 	}
# }

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
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
			
			#Gathering old Primary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering old Primary SMS User
			$GroupCNSMS = (get-adgroup $oncallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $oncallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $oncallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $oncallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into primary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $oncallgroup -Verbos
			
			#Adding into primary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $oncallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Primary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $oncallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $oncallgroup -Verbose).Name
			
			#Gathering New Primary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $oncallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $oncallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $oncallgroup"
			}
		}
		elseif ($syseng.On_x002d_CallBackup -like "yes" -and $syseng.JobTitle -like $JobTitle)
		{
			#Setting On Call Group like Title in Sharepoint Site
			$oncall = $syseng.Title
		
			#Gathering old Secondary Email User
			$OLDoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$OLDoncallgroupmemberName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering old Secondary SMS User
			$GroupCNSMS = (get-adgroup $bkponcallgroupSMS).DistinguishedName
			$OldOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			$OldOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			
			#Writing to Log file Info
			Write-Host "Current $bkponcallgroup has been identified as $OLDoncallgroupmemberName"
			Write-Host "Current $bkponcallgroupSMS has been identified as $OLDOnCallSMSMemberName"
			
			#Removing Memebers of the Email and SMS Group
			Remove-ADGroupMember -Identity $bkponcallgroup $OLDoncallgroupmember -Confirm:$false -Verbose
			Get-ADGroup $GroupCNSMS | Set-ADObject -Remove @{ 'member' = $OldOnCallSMSMemberDN }
			
			#Adding in Current Sharepoint site Users to group
			
			#Adding into Secondary Email Group
			Get-ADuser -Filter { (name -eq $oncall) -and (emailaddress -like "*@wingsfinancial.com") } -Properties * -Verbose | Add-ADPrincipalGroupMembership -MemberOf $bkponcallgroup -Verbos
			
			#Adding into Secondary SMS Group
			$BetterToSearch = "*$oncall*"
			$TextUserDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Name -like $BetterToSearch) })
			Set-ADGroup -Identity $bkponcallgroupSMS -Add @{ 'member' = "$TextUserDN" } -verbose
			
			#Gathering New Secondary Email User
			$NEWoncallgroupmember = Get-ADGroupMember -Identity $bkponcallgroup
			$NEWoncallgroupmembeName = (Get-ADGroupMember -Identity $bkponcallgroup -Verbose).Name
			
			#Gathering New Secondary SMS User
			$NewOnCallSMSMemberDN = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) }).DistinguishedName
			$NewOnCallSMSMemberName = (Get-ADObject -Filter { (objectClass -eq "contact") -and (Memberof -like $GroupCNSMS) } -properties *).givenName
			
			#Writing to Log file Info
			Write-Host "Sharepoint for $bkponcallgroup has been identified as $NEWoncallgroupmembeName"
			Write-Host "Sharepoint for $bkponcallgroupSMS has been identified as $NewOnCallSMSMemberName"
			
			#Sends email if group membership has changed
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
			else
			{
				Write-Host "No changes needed for $bkponcallgroup"
			}
		}
	}
}

#Connect to PnP Online
Connect-PnPOnline -Url $SiteURL -Credentials $cred
$Counter = 0
$ListItems = Get-PnPListItem -List $ListName 
 
#Get all items from list
$ListItems | ForEach-Object {
        $ListItem  = Get-PnPProperty -ClientObject $_ -Property FieldValuesAsText
        $ListRow = New-Object PSObject
        $Counter++
        Get-PnPField -List $ListName | ForEach-Object {
            $ListRow | Add-Member -MemberType NoteProperty -name $_.InternalName -Value $ListItem[$_.InternalName]
            }
       #uncomment the line below if you do not want to see the progress
        #Write-Progress -PercentComplete ($Counter / $($ListItems.Count)  * 100) -Activity "Exporting List Items..." -Status  "Exporting Item $Counter of $($ListItems.Count)"
#Filter records by Oncall and Oncall Backup       
        if ($ListRow.On_x0020_Call -like "yes" -or $ListRow.On_x002d_CallBackup -like "yes") {
        $ListDataCollection += $ListRow
       } 
        
}

#Add Members to distribution group functions
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
# Write-Host "Performing Security Engineer Function"
# Set-sec
Write-Host "Performing TeleAdm Function"
Set-TeleAdm
Write-Host "Complete Exiting Now"
#Export the result Array to CSV file
#$ListDataCollection.Title | Export-CSV $CSVPath -NoTypeInformation

Exit
#Read more: https://www.sharepointdiary.com/2016/03/export-list-items-to-csv-in-sharepoint-online-using-powershell.html#ixzz6JcrwKbhp
