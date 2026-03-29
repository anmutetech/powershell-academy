# =============================================================================
# Day 1 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Find Service Commands ---
Get-Command *Service*
# To count them:
(Get-Command *Service*).Count

# --- Exercise 2: Explore Get-Process ---
# Parameter to get by name: -Name
# Parameter to get by ID: -Id
# Show examples:
Get-Help Get-Process -Examples

# --- Exercise 3: Top 10 by Memory ---
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 10 -Property ProcessName, WorkingSet64

# Bonus: format memory in MB for readability
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 10 -Property ProcessName,
        @{Name='MemoryMB'; Expression={[math]::Round($_.WorkingSet64 / 1MB, 2)}}

# --- Exercise 4: Alias Detective ---
Get-Alias -Definition Get-ChildItem
# Common aliases: ls, dir, gci

# --- Exercise 5: Running Services ---
Get-Service |
    Where-Object Status -eq 'Running' |
    Sort-Object DisplayName |
    Select-Object DisplayName, Status
