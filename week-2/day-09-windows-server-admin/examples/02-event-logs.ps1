# =============================================================================
# Day 9 — Event Log Management
# =============================================================================

# === Available Logs ===
Write-Host "=== Top Event Logs by Record Count ===" -ForegroundColor Cyan
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue |
    Where-Object RecordCount -gt 0 |
    Sort-Object RecordCount -Descending |
    Select-Object -First 10 LogName, RecordCount,
        @{N="SizeMB";E={[math]::Round($_.FileSize/1MB,2)}} |
    Format-Table -AutoSize

# === Recent System Events ===
Write-Host "=== Recent System Events ===" -ForegroundColor Cyan
try {
    Get-WinEvent -LogName System -MaxEvents 10 |
        Select-Object TimeCreated,
            @{N="Level";E={$_.LevelDisplayName}},
            Id,
            @{N="Message";E={$_.Message.Substring(0, [math]::Min(80, $_.Message.Length))}} |
        Format-Table -AutoSize
} catch {
    Write-Warning "Could not read System log: $($_.Exception.Message)"
}

# === Filter with Hashtable (fastest method) ===
Write-Host "=== System Errors (last 24 hours) ===" -ForegroundColor Cyan
try {
    $errors = Get-WinEvent -FilterHashtable @{
        LogName   = "System"
        Level     = 2  # Error
        StartTime = (Get-Date).AddHours(-24)
    } -ErrorAction SilentlyContinue

    if ($errors) {
        Write-Output "Found $($errors.Count) errors"
        $errors | Select-Object -First 5 TimeCreated, Id,
            @{N="Source";E={$_.ProviderName}},
            @{N="Message";E={$_.Message.Substring(0, [math]::Min(100, $_.Message.Length))}} |
            Format-Table -AutoSize
    } else {
        Write-Output "No errors in the last 24 hours"
    }
} catch {
    Write-Output "No error events found or insufficient permissions"
}

# === Event Summary ===
Write-Host "=== System Event Summary (last 24 hours) ===" -ForegroundColor Cyan
try {
    $events = Get-WinEvent -FilterHashtable @{
        LogName   = "System"
        StartTime = (Get-Date).AddHours(-24)
    } -ErrorAction SilentlyContinue

    if ($events) {
        $events | Group-Object LevelDisplayName |
            Select-Object Name, Count |
            Sort-Object Count -Descending |
            Format-Table -AutoSize
    }
} catch {
    Write-Output "Could not retrieve events"
}

# === Search for Specific Event IDs ===
Write-Host "=== Common Security Events ===" -ForegroundColor Cyan
Write-Output @"
Common Event IDs to monitor:
  4624 - Successful logon
  4625 - Failed logon
  4720 - User account created
  4726 - User account deleted
  4732 - Member added to security group
  4740 - Account locked out
  1074 - System shutdown/restart
  7036 - Service started/stopped
"@
