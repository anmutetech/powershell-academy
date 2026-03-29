# =============================================================================
# Day 3 — if/else and switch
# =============================================================================

# --- Disk space threshold check ---
$diskPercent = 87

if ($diskPercent -ge 90) {
    Write-Host "CRITICAL: ${diskPercent}% used" -ForegroundColor Red
} elseif ($diskPercent -ge 75) {
    Write-Host "WARNING: ${diskPercent}% used" -ForegroundColor Yellow
} else {
    Write-Host "OK: ${diskPercent}% used" -ForegroundColor Green
}

# --- Nested if ---
$user = @{ Role = "Admin"; MFA = $true }

if ($user.Role -eq "Admin") {
    if ($user.MFA) {
        Write-Output "Admin access granted (MFA verified)"
    } else {
        Write-Output "Admin access DENIED — MFA required"
    }
} else {
    Write-Output "Standard user access"
}

# --- switch with multiple values ---
$httpStatus = 404

switch ($httpStatus) {
    200 { Write-Output "OK" }
    301 { Write-Output "Redirect" }
    {$_ -ge 400 -and $_ -lt 500} { Write-Output "Client Error ($httpStatus)" }
    {$_ -ge 500} { Write-Output "Server Error ($httpStatus)" }
    default { Write-Output "Unknown status: $httpStatus" }
}

# --- switch -Wildcard ---
$fileName = "report-2026.csv"

switch -Wildcard ($fileName) {
    "*.csv"  { Write-Output "CSV file detected" }
    "*.json" { Write-Output "JSON file detected" }
    "*.xml"  { Write-Output "XML file detected" }
    "report*" { Write-Output "This is a report file" }
}
