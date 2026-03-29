# =============================================================================
# Day 14 — Stretch Exercise Solutions (Excerpts)
# =============================================================================

# --- Exercise 1: HTML Report ---
Write-Host "=== Exercise 1: HTML Report ===" -ForegroundColor Cyan

function New-HTMLReport {
    param(
        [PSCustomObject]$Health,
        [PSCustomObject]$Security,
        [string]$OutputPath = (Join-Path $env:TEMP "report.html")
    )

    $statusColor = switch ($Health.Status) {
        "Critical" { "#dc3545" }
        "Warning" { "#ffc107" }
        default { "#28a745" }
    }

    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Infrastructure Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .card { background: white; border-radius: 8px; padding: 20px; margin: 10px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .status { display: inline-block; padding: 4px 12px; border-radius: 4px; color: white; font-weight: bold; }
        .bar { height: 20px; background: #e0e0e0; border-radius: 10px; overflow: hidden; }
        .bar-fill { height: 100%; border-radius: 10px; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 8px 12px; text-align: left; border-bottom: 1px solid #eee; }
        th { background: #f8f9fa; }
    </style>
</head>
<body>
    <h1>Infrastructure Dashboard</h1>
    <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>

    <div class="card">
        <h2>Health Status: <span class="status" style="background:$statusColor">$($Health.Status)</span></h2>
        <p>CPU: $($Health.CPUPercent)% | Memory: $($Health.MemoryPercent)% | Disk: $($Health.DiskPercent)%</p>
        <div class="bar"><div class="bar-fill" style="width:$($Health.CPUPercent)%;background:#007bff"></div></div>
        <small>CPU Usage</small>
    </div>

    <div class="card">
        <h2>Security Score: $($Security.Score)%</h2>
        <table>
            <tr><th>Check</th><th>Status</th></tr>
            $($Security.Findings | ForEach-Object {
                $color = if ($_.Passed) { '#28a745' } else { '#dc3545' }
                "<tr><td>$($_.Check)</td><td style='color:$color;font-weight:bold'>$($_.Status)</td></tr>"
            })
        </table>
    </div>
</body>
</html>
"@

    $html | Set-Content -Path $OutputPath
    Write-Output "HTML report saved to: $OutputPath"
}

# Demo with simulated data
$healthData = [PSCustomObject]@{Status="Healthy";CPUPercent=42;MemoryPercent=65;DiskPercent=52}
$securityData = [PSCustomObject]@{Score=75;Findings=@(
    [PSCustomObject]@{Check="Execution Policy";Passed=$true;Status="PASS"}
    [PSCustomObject]@{Check="PS Version 7+";Passed=$true;Status="PASS"}
    [PSCustomObject]@{Check="Standard User";Passed=$false;Status="FAIL"}
)}

$reportPath = Join-Path $env:TEMP "demo-report.html"
New-HTMLReport -Health $healthData -Security $securityData -OutputPath $reportPath
Remove-Item $reportPath -Force -ErrorAction SilentlyContinue

# --- Exercise 2: Alert Notification ---
Write-Host "`n=== Exercise 2: Alert Notification ===" -ForegroundColor Cyan

function Send-AlertNotification {
    [CmdletBinding()]
    param(
        [PSCustomObject]$Health,
        [PSCustomObject]$Security,
        [string]$Recipient = "admin@company.com"
    )

    $shouldAlert = $Health.Status -ne "Healthy" -or $Security.Score -lt 80

    if (-not $shouldAlert) {
        Write-Output "No alerts needed — all systems healthy"
        return
    }

    $subject = "ALERT: Infrastructure Status - $($Health.Status)"
    $body = "Health: $($Health.Status) | Security: $($Security.Score)%"

    Write-Output "Simulated email:"
    Write-Output "  To: $Recipient"
    Write-Output "  Subject: $subject"
    Write-Output "  Body: $body"
}

Send-AlertNotification -Health $healthData -Security $securityData

# --- Exercise 4: Parallel Processing ---
Write-Host "`n=== Exercise 4: Parallel Processing ===" -ForegroundColor Cyan

$servers = @("web01", "web02", "db01", "app01")
Write-Output "Simulating parallel health check for $($servers.Count) servers..."

$results = $servers | ForEach-Object {
    [PSCustomObject]@{
        Server = $_
        CPU = Get-Random -Minimum 10 -Maximum 90
        Memory = Get-Random -Minimum 30 -Maximum 85
        Disk = Get-Random -Minimum 20 -Maximum 75
        Status = "Healthy"
    }
}

$results | Format-Table -AutoSize

Write-Host @"

In PowerShell 7, use ForEach-Object -Parallel:
  `$servers | ForEach-Object -Parallel {
      Get-InfrastructureHealth -ComputerName `$_
  } -ThrottleLimit 5
"@ -ForegroundColor Gray
