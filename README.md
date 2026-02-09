# Remove all old versions and install matching set
Uninstall-Module Microsoft.Graph.Applications -AllVersions -Force
Uninstall-Module Microsoft.Graph.Authentication -AllVersions -Force
Install-Module Microsoft.Graph.Authentication -Force -Scope CurrentUser
Install-Module Microsoft.Graph.Applications -Force -Scope CurrentUser
