# =============================================================================
# Day 1 — First Commands
# Run each section in your PowerShell terminal to see the output.
# =============================================================================

# --- Basic Information Commands ---

# Get the current date and time
Get-Date

# Get just the day of the week
(Get-Date).DayOfWeek

# Get your current directory (where you are in the file system)
Get-Location

# List files and folders in your current directory
Get-ChildItem

# List files with details (name, size, last modified)
Get-ChildItem | Format-Table Name, Length, LastWriteTime

# --- Navigation ---

# Move to your home directory
Set-Location ~

# Move to a specific folder (change this to a real path on your machine)
# Set-Location ~/Documents

# Go back to the previous location
Set-Location -

# --- System Information ---

# What version of PowerShell am I running?
$PSVersionTable

# Just the version number
$PSVersionTable.PSVersion

# What operating system am I on?
$PSVersionTable.OS

# Who am I?
whoami

# What is my computer's name?
[System.Environment]::MachineName
