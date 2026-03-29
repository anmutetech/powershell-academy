# Day 9 — Windows Server Administration

System administrators spend most of their time managing Windows Servers. Today you learn to automate the most common server tasks: services, processes, event logs, scheduled tasks, networking, and remote management.

---

## Video Resources

- [PowerShell for Server Administration](https://www.youtube.com/watch?v=UVUd9_k9C6A)
- [PowerShell Remoting](https://www.youtube.com/watch?v=M7bN5SRxkOQ)
- [PowerShell for Beginners Playlist](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) — Episodes 20-22

---

## 1. Service Management

```powershell
# List all services
Get-Service | Sort-Object Status, Name

# Filter running/stopped
Get-Service | Where-Object Status -eq "Running"
Get-Service | Where-Object Status -eq "Stopped"

# Check specific services
Get-Service -Name "wuauserv", "Spooler", "W32Time" | Format-Table Name, DisplayName, Status, StartType

# Start, Stop, Restart
Start-Service -Name "Spooler"
Stop-Service -Name "Spooler" -Force
Restart-Service -Name "Spooler"

# Change startup type
Set-Service -Name "Spooler" -StartupType Automatic

# Get service dependencies
Get-Service -Name "WinRM" -DependentServices
Get-Service -Name "WinRM" -RequiredServices
```

## 2. Process Management

```powershell
# List processes
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id, CPU, @{N="MemMB";E={[math]::Round($_.WorkingSet64/1MB)}}

# Find process by name
Get-Process -Name "explorer" | Format-List *

# Kill a process
Stop-Process -Name "notepad" -Force
Stop-Process -Id 1234 -Force

# Start a process
Start-Process -FilePath "notepad.exe"
Start-Process -FilePath "cmd.exe" -ArgumentList "/c dir" -NoNewWindow -Wait

# Monitor process CPU usage
Get-Process | Where-Object { $_.CPU -gt 100 } | Select-Object Name, Id, CPU
```

## 3. Event Logs

Event logs are critical for troubleshooting and security monitoring.

```powershell
# List available logs
Get-EventLog -List
Get-WinEvent -ListLog * | Where-Object RecordCount -gt 0 | Sort-Object RecordCount -Descending | Select-Object -First 10

# Read recent events (classic)
Get-EventLog -LogName System -Newest 20
Get-EventLog -LogName Application -EntryType Error -Newest 10

# Read events (modern — preferred)
Get-WinEvent -LogName System -MaxEvents 20
Get-WinEvent -LogName Application -MaxEvents 10 | Where-Object LevelDisplayName -eq "Error"

# Filter with hashtable (fastest)
Get-WinEvent -FilterHashtable @{
    LogName   = "System"
    Level     = 2  # 1=Critical, 2=Error, 3=Warning, 4=Info
    StartTime = (Get-Date).AddHours(-24)
}

# Security log (requires admin)
Get-WinEvent -FilterHashtable @{
    LogName = "Security"
    Id      = 4624  # Successful logon
} -MaxEvents 10

# Export events
Get-WinEvent -LogName System -MaxEvents 100 |
    Select-Object TimeCreated, LevelDisplayName, Id, Message |
    Export-Csv ".\system-events.csv" -NoTypeInformation
```

## 4. Scheduled Tasks

```powershell
# List scheduled tasks
Get-ScheduledTask | Where-Object State -eq "Ready" | Select-Object TaskName, State, TaskPath

# Get task details
Get-ScheduledTask -TaskName "MicrosoftEdgeUpdateTaskMachineCore" | Format-List *

# Create a scheduled task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-NoProfile -File C:\Scripts\backup.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At "02:00AM"

$settings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -WakeToRun

Register-ScheduledTask -TaskName "DailyBackup" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Description "Daily backup script" `
    -User "SYSTEM"

# Enable/Disable
Disable-ScheduledTask -TaskName "DailyBackup"
Enable-ScheduledTask -TaskName "DailyBackup"

# Run immediately
Start-ScheduledTask -TaskName "DailyBackup"

# Remove
Unregister-ScheduledTask -TaskName "DailyBackup" -Confirm:$false
```

## 5. Networking

```powershell
# Network adapters
Get-NetAdapter | Format-Table Name, Status, MacAddress, LinkSpeed

# IP configuration
Get-NetIPAddress | Where-Object AddressFamily -eq "IPv4" | Format-Table InterfaceAlias, IPAddress, PrefixLength

# DNS settings
Get-DnsClientServerAddress | Format-Table InterfaceAlias, ServerAddresses

# Test connectivity
Test-Connection -ComputerName "8.8.8.8" -Count 4
Test-NetConnection -ComputerName "google.com" -Port 443

# Firewall rules
Get-NetFirewallRule | Where-Object Enabled -eq "True" | Select-Object -First 10 DisplayName, Direction, Action

# Create firewall rule
New-NetFirewallRule -DisplayName "Allow Port 8080" `
    -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
```

## 6. System Information

```powershell
# Computer info
Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain, Model, TotalPhysicalMemory
Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, BuildNumber, LastBootUpTime

# Installed software
Get-CimInstance Win32_Product | Select-Object Name, Version, Vendor | Sort-Object Name

# Hotfixes/Updates
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 HotFixID, Description, InstalledOn

# Disk information
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,
        @{N="SizeGB";E={[math]::Round($_.Size/1GB,2)}},
        @{N="FreeGB";E={[math]::Round($_.FreeSpace/1GB,2)}},
        @{N="UsedPct";E={[math]::Round((($_.Size-$_.FreeSpace)/$_.Size)*100,1)}}
```

## 7. PowerShell Remoting

```powershell
# Enable remoting (run on target server)
Enable-PSRemoting -Force

# Run command on remote computer
Invoke-Command -ComputerName "Server01" -ScriptBlock {
    Get-Service | Where-Object Status -eq "Running" | Measure-Object
}

# Run on multiple servers
$servers = "Web01", "Web02", "DB01"
Invoke-Command -ComputerName $servers -ScriptBlock {
    [PSCustomObject]@{
        Computer = $env:COMPUTERNAME
        Uptime   = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
        OS       = (Get-CimInstance Win32_OperatingSystem).Caption
    }
}

# Interactive remote session
Enter-PSSession -ComputerName "Server01"
# ... run commands ...
Exit-PSSession

# Persistent session (reuse connection)
$session = New-PSSession -ComputerName "Server01"
Invoke-Command -Session $session -ScriptBlock { Get-Process | Measure-Object }
Invoke-Command -Session $session -ScriptBlock { Get-Service | Measure-Object }
Remove-PSSession $session

# Copy files via remoting
$session = New-PSSession -ComputerName "Server01"
Copy-Item -Path ".\script.ps1" -Destination "C:\Scripts\" -ToSession $session
```

## 8. Windows Features & Roles

```powershell
# List installed features (Server only)
Get-WindowsFeature | Where-Object Installed | Select-Object Name, DisplayName

# Install a feature
Install-WindowsFeature -Name "Web-Server" -IncludeManagementTools

# Check Windows capabilities (Windows 10/11)
Get-WindowsCapability -Online | Where-Object State -eq "Installed"
```

---

## Key Takeaways

1. `Get-Service` / `Set-Service` for service lifecycle management
2. `Get-WinEvent` with `-FilterHashtable` is the fastest way to query logs
3. Scheduled tasks replace cron jobs — use `Register-ScheduledTask`
4. `Invoke-Command` enables running scripts on remote servers in parallel
5. `Get-CimInstance` replaces the older `Get-WmiObject` for system queries
6. Always test with `-WhatIf` before making changes on production servers

---

## Interview Prep

**Q: How do you query Windows event logs efficiently?**
A: Use `Get-WinEvent` with `-FilterHashtable` for best performance. The hashtable supports LogName, Level, Id, StartTime, EndTime, and ProviderName. This filters at the source rather than piping through `Where-Object`, making it significantly faster for large logs.

**Q: How do you manage services on remote servers?**
A: Use `Invoke-Command -ComputerName` to run service commands remotely, or use `Get-Service -ComputerName`. For multiple servers, pass an array of names — PowerShell runs the commands in parallel. For repeated operations, create a persistent session with `New-PSSession`.

**Q: What is the difference between Get-WmiObject and Get-CimInstance?**
A: `Get-CimInstance` is the modern replacement. It uses WSMan (WinRM) by default instead of DCOM, is more secure, returns cleaner objects, and works better with PowerShell remoting. `Get-WmiObject` is deprecated in PowerShell 7+.
