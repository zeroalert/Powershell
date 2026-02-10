Save-Module -Name PnP.PowerShell -Path C:\Temp\PnPModule -RequiredVersion 2.12.0vvvv


# Remove the incompatible version
Remove-Item "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell\3.1.0" -Recurse -Force

# Copy the 2.x version from your workstation
Copy-Item "C:\Temp\PnPModule\PnP.PowerShell" -Destination "C:\Program Files\WindowsPowerShell\Modules\PnP.PowerShell" -Recurse
