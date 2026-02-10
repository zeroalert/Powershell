PS C:\Users\3382z9\Documents> .\Test.ps1 -LogLocation C:\logs -PfxPassword "Firewall1!"
Log Started
VERBOSE: Performing the operation "Start-Transcript" on target "C:\logs\Sharepoint_OnCall_0210261438.log".
Transcript started, output file is C:\logs\Sharepoint_OnCall_0210261438.log
Importing Module
Connecting to SharePoint (app-only cert)

===== Performing System Engineer rotation =====
Processing Primary System Engineer : Dan Madigan
  Email group 'Primary On Call Sys Engineer' has no current members
  SMS group 'Primary On Call Sys Engineer SMS' has no current contacts
  Current email member :
  Current SMS contact  :
VERBOSE: Adds all the specified member(s) to the specified group(s).
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call Sys Engineer SMS,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
  New email member     : Dan Madigan
  New SMS contact      : Dan
  Membership changed — sending email
WARNING: Failed processing System Engineer rotation: Cannot validate argument on parameter 'Attachments'. The argument is null, empty, or an element of the argument collection contains a null value. Supply a collection that does not contain any null values and then try the command again.

===== Performing DBA rotation =====
Processing Primary DBA : Jonathan Roberts
  Current email member : Jonathan Roberts
  Current SMS contact  : Jonathan
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call DBA,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
VERBOSE: Adds all the specified member(s) to the specified group(s).
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call DBA SMS,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
  New email member     : Jonathan Roberts
  New SMS contact      : Jonathan
  No changes needed for Primary On Call DBA
Processing Secondary DBA : Paul Schulz
  Current email member : Paul Schulz
  Current SMS contact  : Paul
VERBOSE: Performing the operation "Set" on target "CN=Secondary On Call DBA,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
VERBOSE: Adds all the specified member(s) to the specified group(s).
VERBOSE: Performing the operation "Set" on target "CN=Secondary On Call DBA SMS,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
  New email member     : Paul Schulz
  New SMS contact      : Paul
  No changes needed for Secondary On Call DBA

===== Performing Lending ASA rotation =====
Processing Primary Lending ASA : Bee Vang
  Current email member : Bee Vang
  Current SMS contact  : Bee
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call Lending ASA,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
VERBOSE: Adds all the specified member(s) to the specified group(s).
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call Lending ASA SMS,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
  New email member     : Bee Vang
  New SMS contact      : Bee
  No changes needed for Primary On Call Lending ASA

===== Performing Digital ASA rotation =====
Processing Primary Digital ASA : Louis Peloquin
  Current email member : Louis Peloquin
  Current SMS contact  : Justin
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call Digital ASA,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
VERBOSE: Adds all the specified member(s) to the specified group(s).
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call Digital ASA SMS,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
  New email member     : Louis Peloquin
  New SMS contact      : Louis
  No changes needed for Primary On Call Digital ASA
Processing Secondary Digital ASA : Patrick Meshak
  Current email member : Patrick Meshak
  Current SMS contact  : Louis
VERBOSE: Performing the operation "Set" on target "CN=Secondary On Call Digital ASA,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
VERBOSE: Adds all the specified member(s) to the specified group(s).
VERBOSE: Performing the operation "Set" on target "CN=Secondary On Call Digital ASA SMS,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
  New email member     : Patrick Meshak
  New SMS contact      : Patrick
  No changes needed for Secondary On Call Digital ASA

===== Performing Retail ASA rotation =====
Processing Primary Retail ASA : Derek Balke
  Current email member : Derek Balke
  Current SMS contact  : Mike
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call Retail ASA,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
VERBOSE: Adds all the specified member(s) to the specified group(s).
VERBOSE: Performing the operation "Set" on target "CN=Primary On Call Retail ASA SMS,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
  New email member     : Derek Balke
  New SMS contact      : Derek
  No changes needed for Primary On Call Retail ASA
Processing Secondary Retail ASA : Mike Ryan
  Current email member : Mike Ryan
  Current SMS contact  : Perry
VERBOSE: Performing the operation "Set" on target "CN=Secondary On Call Retail ASA,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
VERBOSE: Adds all the specified member(s) to the specified group(s).
VERBOSE: Performing the operation "Set" on target "CN=Secondary On Call Retail ASA SMS,OU=Distribution,OU=Groups,OU=Users,OU=Wings,DC=wingsfinancial,DC=local".
  New email member     : Mike Ryan
  New SMS contact      : Mike
  No changes needed for Secondary On Call Retail ASA

===== Performing BackOffice ASA rotation =====

===== Performing Network Engineer rotation =====

===== Performing Telecom Administrator rotation =====

Complete — Exiting Now
PS C:\Users\3382z9\Documents>
