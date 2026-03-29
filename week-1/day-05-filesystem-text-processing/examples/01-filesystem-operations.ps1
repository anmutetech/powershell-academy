# =============================================================================
# Day 5 — File System Operations
# =============================================================================

# --- Navigation ---
Write-Host "=== Current Location ===" -ForegroundColor Cyan
Get-Location

# --- Listing files ---
Write-Host "`n=== Files in Current Directory ===" -ForegroundColor Cyan
Get-ChildItem | Select-Object Mode, LastWriteTime, Length, Name | Format-Table

# --- Filtered listing ---
Write-Host "=== PowerShell Files (recursive) ===" -ForegroundColor Cyan
Get-ChildItem -Path $PSScriptRoot\.. -Filter "*.ps1" -Recurse |
    Select-Object Name, Directory, Length | Format-Table

# --- Test-Path ---
Write-Host "=== Path Testing ===" -ForegroundColor Cyan
$testPaths = @($env:TEMP, "$env:TEMP\nonexistent.txt", $PROFILE)
foreach ($path in $testPaths) {
    $exists = Test-Path $path
    Write-Output "${path}: $exists"
}

# --- Create temp workspace ---
Write-Host "`n=== Creating Temp Workspace ===" -ForegroundColor Cyan
$workspace = Join-Path $env:TEMP "ps-academy-demo"

if (-not (Test-Path $workspace)) {
    New-Item -Path $workspace -ItemType Directory | Out-Null
    Write-Output "Created: $workspace"
}

# Create files
"Server log entry 1" | Set-Content -Path (Join-Path $workspace "server.log")
"Config data" | Set-Content -Path (Join-Path $workspace "app.config")
New-Item -Path (Join-Path $workspace "data") -ItemType Directory -Force | Out-Null
"CSV data" | Set-Content -Path (Join-Path $workspace "data\report.csv")

Write-Output "Workspace contents:"
Get-ChildItem $workspace -Recurse | Select-Object FullName | Format-Table

# --- Copy and Move ---
Copy-Item -Path (Join-Path $workspace "server.log") -Destination (Join-Path $workspace "server.log.bak")
Write-Output "Copied server.log to server.log.bak"

Rename-Item -Path (Join-Path $workspace "app.config") -NewName "app.config.old"
Write-Output "Renamed app.config to app.config.old"

# --- Cleanup ---
Remove-Item -Path $workspace -Recurse -Force
Write-Output "`nWorkspace cleaned up."
