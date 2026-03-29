# =============================================================================
# Day 1 Daily Challenge — System Information Reporter (Solution)
# =============================================================================

Write-Output "=== SYSTEM INFORMATION REPORT ==="
Write-Output "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Output ""

# Computer name
Write-Output "Computer Name: $([System.Environment]::MachineName)"

# Operating system
Write-Output "Operating System: $($PSVersionTable.OS)"

# Current user
Write-Output "Current User: $([System.Environment]::UserName)"

# PowerShell version
Write-Output "PowerShell Version: $($PSVersionTable.PSVersion)"

# IP addresses
Write-Output ""
Write-Output "IP Address(es):"
try {
    $addresses = [System.Net.Dns]::GetHostAddresses([System.Net.Dns]::GetHostName())
    foreach ($addr in $addresses) {
        if ($addr.AddressFamily -eq 'InterNetwork') {
            Write-Output "  - $($addr.IPAddressToString)"
        }
    }
} catch {
    Write-Output "  (Could not retrieve IP addresses)"
}

# Disk space
Write-Output ""
Write-Output "Disk Space:"
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -or $_.Free }
foreach ($drive in $drives) {
    $totalGB = [math]::Round(($drive.Used + $drive.Free) / 1GB, 1)
    $freeGB = [math]::Round($drive.Free / 1GB, 1)
    if ($totalGB -gt 0) {
        $pctFree = [math]::Round(($drive.Free / ($drive.Used + $drive.Free)) * 100, 0)
        Write-Output "  $($drive.Name): $freeGB GB free / $totalGB GB total ($pctFree% free)"
    }
}

# Top 5 processes by CPU
Write-Output ""
Write-Output "Top 5 Processes by CPU:"
$rank = 0
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
    $rank++
    $cpuRounded = [math]::Round($_.CPU, 1)
    Write-Output ("  {0}. {1,-20} - CPU: {2}" -f $rank, $_.ProcessName, $cpuRounded)
}
