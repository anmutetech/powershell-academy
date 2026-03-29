# =============================================================================
# Day 1 — The Big Three Discovery Commands
# =============================================================================

# --- Get-Help: Read the documentation ---

# Basic help for a command
Get-Help Get-Process

# Show practical examples (most useful)
Get-Help Get-Process -Examples

# Search for commands related to a keyword
Get-Help *network*
Get-Help *firewall*

# Update help files (run once, may need admin/sudo)
# Update-Help -ErrorAction SilentlyContinue

# --- Get-Command: Find available commands ---

# Find all commands with "Service" in the name
Get-Command *Service*

# Find all commands that stop something
Get-Command -Verb Stop

# Find all commands that work with processes
Get-Command -Noun Process

# Count how many commands are available
(Get-Command).Count

# --- Get-Member: Explore object properties and methods ---

# What properties does a Process have?
Get-Process | Get-Member

# Just the properties
Get-Process | Get-Member -MemberType Property

# What can I do with a DateTime object?
Get-Date | Get-Member

# Practical example: I discovered "DayOfYear" from Get-Member
(Get-Date).DayOfYear

# Practical example: I discovered "Kill()" method on processes from Get-Member
# Get-Process -Name notepad | Get-Member -MemberType Method

# --- Combining discovery with action ---

# Step 1: I want to work with services. Let me find the commands.
Get-Command *Service*

# Step 2: How do I use Get-Service?
Get-Help Get-Service -Examples

# Step 3: Let me run it and see what properties are available.
Get-Service | Get-Member -MemberType Property

# Step 4: Now I know I can filter by Status
Get-Service | Where-Object Status -eq 'Running'
