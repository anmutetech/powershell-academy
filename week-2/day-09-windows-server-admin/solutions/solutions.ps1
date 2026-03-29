# =============================================================================
# Day 9 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Service Monitor Dashboard ---
Write-Host "=== Exercise 1: Service Monitor ===" -ForegroundColor Cyan

function Show-ServiceDashboard {
    [CmdletBinding()]
    param(
        [string[]]$ServiceName = @("Spooler", "W32Time", "wuauserv", "EventLog", "WinRM"),
        [switch]$AutoRestart
    )

    Write-Host "`n  SERVICE MONITOR DASHBOARD" -ForegroundColor Cyan
    Write-Host "  $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

    $stoppedCount = 0

    foreach ($name in $ServiceName) {
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if ($null -eq $svc) {
            Write-Host ("  {0,-25} NOT FOUND" -f $name) -ForegroundColor Red
            continue
        }

        $color = if ($svc.Status -eq "Running") { "Green" } else { "Red"; $stoppedCount++ }
        Write-Host ("  {0,-25} {1,-12} {2}" -f $svc.DisplayName, $svc.Status, $svc.StartType) -ForegroundColor $color

        if ($svc.Status -ne "Running" -and $AutoRestart) {
            try {
                Start-Service -Name $name -ErrorAction Stop
                Write-Host "    -> Restarted successfully" -ForegroundColor Green
            } catch {
                Write-Host "    -> Failed to restart: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }

    if ($stoppedCount -gt 0) {
        Write-Host "`n  ALERT: $stoppedCount service(s) stopped!" -ForegroundColor Red
    } else {
        Write-Host "`n  All services running." -ForegroundColor Green
    }
}

Show-ServiceDashboard

# --- Exercise 2: Event Log Analyzer ---
Write-Host "`n=== Exercise 2: Event Log Analyzer ===" -ForegroundColor Cyan

function Get-EventSummary {
    [CmdletBinding()]
    param(
        [string]$LogName = "System",
        [int]$Hours = 24,
        [int]$MaxEvents = 500
    )

    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName   = $LogName
            StartTime = (Get-Date).AddHours(-$Hours)
        } -MaxEvents $MaxEvents -ErrorAction Stop

        $byLevel = $events | Group-Object LevelDisplayName | Select-Object Name, Count

        $topIds = $events | Group-Object Id |
            Sort-Object Count -Descending |
            Select-Object -First 5 Name, Count

        [PSCustomObject]@{
            LogName    = $LogName
            TimeRange  = "$Hours hours"
            TotalEvents = $events.Count
            ByLevel    = $byLevel
            TopEventIds = $topIds
        }
    } catch {
        Write-Warning "Could not analyze $LogName`: $($_.Exception.Message)"
    }
}

$summary = Get-EventSummary -LogName "System" -Hours 24
if ($summary) {
    Write-Output "Log: $($summary.LogName) | Events: $($summary.TotalEvents) | Range: $($summary.TimeRange)"
    $summary.ByLevel | Format-Table -AutoSize
}

# --- Exercise 3: System Health Reporter ---
Write-Host "=== Exercise 3: System Health ===" -ForegroundColor Cyan

function Get-SystemHealthReport {
    [CmdletBinding()]
    param([string]$OutputPath)

    $report = @{}

    # CPU
    try {
        $cpu = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average
        $report.CPU = [PSCustomObject]@{ UsagePercent = [math]::Round($cpu, 1) }
    } catch { $report.CPU = @{ Error = $_.Exception.Message } }

    # Memory
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $memPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)
        $report.Memory = [PSCustomObject]@{
            TotalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
            UsagePercent = $memPct
        }
    } catch { $report.Memory = @{ Error = $_.Exception.Message } }

    # Top processes
    $report.TopProcesses = Get-Process | Sort-Object WorkingSet64 -Descending |
        Select-Object -First 10 Name, @{N="MemMB";E={[math]::Round($_.WorkingSet64/1MB)}}

    # Network
    try {
        $report.Network = Get-NetAdapter -ErrorAction Stop | Select-Object Name, Status, LinkSpeed
    } catch { $report.Network = @(@{Name="N/A"; Status="Unavailable"}) }

    $report.GeneratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if ($OutputPath) {
        $report | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath
        Write-Verbose "Report saved to $OutputPath"
    }

    $report
}

$health = Get-SystemHealthReport -Verbose
Write-Output "CPU: $($health.CPU.UsagePercent)%  |  Memory: $($health.Memory.UsagePercent)%"

# --- Exercise 4 & 5 are more complex and work best on Windows Server ---
Write-Host "`n=== Exercise 4: Scheduled Tasks ===" -ForegroundColor Cyan
try {
    $tasks = Get-ScheduledTask -ErrorAction Stop | Where-Object State -eq "Ready" | Select-Object -First 5
    Write-Output "Enabled tasks found: $($tasks.Count)"
    $tasks | Select-Object TaskName, State | Format-Table
} catch {
    Write-Output "Scheduled task management requires Windows"
}

Write-Host "=== Exercise 5: Server Inventory ===" -ForegroundColor Cyan
# Simulated multi-server comparison
$servers = @("Web01", "Web02", "DB01") | ForEach-Object {
    [PSCustomObject]@{
        Server  = $_
        OS      = "Windows Server 2022"
        RAM_GB  = Get-Random -Minimum 8 -Maximum 64
        DiskPct = Get-Random -Minimum 30 -Maximum 95
        CPUPct  = Get-Random -Minimum 5 -Maximum 90
    }
}

$servers | Format-Table -AutoSize
$outliers = $servers | Where-Object { $_.DiskPct -ge 80 -or $_.CPUPct -ge 80 }
if ($outliers) {
    Write-Host "Outliers (high usage):" -ForegroundColor Yellow
    $outliers | Format-Table -AutoSize
}
