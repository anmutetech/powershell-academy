# =============================================================================
# Day 9 — System Information and Networking
# =============================================================================

# === System Info ===
Write-Host "=== System Information ===" -ForegroundColor Cyan

try {
    $cs = Get-CimInstance Win32_ComputerSystem
    $os = Get-CimInstance Win32_OperatingSystem

    [PSCustomObject]@{
        ComputerName = $cs.Name
        Domain       = $cs.Domain
        Model        = $cs.Model
        OS           = $os.Caption
        Version      = $os.Version
        Build        = $os.BuildNumber
        TotalRAM_GB  = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
        LastBoot     = $os.LastBootUpTime
    } | Format-List
} catch {
    Write-Warning "Could not retrieve system info: $($_.Exception.Message)"
}

# === Disk Info ===
Write-Host "=== Disk Information ===" -ForegroundColor Cyan
try {
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $usedPct = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 1)
        $color = if ($usedPct -ge 90) { "Red" } elseif ($usedPct -ge 75) { "Yellow" } else { "Green" }

        Write-Host ("{0}  Size: {1,8:N1} GB  Free: {2,8:N1} GB  Used: {3,5}%" -f
            $_.DeviceID,
            ($_.Size / 1GB),
            ($_.FreeSpace / 1GB),
            $usedPct
        ) -ForegroundColor $color
    }
} catch {
    Write-Warning "Could not retrieve disk info"
}

# === Installed Updates ===
Write-Host "`n=== Recent Updates ===" -ForegroundColor Cyan
try {
    Get-HotFix | Sort-Object InstalledOn -Descending -ErrorAction SilentlyContinue |
        Select-Object -First 5 HotFixID, Description, InstalledOn |
        Format-Table -AutoSize
} catch {
    Write-Output "Could not retrieve hotfix info"
}

# === Network Info ===
Write-Host "=== Network Adapters ===" -ForegroundColor Cyan
try {
    Get-NetAdapter -ErrorAction SilentlyContinue | ForEach-Object {
        $color = if ($_.Status -eq "Up") { "Green" } else { "Red" }
        Write-Host ("  {0,-30} {1,-8} {2}" -f $_.Name, $_.Status, $_.LinkSpeed) -ForegroundColor $color
    }
} catch {
    Write-Output "Network adapter cmdlets not available (may need Windows)"
}

Write-Host "`n=== IP Addresses ===" -ForegroundColor Cyan
try {
    Get-NetIPAddress -ErrorAction SilentlyContinue |
        Where-Object { $_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1" } |
        Select-Object InterfaceAlias, IPAddress, PrefixLength |
        Format-Table -AutoSize
} catch {
    # Fallback for non-Windows
    Write-Output "IP Info (fallback):"
    if ($IsWindows -eq $false) {
        $ipInfo = (Get-NetIPAddress -ErrorAction SilentlyContinue) ??
            "Run 'ip addr' or 'ifconfig' on Linux/macOS"
        Write-Output $ipInfo
    }
}

# === Connectivity Test ===
Write-Host "=== Connectivity Check ===" -ForegroundColor Cyan
$targets = @(
    @{ Name = "DNS (Google)"; Host = "8.8.8.8" }
    @{ Name = "DNS (Cloudflare)"; Host = "1.1.1.1" }
)

foreach ($target in $targets) {
    try {
        $result = Test-Connection -ComputerName $target.Host -Count 1 -Quiet -ErrorAction Stop
        $status = if ($result) { "OK" } else { "UNREACHABLE" }
        $color = if ($result) { "Green" } else { "Red" }
        Write-Host ("  {0,-25} {1,-15} {2}" -f $target.Name, $target.Host, $status) -ForegroundColor $color
    } catch {
        Write-Host ("  {0,-25} {1,-15} ERROR" -f $target.Name, $target.Host) -ForegroundColor Red
    }
}
