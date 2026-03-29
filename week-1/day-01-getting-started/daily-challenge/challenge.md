# Day 1 — Daily Challenge: System Information Reporter

## The Task

Write a PowerShell script that displays a system information report. When you run it, the output should look something like this:

```
=== SYSTEM INFORMATION REPORT ===
Generated: 2026-03-29 10:30:00

Computer Name: DESKTOP-ABC123
Operating System: Microsoft Windows 11 Pro
Current User: john.smith
PowerShell Version: 7.4.1

IP Address(es):
  - 192.168.1.100
  - 10.0.0.5

Disk Space:
  C: 45.2 GB free / 237.8 GB total (19% free)
  D: 120.0 GB free / 500.0 GB total (24% free)

Top 5 Processes by CPU:
  1. chrome         - CPU: 125.4
  2. code           - CPU: 89.2
  3. pwsh           - CPU: 12.1
  4. explorer       - CPU: 8.5
  5. svchost        - CPU: 5.3
```

## Requirements

1. Display the computer name
2. Display the operating system
3. Display the current logged-in user
4. Display the current date and time
5. Display IP addresses (at least one)
6. Display disk space for each drive (free, total, percentage free)
7. Display the top 5 processes by CPU time

## Hints

- Computer name: `[System.Environment]::MachineName` or `$env:COMPUTERNAME`
- OS info: `[System.Environment]::OSVersion` or `$PSVersionTable.OS`
- Current user: `[System.Environment]::UserName` or `whoami`
- IP addresses: `Get-NetIPAddress` (Windows) or `hostname -I` (Linux)
- Disk space: `Get-PSDrive -PSProvider FileSystem` or `Get-CimInstance Win32_LogicalDisk`
- Top processes: `Get-Process | Sort-Object CPU -Descending | Select-Object -First 5`

## Getting Started

Open `starter.ps1` and fill in the sections marked with TODO comments.
