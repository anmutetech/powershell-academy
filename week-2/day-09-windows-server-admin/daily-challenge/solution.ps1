# =============================================================================
# Day 9 Daily Challenge — Server Monitoring Dashboard (Solution)
# =============================================================================

# Configuration
$refreshInterval = 30
$servicesToMonitor = @("Spooler", "W32Time", "wuauserv", "EventLog")
$diskWarning = 80
$diskCritical = 90
$memWarning = 80
$memCritical = 90

function Get-ProgressBar {
    param([double]$Percent, [int]$Width = 10)
    $filled = [math]::Floor($Percent / 100 * $Width)
    $empty = $Width - $filled
    "[" + ("#" * $filled) + ("-" * $empty) + "]"
}

function Get-StatusColor {
    param([double]$Value, [int]$Warning = 80, [int]$Critical = 90)
    if ($Value -ge $Critical) { "Red" }
    elseif ($Value -ge $Warning) { "Yellow" }
    else { "Green" }
}

function Get-StatusText {
    param([double]$Value, [int]$Warning = 80, [int]$Critical = 90)
    if ($Value -ge $Critical) { "CRITICAL" }
    elseif ($Value -ge $Warning) { "WARNING" }
    else { "OK" }
}

function Show-MonitoringDashboard {
    [CmdletBinding()]
    param(
        [string[]]$Services = $servicesToMonitor,
        [switch]$SingleRun
    )

    $alerts = @()
    $divider = "=" * 60

    Clear-Host
    Write-Host $divider -ForegroundColor Cyan
    Write-Host "     SERVER MONITORING DASHBOARD - $env:COMPUTERNAME" -ForegroundColor Cyan
    Write-Host "     $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | Refresh: ${refreshInterval}s" -ForegroundColor Cyan
    Write-Host $divider -ForegroundColor Cyan
    Write-Host ""

    # CPU
    try {
        $cpu = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average
        $cpuPct = [math]::Round($cpu, 1)
    } catch { $cpuPct = 0 }

    $bar = Get-ProgressBar -Percent $cpuPct
    $color = Get-StatusColor -Value $cpuPct -Warning 70 -Critical 90
    Write-Host ("  CPU:     {0} {1,5}%  {2}" -f $bar, $cpuPct, (Get-StatusText $cpuPct 70 90)) -ForegroundColor $color
    if ($cpuPct -ge 70) { $alerts += "CPU usage at $cpuPct%" }

    # Memory
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
        $usedGB = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 1)
        $memPct = [math]::Round(($usedGB / $totalGB) * 100, 1)
    } catch { $memPct = 0; $usedGB = 0; $totalGB = 0 }

    $bar = Get-ProgressBar -Percent $memPct
    $color = Get-StatusColor -Value $memPct -Warning $memWarning -Critical $memCritical
    Write-Host ("  Memory:  {0} {1,5}%  {2}/{3} GB  {4}" -f $bar, $memPct, $usedGB, $totalGB, (Get-StatusText $memPct $memWarning $memCritical)) -ForegroundColor $color
    if ($memPct -ge $memWarning) { $alerts += "Memory at $memPct%" }

    # Disks
    try {
        Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
            $dPct = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 1)
            $dUsed = [math]::Round(($_.Size - $_.FreeSpace) / 1GB)
            $dTotal = [math]::Round($_.Size / 1GB)
            $bar = Get-ProgressBar -Percent $dPct
            $color = Get-StatusColor -Value $dPct -Warning $diskWarning -Critical $diskCritical
            Write-Host ("  Disk {0}  {1} {2,5}%  {3}/{4} GB  {5}" -f $_.DeviceID, $bar, $dPct, $dUsed, $dTotal, (Get-StatusText $dPct $diskWarning $diskCritical)) -ForegroundColor $color
            if ($dPct -ge $diskWarning) { $alerts += "Disk $($_.DeviceID) at $dPct%" }
        }
    } catch {}

    # Top Processes
    Write-Host "`n  TOP PROCESSES (CPU)" -ForegroundColor Yellow
    Get-Process | Where-Object CPU -gt 0 | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Output ("    {0,-25} {1,8:N1}s  {2,6} MB" -f $_.Name, $_.CPU, [math]::Round($_.WorkingSet64/1MB))
    }

    # Services
    Write-Host "`n  SERVICES" -ForegroundColor Yellow
    foreach ($svcName in $Services) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        if ($svc) {
            $sColor = if ($svc.Status -eq "Running") { "Green" } else { "Red" }
            $sTag = if ($svc.Status -eq "Running") { "OK" } else { "ALERT" }
            Write-Host ("    {0,-20} {1,-12} {2}" -f $svc.Name, $svc.Status, $sTag) -ForegroundColor $sColor
            if ($svc.Status -ne "Running") { $alerts += "$svcName service is $($svc.Status)" }
        }
    }

    # Recent errors
    Write-Host "`n  RECENT EVENTS" -ForegroundColor Yellow
    foreach ($log in @("System", "Application")) {
        try {
            $errCount = (Get-WinEvent -FilterHashtable @{
                LogName = $log; Level = 2; StartTime = (Get-Date).AddHours(-1)
            } -ErrorAction SilentlyContinue).Count

            $eColor = if ($errCount -gt 0) { "Yellow" } else { "Green" }
            Write-Host ("    {0,-20} {1} errors (last hour)" -f $log, $errCount) -ForegroundColor $eColor
        } catch {
            Write-Host ("    {0,-20} Unable to read" -f $log) -ForegroundColor Gray
        }
    }

    # Alerts
    if ($alerts.Count -gt 0) {
        Write-Host "`n  ALERTS:" -ForegroundColor Red
        foreach ($alert in $alerts) {
            Write-Host "  [!] $alert" -ForegroundColor Red
        }
    } else {
        Write-Host "`n  No alerts - all systems healthy." -ForegroundColor Green
    }

    Write-Host "`n$divider" -ForegroundColor Cyan
}

# Run once (remove the SingleRun for continuous monitoring)
Show-MonitoringDashboard -SingleRun

Write-Host "`nTo run continuously, uncomment the loop below:" -ForegroundColor Gray
Write-Host @"

# Continuous monitoring loop:
# do {
#     Show-MonitoringDashboard
#     Write-Host "Press Ctrl+C to stop. Refreshing in $refreshInterval seconds..." -ForegroundColor Gray
#     Start-Sleep -Seconds $refreshInterval
# } while (`$true)
"@
