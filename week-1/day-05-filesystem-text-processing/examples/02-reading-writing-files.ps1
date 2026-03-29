# =============================================================================
# Day 5 — Reading and Writing Files (CSV, JSON, Text)
# =============================================================================

# --- Setup temp directory ---
$demoDir = Join-Path $env:TEMP "ps-academy-files"
New-Item -Path $demoDir -ItemType Directory -Force | Out-Null

# === TEXT FILES ===
Write-Host "=== Text Files ===" -ForegroundColor Cyan

# Write text
$logFile = Join-Path $demoDir "app.log"
@(
    "2026-03-15 10:00:00 INFO Application started",
    "2026-03-15 10:01:15 INFO User 'admin' logged in",
    "2026-03-15 10:05:30 WARNING High memory usage detected",
    "2026-03-15 10:10:45 ERROR Database connection timeout",
    "2026-03-15 10:11:00 INFO Retrying database connection",
    "2026-03-15 10:11:05 INFO Database connection restored",
    "2026-03-15 10:15:20 ERROR File not found: config.yaml",
    "2026-03-15 10:20:00 INFO Scheduled backup started"
) | Set-Content -Path $logFile

# Read all lines
$lines = Get-Content -Path $logFile
Write-Output "Total lines: $($lines.Count)"
Write-Output "First line: $($lines[0])"
Write-Output "Last line: $($lines[-1])"

# Read as single string
$raw = Get-Content -Path $logFile -Raw
Write-Output "`nRaw length: $($raw.Length) characters"

# Append
"2026-03-15 10:25:00 INFO Backup completed successfully" | Add-Content -Path $logFile

# Head and Tail
Write-Host "`nFirst 3 lines:" -ForegroundColor Yellow
Get-Content $logFile -Head 3

Write-Host "`nLast 3 lines:" -ForegroundColor Yellow
Get-Content $logFile -Tail 3

# === CSV FILES ===
Write-Host "`n=== CSV Files ===" -ForegroundColor Cyan

# Create CSV
$csvFile = Join-Path $demoDir "servers.csv"
$servers = @(
    [PSCustomObject]@{ Name="web01"; Role="WebServer"; OS="Windows 2022"; IP="10.0.1.10" }
    [PSCustomObject]@{ Name="web02"; Role="WebServer"; OS="Windows 2022"; IP="10.0.1.11" }
    [PSCustomObject]@{ Name="db01";  Role="Database";  OS="Windows 2022"; IP="10.0.2.10" }
    [PSCustomObject]@{ Name="app01"; Role="AppServer";  OS="Ubuntu 22.04"; IP="10.0.3.10" }
)
$servers | Export-Csv -Path $csvFile -NoTypeInformation

# Read CSV
$imported = Import-Csv -Path $csvFile
Write-Output "Servers loaded: $($imported.Count)"
$imported | Format-Table

# Filter CSV
Write-Host "Web servers only:" -ForegroundColor Yellow
$imported | Where-Object Role -eq "WebServer" | Format-Table

# === JSON FILES ===
Write-Host "=== JSON Files ===" -ForegroundColor Cyan

# Create JSON
$jsonFile = Join-Path $demoDir "config.json"
$config = @{
    application = @{
        name    = "MediTrack"
        version = "2.1.0"
        env     = "production"
    }
    database = @{
        host = "db01.internal"
        port = 5432
        name = "meditrack_prod"
    }
    features = @{
        logging    = $true
        monitoring = $true
        darkMode   = $false
    }
}
$config | ConvertTo-Json -Depth 3 | Set-Content -Path $jsonFile

# Read JSON
$loaded = Get-Content -Path $jsonFile -Raw | ConvertFrom-Json
Write-Output "App: $($loaded.application.name) v$($loaded.application.version)"
Write-Output "DB Host: $($loaded.database.host)"
Write-Output "Logging: $($loaded.features.logging)"

# --- Cleanup ---
Remove-Item -Path $demoDir -Recurse -Force
Write-Output "`nDemo files cleaned up."
