# Remove all Graph modules
Uninstall-Module Microsoft.Graph.Authentication -AllVersions -Force -ErrorAction SilentlyContinue
Uninstall-Module Microsoft.Graph.Applications -AllVersions -Force -ErrorAction SilentlyContinue

# Reinstall latest
Install-Module Microsoft.Graph.Authentication -Force -Scope CurrentUser
Install-Module Microsoft.Graph.Applications -Force -Scope CurrentUser

# Test Graph connection immediately (before loading anything else)
Import-Module Microsoft.Graph.Authentication
Connect-MgGraph -Scopes "Application.ReadWrite.All" -UseDeviceCode
