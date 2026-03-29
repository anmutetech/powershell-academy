# =============================================================================
# Day 5 — Regex and Text Processing
# =============================================================================

# === String Methods ===
Write-Host "=== String Methods ===" -ForegroundColor Cyan
$text = "  Hello, PowerShell World!  "

Write-Output "Original:  '$text'"
Write-Output "Trimmed:   '$($text.Trim())'"
Write-Output "Upper:     '$($text.Trim().ToUpper())'"
Write-Output "Lower:     '$($text.Trim().ToLower())'"
Write-Output "Contains:  $($text.Contains('PowerShell'))"
Write-Output "Replace:   '$($text.Trim().Replace('World', 'Academy'))'"
Write-Output "Split:     $($text.Trim().Split(' ') -join ' | ')"
Write-Output "Substring: '$($text.Trim().Substring(0, 5))'"

# === -match and $Matches ===
Write-Host "`n=== Regex -match ===" -ForegroundColor Cyan

# Simple match
"My phone is 555-123-4567" -match "\d{3}-\d{3}-\d{4}" | Out-Null
Write-Output "Phone found: $($Matches[0])"

# Named capture groups
$serverName = "web-prod-03"
if ($serverName -match "^(?<role>\w+)-(?<env>\w+)-(?<num>\d+)$") {
    Write-Output "Role: $($Matches.role)"
    Write-Output "Env:  $($Matches.env)"
    Write-Output "Num:  $($Matches.num)"
}

# === -replace (regex) ===
Write-Host "`n=== Regex -replace ===" -ForegroundColor Cyan

# Reformat date
$date = "2026-03-15"
$reformatted = $date -replace "(\d{4})-(\d{2})-(\d{2})", '$2/$3/$1'
Write-Output "Date: $date -> $reformatted"

# Remove extra whitespace
$messy = "Too    many     spaces    here"
$clean = $messy -replace "\s+", " "
Write-Output "Cleaned: '$clean'"

# Mask sensitive data
$email = "john.doe@company.com"
$masked = $email -replace "^(\w{2})\w+", '$1***'
Write-Output "Masked: $masked"

# === Select-String (grep for PowerShell) ===
Write-Host "`n=== Select-String ===" -ForegroundColor Cyan

# Create sample log
$tempLog = Join-Path $env:TEMP "demo-app.log"
@(
    "2026-03-15 10:00:00 INFO  Application started on port 8080",
    "2026-03-15 10:01:15 INFO  User 'admin' authenticated from 192.168.1.50",
    "2026-03-15 10:05:30 WARN  Memory usage at 82% (threshold: 80%)",
    "2026-03-15 10:10:45 ERROR Database connection failed: timeout after 30s",
    "2026-03-15 10:11:00 INFO  Retrying connection (attempt 1/3)",
    "2026-03-15 10:11:05 INFO  Database connection established",
    "2026-03-15 10:15:20 ERROR File not found: /etc/app/config.yaml",
    "2026-03-15 10:20:00 INFO  Health check passed - all services green",
    "2026-03-15 10:25:00 WARN  Disk usage at 91% on /var/log",
    "2026-03-15 10:30:00 ERROR Authentication failed for user 'hacker' from 10.0.0.99"
) | Set-Content -Path $tempLog

# Find errors
Write-Host "Error lines:" -ForegroundColor Red
Select-String -Path $tempLog -Pattern "ERROR" | ForEach-Object {
    Write-Output "  Line $($_.LineNumber): $($_.Line)"
}

# Find IP addresses
Write-Host "`nIP Addresses found:" -ForegroundColor Yellow
Select-String -Path $tempLog -Pattern "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" | ForEach-Object {
    $_.Matches.Value
} | Sort-Object -Unique

# === Log Parsing ===
Write-Host "`n=== Structured Log Parsing ===" -ForegroundColor Cyan

$logEntries = Get-Content $tempLog | ForEach-Object {
    if ($_ -match "^(\d{4}-\d{2}-\d{2})\s(\d{2}:\d{2}:\d{2})\s(\w+)\s+(.+)$") {
        [PSCustomObject]@{
            Date    = $Matches[1]
            Time    = $Matches[2]
            Level   = $Matches[3]
            Message = $Matches[4]
        }
    }
}

$logEntries | Format-Table -AutoSize

# Count by level
Write-Host "Log Level Summary:" -ForegroundColor Yellow
$logEntries | Group-Object Level | Select-Object Name, Count | Format-Table

# Cleanup
Remove-Item $tempLog -Force
