# Check agent service status
Get-Service -Name "vstsagent*" -ComputerName TSSSIS01

# Check uptime (did it reboot?)
(Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName TSSSIS01).LastBootUpTime

# Check agent logs for errors
Get-ChildItem "\\TSSSIS01\c$\agent\_diag" | Sort-Object LastWriteTime -Descending | Select-Object -First 5
