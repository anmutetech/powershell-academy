# =============================================================================
# Day 9 — Service and Process Management
# =============================================================================

# === Services ===
Write-Host "=== Service Overview ===" -ForegroundColor Cyan

# Count by status
$services = Get-Service
$running = ($services | Where-Object Status -eq "Running").Count
$stopped = ($services | Where-Object Status -eq "Stopped").Count
Write-Output "Total: $($services.Count) | Running: $running | Stopped: $stopped"

# Key services check
Write-Host "`n=== Key Services ===" -ForegroundColor Cyan
$keyServices = @("Spooler", "W32Time", "wuauserv", "WinRM", "EventLog")
foreach ($svc in $keyServices) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        $color = if ($s.Status -eq "Running") { "Green" } else { "Yellow" }
        Write-Host ("  {0,-20} {1,-12} {2}" -f $s.Name, $s.Status, $s.StartType) -ForegroundColor $color
    } else {
        Write-Host "  $svc - NOT FOUND" -ForegroundColor Red
    }
}

# Service dependencies
Write-Host "`n=== WinRM Dependencies ===" -ForegroundColor Cyan
$deps = Get-Service -Name "WinRM" -ErrorAction SilentlyContinue
if ($deps) {
    Write-Output "Required by WinRM:"
    Get-Service -Name "WinRM" -RequiredServices | ForEach-Object { Write-Output "  - $($_.Name): $($_.Status)" }
}

# === Processes ===
Write-Host "`n=== Top 10 Processes by CPU ===" -ForegroundColor Cyan
Get-Process | Where-Object { $_.CPU -gt 0 } |
    Sort-Object CPU -Descending |
    Select-Object -First 10 Name, Id, CPU,
        @{N="MemMB";E={[math]::Round($_.WorkingSet64/1MB)}},
        @{N="Threads";E={$_.Threads.Count}} |
    Format-Table -AutoSize

# Memory hogs
Write-Host "=== Top 5 by Memory ===" -ForegroundColor Cyan
Get-Process |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 5 Name, Id,
        @{N="MemMB";E={[math]::Round($_.WorkingSet64/1MB)}},
        @{N="MemGB";E={[math]::Round($_.WorkingSet64/1GB,2)}} |
    Format-Table -AutoSize

# Process count by name
Write-Host "=== Processes with Multiple Instances ===" -ForegroundColor Cyan
Get-Process | Group-Object Name |
    Where-Object Count -gt 1 |
    Sort-Object Count -Descending |
    Select-Object -First 10 Name, Count |
    Format-Table -AutoSize
