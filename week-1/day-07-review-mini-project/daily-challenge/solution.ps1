# =============================================================================
# Day 7 Capstone — Server Inventory & Health Dashboard (Solution)
# =============================================================================

# --- Configuration ---
$reportDir = Join-Path $PSScriptRoot "reports"
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
$dateDisplay = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$servicesToCheck = @("Spooler", "W32Time", "wuauserv", "WinRM")
$logFile = Join-Path $reportDir "inventory-$timestamp.log"

if (-not (Test-Path $reportDir)) {
    New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
}

# --- Logging ---
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $logFile -Value $entry
}

# --- Data Collection ---
function Get-SystemInfo {
    [CmdletBinding()]
    param()

    try {
        Write-Verbose "Collecting system information"
        Write-Log "Collecting system info"

        $uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

        [PSCustomObject]@{
            ComputerName = $env:COMPUTERNAME
            OS           = (Get-CimInstance Win32_OperatingSystem).Caption
            PSVersion    = $PSVersionTable.PSVersion.ToString()
            Uptime       = "{0} days, {1} hours" -f $uptime.Days, $uptime.Hours
        }
        Write-Log "System info collected"
    } catch {
        Write-Log "Failed to collect system info: $($_.Exception.Message)" -Level "ERROR"
        [PSCustomObject]@{ ComputerName = $env:COMPUTERNAME; OS = "Error"; PSVersion = "Error"; Uptime = "Error" }
    }
}

function Get-DiskHealth {
    [CmdletBinding()]
    param(
        [int]$WarningThreshold = 75,
        [int]$CriticalThreshold = 90
    )

    try {
        Write-Verbose "Checking disk health"
        Write-Log "Checking disk health"

        Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
            $totalGB = [math]::Round($_.Size / 1GB, 2)
            $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
            $usedGB = [math]::Round($totalGB - $freeGB, 2)
            $usagePct = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100, 1) } else { 0 }

            $status = if ($usagePct -ge $CriticalThreshold) { "Critical" }
                      elseif ($usagePct -ge $WarningThreshold) { "Warning" }
                      else { "OK" }

            [PSCustomObject]@{
                Drive        = $_.DeviceID
                TotalGB      = $totalGB
                UsedGB       = $usedGB
                FreeGB       = $freeGB
                UsagePercent = $usagePct
                Status       = $status
            }
        }
    } catch {
        Write-Log "Disk health check failed: $($_.Exception.Message)" -Level "ERROR"
    }
}

function Get-MemoryHealth {
    [CmdletBinding()]
    param()

    try {
        Write-Verbose "Checking memory health"
        $os = Get-CimInstance Win32_OperatingSystem
        $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
        $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
        $usedGB = [math]::Round($totalGB - $freeGB, 2)
        $usagePct = [math]::Round(($usedGB / $totalGB) * 100, 1)

        $status = if ($usagePct -ge 90) { "Critical" }
                  elseif ($usagePct -ge 80) { "Warning" }
                  else { "OK" }

        [PSCustomObject]@{
            TotalGB      = $totalGB
            UsedGB       = $usedGB
            FreeGB       = $freeGB
            UsagePercent = $usagePct
            Status       = $status
        }
    } catch {
        Write-Log "Memory check failed: $($_.Exception.Message)" -Level "ERROR"
    }
}

function Get-TopProcesses {
    [CmdletBinding()]
    param([int]$Count = 5)

    try {
        Write-Verbose "Getting top $Count processes"
        Get-Process | Where-Object { $_.CPU -gt 0 } |
            Sort-Object CPU -Descending |
            Select-Object -First $Count Name,
                @{N="CPU"; E={[math]::Round($_.CPU, 1)}},
                @{N="MemoryMB"; E={[math]::Round($_.WorkingSet64 / 1MB)}}
    } catch {
        Write-Log "Process collection failed: $($_.Exception.Message)" -Level "ERROR"
    }
}

function Get-ServiceStatus {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string[]]$ServiceName)

    foreach ($name in $ServiceName) {
        try {
            $svc = Get-Service -Name $name -ErrorAction Stop
            [PSCustomObject]@{
                Name      = $svc.Name
                Display   = $svc.DisplayName
                Status    = $svc.Status.ToString()
                StartType = $svc.StartType.ToString()
            }
        } catch {
            [PSCustomObject]@{
                Name = $name; Display = "N/A"; Status = "NOT FOUND"; StartType = "N/A"
            }
            Write-Log "Service '$name' not found" -Level "WARN"
        }
    }
}

# --- Dashboard ---
function Show-Dashboard {
    param($SystemInfo, $DiskHealth, $Memory, $Processes, $Services)

    $divider = "=" * 64

    Write-Host $divider -ForegroundColor Cyan
    Write-Host "        SERVER INVENTORY & HEALTH DASHBOARD" -ForegroundColor Cyan
    Write-Host "        Generated: $dateDisplay" -ForegroundColor Cyan
    Write-Host $divider -ForegroundColor Cyan

    # System Info
    Write-Host "`nSYSTEM INFORMATION" -ForegroundColor Yellow
    Write-Host "  Computer:     $($SystemInfo.ComputerName)"
    Write-Host "  OS:           $($SystemInfo.OS)"
    Write-Host "  PS Version:   $($SystemInfo.PSVersion)"
    Write-Host "  Uptime:       $($SystemInfo.Uptime)"

    # Disk
    Write-Host "`nDISK HEALTH" -ForegroundColor Yellow
    foreach ($disk in $DiskHealth) {
        $color = switch ($disk.Status) { "Critical" { "Red" }; "Warning" { "Yellow" }; default { "Green" } }
        Write-Host ("  {0}  {1,8} GB  {2,8} GB  {3,8} GB  {4,5}%  [{5}]" -f
            $disk.Drive, $disk.TotalGB, $disk.UsedGB, $disk.FreeGB, $disk.UsagePercent, $disk.Status) -ForegroundColor $color
    }

    # Memory
    Write-Host "`nMEMORY" -ForegroundColor Yellow
    $memColor = switch ($Memory.Status) { "Critical" { "Red" }; "Warning" { "Yellow" }; default { "Green" } }
    Write-Host ("  Total: {0} GB | Used: {1} GB | Free: {2} GB | Usage: {3}% [{4}]" -f
        $Memory.TotalGB, $Memory.UsedGB, $Memory.FreeGB, $Memory.UsagePercent, $Memory.Status) -ForegroundColor $memColor

    # Processes
    Write-Host "`nTOP PROCESSES (by CPU)" -ForegroundColor Yellow
    $Processes | Format-Table -AutoSize | Out-String | Write-Host

    # Services
    Write-Host "SERVICE STATUS" -ForegroundColor Yellow
    foreach ($svc in $Services) {
        $svcColor = if ($svc.Status -eq "Running") { "Green" } elseif ($svc.Status -eq "NOT FOUND") { "Red" } else { "Yellow" }
        Write-Host ("  {0,-20} {1,-12} {2}" -f $svc.Name, $svc.Status, $svc.StartType) -ForegroundColor $svcColor
    }

    # Overall status
    $issues = @()
    $hasCritical = $false
    $DiskHealth | Where-Object Status -ne "OK" | ForEach-Object {
        $issues += "Disk $($_.Drive) at $($_.UsagePercent)% [$($_.Status)]"
        if ($_.Status -eq "Critical") { $hasCritical = $true }
    }
    if ($Memory.Status -ne "OK") {
        $issues += "Memory at $($Memory.UsagePercent)% [$($Memory.Status)]"
        if ($Memory.Status -eq "Critical") { $hasCritical = $true }
    }

    $overall = if ($hasCritical) { "CRITICAL" }
               elseif ($issues.Count -gt 0) { "WARNING" }
               else { "HEALTHY" }

    $overallColor = switch ($overall) { "CRITICAL" { "Red" }; "WARNING" { "Yellow" }; default { "Green" } }
    Write-Host "`nOVERALL STATUS: $overall" -ForegroundColor $overallColor
    if ($issues) { $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow } }

    Write-Host "`n$divider" -ForegroundColor Cyan
}

# === Main Execution ===
$sw = [System.Diagnostics.Stopwatch]::StartNew()
Write-Log "Inventory started"

$sysInfo    = Get-SystemInfo -Verbose
$diskHealth = @(Get-DiskHealth -Verbose)
$memory     = Get-MemoryHealth -Verbose
$processes  = @(Get-TopProcesses -Count 5 -Verbose)
$services   = @(Get-ServiceStatus -ServiceName $servicesToCheck -Verbose)

Show-Dashboard -SystemInfo $sysInfo -DiskHealth $diskHealth -Memory $memory -Processes $processes -Services $services

# Export CSV
$csvPath = Join-Path $reportDir "inventory-$timestamp.csv"
$diskHealth | Export-Csv -Path $csvPath -NoTypeInformation
Write-Log "CSV exported: $csvPath"

# Export JSON
$jsonPath = Join-Path $reportDir "inventory-$timestamp.json"
@{
    GeneratedAt = $dateDisplay
    System      = $sysInfo
    Disks       = $diskHealth
    Memory      = $memory
    TopProcesses = $processes
    Services    = $services
} | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonPath
Write-Log "JSON exported: $jsonPath"

$sw.Stop()
Write-Log "Inventory complete in $([math]::Round($sw.Elapsed.TotalSeconds, 2)) seconds"

Write-Host "Reports saved to:" -ForegroundColor Cyan
Write-Host "  CSV:  $csvPath"
Write-Host "  JSON: $jsonPath"
Write-Host "  Log:  $logFile"
