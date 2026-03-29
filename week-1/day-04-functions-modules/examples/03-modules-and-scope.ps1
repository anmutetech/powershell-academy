# =============================================================================
# Day 4 — Modules and Scope
# =============================================================================

# --- Creating a simple module (inline demo) ---
# In real use, save functions to a .psm1 file and use Import-Module

# --- Scope demonstration ---
Write-Host "=== Scope Demo ===" -ForegroundColor Cyan
$outerVar = "I live outside"

function Test-Scope {
    $innerVar = "I live inside"
    Write-Output "Inside function - outerVar: $outerVar"
    Write-Output "Inside function - innerVar: $innerVar"
}

Test-Scope
Write-Output "Outside function - outerVar: $outerVar"
Write-Output "Outside function - innerVar: $innerVar"  # Empty!

# --- Don't modify outer variables (bad practice) ---
Write-Host "`n=== Bad Practice: Modifying Outer Scope ===" -ForegroundColor Yellow
$counter = 0

function Add-BadCount {
    $script:counter++   # Modifying script scope — avoid this
}

Add-BadCount
Add-BadCount
Write-Output "Counter (bad practice): $counter"

# --- Good practice: return values ---
Write-Host "`n=== Good Practice: Return Values ===" -ForegroundColor Green
function Add-GoodCount {
    param([int]$Current)
    return $Current + 1
}

$counter2 = 0
$counter2 = Add-GoodCount -Current $counter2
$counter2 = Add-GoodCount -Current $counter2
Write-Output "Counter (good practice): $counter2"

# --- Module commands ---
Write-Host "`n=== Working with Modules ===" -ForegroundColor Cyan

# List loaded modules
Write-Output "Currently loaded modules:"
Get-Module | Select-Object Name, Version | Format-Table

# List available modules
Write-Output "Available modules (first 10):"
Get-Module -ListAvailable | Select-Object -First 10 Name, Version | Format-Table

# Find commands in a module
Write-Output "Commands in Microsoft.PowerShell.Management:"
Get-Command -Module Microsoft.PowerShell.Management | Select-Object -First 10 Name, CommandType | Format-Table

# --- Module paths ---
Write-Host "=== Module Paths ===" -ForegroundColor Cyan
$env:PSModulePath -split [System.IO.Path]::PathSeparator | ForEach-Object {
    Write-Output "  $_"
}
