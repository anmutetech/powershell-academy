# =============================================================================
# Day 1 — Pipeline Basics
# =============================================================================

# --- Simple pipeline: Get, Sort, Select ---

# Top 5 processes by CPU usage
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5

# Top 10 processes by memory usage
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10

# --- Filtering with Where-Object ---

# Services that are currently running
Get-Service | Where-Object Status -eq 'Running'

# Processes using more than 50MB of memory
Get-Process | Where-Object { $_.WorkingSet64 -gt 50MB }

# Files larger than 1MB in the current directory
Get-ChildItem | Where-Object { $_.Length -gt 1MB }

# --- Selecting specific properties ---

# Show only Name and CPU for processes
Get-Process | Select-Object Name, CPU, WorkingSet64 | Sort-Object WorkingSet64 -Descending | Select-Object -First 5

# Show only DisplayName and Status for services
Get-Service | Select-Object DisplayName, Status | Sort-Object DisplayName

# --- Formatting output ---

# As a table (default for most commands)
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table

# As a list (shows all properties vertically)
Get-Process | Sort-Object CPU -Descending | Select-Object -First 1 | Format-List *

# --- Counting ---

# How many processes are running?
(Get-Process).Count

# How many services are running vs stopped?
Get-Service | Group-Object Status

# --- Practical one-liners ---

# Find all .ps1 files in current directory tree
Get-ChildItem -Recurse -Filter *.ps1

# Get the total size of all files in a directory
(Get-ChildItem | Measure-Object -Property Length -Sum).Sum / 1MB
