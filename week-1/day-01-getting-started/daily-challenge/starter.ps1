# =============================================================================
# Day 1 Daily Challenge — System Information Reporter (Starter)
# Fill in each TODO section to complete the script.
# =============================================================================

Write-Output "=== SYSTEM INFORMATION REPORT ==="
Write-Output "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output ""

# TODO 1: Display the computer name
# Hint: [System.Environment]::MachineName
Write-Output "Computer Name: "

# TODO 2: Display the operating system
# Hint: $PSVersionTable.OS
Write-Output "Operating System: "

# TODO 3: Display the current user
# Hint: [System.Environment]::UserName
Write-Output "Current User: "

# TODO 4: Display the PowerShell version
Write-Output "PowerShell Version: "

Write-Output ""
Write-Output "IP Address(es):"
# TODO 5: Display IP addresses
# Hint: Get-NetIPAddress on Windows, or try:
#   [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName())

Write-Output ""
Write-Output "Disk Space:"
# TODO 6: Display disk space for each drive
# Hint: Get-PSDrive -PSProvider FileSystem gives you Used and Free properties
# You will need a foreach loop or ForEach-Object pipeline

Write-Output ""
Write-Output "Top 5 Processes by CPU:"
# TODO 7: Get the top 5 processes by CPU
# Hint: Get-Process | Sort-Object CPU -Descending | Select-Object -First 5
# Display the rank, name, and CPU time
