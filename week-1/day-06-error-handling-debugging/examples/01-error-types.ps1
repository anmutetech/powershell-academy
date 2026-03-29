# =============================================================================
# Day 6 — Error Types and ErrorAction
# =============================================================================

# --- Non-terminating error (continues execution) ---
Write-Host "=== Non-Terminating Error ===" -ForegroundColor Cyan
Get-Item "C:\definitely-not-a-real-file.txt"
Write-Output "Script continues after non-terminating error"

# --- ErrorAction Continue (default) ---
Write-Host "`n=== ErrorAction Continue ===" -ForegroundColor Cyan
Get-Service -Name "FakeService123" -ErrorAction Continue
Write-Output "Continued past the error"

# --- ErrorAction SilentlyContinue ---
Write-Host "`n=== ErrorAction SilentlyContinue ===" -ForegroundColor Cyan
$svc = Get-Service -Name "FakeService123" -ErrorAction SilentlyContinue
if ($null -eq $svc) {
    Write-Output "Service not found (error suppressed)"
}

# --- ErrorAction Stop (makes it catchable) ---
Write-Host "`n=== ErrorAction Stop ===" -ForegroundColor Cyan
try {
    Get-Service -Name "FakeService123" -ErrorAction Stop
} catch {
    Write-Output "Caught: $($_.Exception.Message)"
}

# --- $ErrorActionPreference ---
Write-Host "`n=== ErrorActionPreference ===" -ForegroundColor Cyan
$originalPref = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"

Get-Item "nonexistent1.txt"
Get-Item "nonexistent2.txt"
Write-Output "Both errors were silently ignored"

$ErrorActionPreference = $originalPref

# --- $Error automatic variable ---
Write-Host "`n=== `$Error Variable ===" -ForegroundColor Cyan
$Error.Clear()

Get-Item "fake1.txt" -ErrorAction SilentlyContinue
Get-Item "fake2.txt" -ErrorAction SilentlyContinue

Write-Output "Error count: $($Error.Count)"
Write-Output "Most recent: $($Error[0].Exception.Message)"
Write-Output "Oldest: $($Error[-1].Exception.Message)"
