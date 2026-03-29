# =============================================================================
# Day 12 — Incident Response Toolkit
# =============================================================================

Write-Host "=== Incident Response Toolkit ===" -ForegroundColor Cyan
Write-Host "Collecting system snapshot for forensic analysis...`n"

$irDir = Join-Path $env:TEMP "ir-snapshot-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -Path $irDir -ItemType Directory -Force | Out-Null

# --- 1. System Info ---
Write-Host "[1/6] System Information" -ForegroundColor Yellow
$sysInfo = [PSCustomObject]@{
    ComputerName = $env:COMPUTERNAME
    Username     = $env:USERNAME
    Domain       = $env:USERDOMAIN
    OS           = [System.Environment]::OSVersion.VersionString
    PSVersion    = $PSVersionTable.PSVersion.ToString()
    CollectedAt  = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}
$sysInfo | ConvertTo-Json | Set-Content (Join-Path $irDir "system-info.json")
Write-Output "  Saved system info"

# --- 2. Running Processes ---
Write-Host "[2/6] Running Processes" -ForegroundColor Yellow
$processes = Get-Process | Select-Object Name, Id, Path, StartTime, CPU,
    @{N="MemMB";E={[math]::Round($_.WorkingSet64/1MB)}}
$processes | Export-Csv (Join-Path $irDir "processes.csv") -NoTypeInformation
Write-Output "  Captured $($processes.Count) processes"

# Suspicious: processes without a path or from unusual locations
$suspicious = $processes | Where-Object {
    ($null -eq $_.Path) -or
    ($_.Path -and $_.Path -notmatch "^C:\\Windows|^C:\\Program Files")
}
if ($suspicious) {
    Write-Host "  Suspicious processes:" -ForegroundColor Red
    $suspicious | Select-Object -First 5 | ForEach-Object {
        Write-Host "    PID $($_.Id): $($_.Name) - $($_.Path)" -ForegroundColor Red
    }
}

# --- 3. Network Connections ---
Write-Host "[3/6] Network Connections" -ForegroundColor Yellow
try {
    $connections = Get-NetTCPConnection -ErrorAction Stop |
        Where-Object State -eq "Established" |
        Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess,
            @{N="Process";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}}
    $connections | Export-Csv (Join-Path $irDir "connections.csv") -NoTypeInformation
    Write-Output "  Captured $($connections.Count) established connections"

    # Flag connections to unusual ports
    $unusualPorts = $connections | Where-Object { $_.RemotePort -notin @(80, 443, 53, 22) -and $_.RemoteAddress -ne "127.0.0.1" }
    if ($unusualPorts) {
        Write-Host "  Unusual outbound connections:" -ForegroundColor Yellow
        $unusualPorts | Select-Object -First 5 | ForEach-Object {
            Write-Output "    $($_.Process) -> $($_.RemoteAddress):$($_.RemotePort)"
        }
    }
} catch {
    Write-Output "  Network capture requires Windows"
}

# --- 4. Scheduled Tasks ---
Write-Host "[4/6] Scheduled Tasks" -ForegroundColor Yellow
try {
    $tasks = Get-ScheduledTask -ErrorAction Stop | Where-Object State -eq "Ready" |
        Select-Object TaskName, TaskPath, @{N="Action";E={$_.Actions[0].Execute}}, State
    $tasks | Export-Csv (Join-Path $irDir "scheduled-tasks.csv") -NoTypeInformation
    Write-Output "  Captured $($tasks.Count) active scheduled tasks"
} catch {
    Write-Output "  Scheduled task capture requires Windows"
}

# --- 5. Recent Event Log Entries ---
Write-Host "[5/6] Security Events" -ForegroundColor Yellow
try {
    $secEvents = Get-WinEvent -FilterHashtable @{
        LogName   = "Security"
        StartTime = (Get-Date).AddHours(-24)
    } -MaxEvents 100 -ErrorAction Stop |
        Select-Object TimeCreated, Id, LevelDisplayName, Message
    $secEvents | Export-Csv (Join-Path $irDir "security-events.csv") -NoTypeInformation
    Write-Output "  Captured $($secEvents.Count) security events (last 24h)"
} catch {
    Write-Output "  Security event capture may require admin privileges"
}

# --- 6. Autorun Locations ---
Write-Host "[6/6] Persistence Locations" -ForegroundColor Yellow
$autoruns = @()

# Startup folder
$startupPath = [Environment]::GetFolderPath("Startup")
if (Test-Path $startupPath) {
    Get-ChildItem $startupPath -ErrorAction SilentlyContinue | ForEach-Object {
        $autoruns += [PSCustomObject]@{Location="Startup Folder";Name=$_.Name;Path=$_.FullName}
    }
}

# Registry Run keys
$runKeys = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)
foreach ($key in $runKeys) {
    try {
        $entries = Get-ItemProperty $key -ErrorAction Stop
        $entries.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
            $autoruns += [PSCustomObject]@{Location=$key;Name=$_.Name;Path=$_.Value}
        }
    } catch {}
}

if ($autoruns) {
    $autoruns | Export-Csv (Join-Path $irDir "autoruns.csv") -NoTypeInformation
    Write-Output "  Found $($autoruns.Count) autorun entries"
} else {
    Write-Output "  No autorun entries found (or limited access)"
}

# --- Summary ---
Write-Host "`n=== Collection Complete ===" -ForegroundColor Cyan
Write-Output "Snapshot saved to: $irDir"
Get-ChildItem $irDir | ForEach-Object {
    Write-Output "  $($_.Name) ($([math]::Round($_.Length/1KB, 1)) KB)"
}

# Cleanup
Remove-Item $irDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Output "`n(Demo cleanup: snapshot removed)"
