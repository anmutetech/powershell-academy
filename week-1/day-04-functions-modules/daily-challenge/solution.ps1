# =============================================================================
# Day 4 Daily Challenge — Server Health Check Toolkit (Solution)
# =============================================================================

function Get-SystemHealth {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )

    # CPU
    $cpu = (Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
    $cpuPercent = [math]::Round($cpu, 1)

    # Memory
    $os = Get-CimInstance Win32_OperatingSystem
    $memPercent = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)

    # Disk
    $disk = Get-PSDrive -Name C
    $diskTotal = $disk.Used + $disk.Free
    $diskPercent = if ($diskTotal -gt 0) { [math]::Round(($disk.Used / $diskTotal) * 100, 1) } else { 0 }

    # Status
    $maxUsage = [math]::Max($cpuPercent, [math]::Max($memPercent, $diskPercent))
    $status = if ($maxUsage -ge 95) { "Critical" }
              elseif ($maxUsage -ge 80) { "Warning" }
              else { "Healthy" }

    [PSCustomObject]@{
        ComputerName  = $ComputerName
        CPUPercent    = $cpuPercent
        MemoryPercent = $memPercent
        DiskPercent   = $diskPercent
        Status        = $status
    }
}

function Test-PortConnection {
    [CmdletBinding()]
    param(
        [string]$ComputerName = "localhost",

        [Parameter(Mandatory)]
        [ValidateRange(1, 65535)]
        [int]$Port
    )

    $isOpen = $false
    $responseTime = $null

    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $client = New-Object System.Net.Sockets.TcpClient
        $result = $client.BeginConnect($ComputerName, $Port, $null, $null)
        $wait = $result.AsyncWaitHandle.WaitOne(2000, $false)
        $stopwatch.Stop()

        if ($wait -and $client.Connected) {
            $isOpen = $true
            $responseTime = $stopwatch.ElapsedMilliseconds
        }
        $client.Close()
    } catch {
        Write-Verbose "Port $Port connection failed: $_"
    }

    [PSCustomObject]@{
        ComputerName = $ComputerName
        Port         = $Port
        IsOpen       = $isOpen
        ResponseMs   = $responseTime
    }
}

function Get-HealthReport {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$ComputerName = $env:COMPUTERNAME,

        [int[]]$PortsToCheck = @(80, 443, 22)
    )

    process {
        Write-Host "`n===== Server Health Report =====" -ForegroundColor Cyan

        $health = Get-SystemHealth -ComputerName $ComputerName

        $statusColor = switch ($health.Status) {
            "Healthy"  { "Green" }
            "Warning"  { "Yellow" }
            "Critical" { "Red" }
        }

        Write-Host "`nComputer: $($health.ComputerName)"

        foreach ($metric in @("CPU", "Memory", "Disk")) {
            $value = $health."${metric}Percent"
            $tag = if ($value -ge 95) { "[CRITICAL]" } elseif ($value -ge 80) { "[WARNING]" } else { "[OK]" }
            $color = if ($value -ge 95) { "Red" } elseif ($value -ge 80) { "Yellow" } else { "Green" }
            Write-Host ("  {0,-8} {1,5}%  {2}" -f "${metric}:", $value, $tag) -ForegroundColor $color
        }

        Write-Host "  Status: $($health.Status)" -ForegroundColor $statusColor

        if ($PortsToCheck.Count -gt 0) {
            Write-Host "`nPort Check:" -ForegroundColor Cyan
            foreach ($port in $PortsToCheck) {
                $portResult = Test-PortConnection -ComputerName $ComputerName -Port $port
                $portStatus = if ($portResult.IsOpen) { "OPEN" } else { "CLOSED" }
                $portColor = if ($portResult.IsOpen) { "Green" } else { "Red" }
                Write-Host ("  {0}:{1,-6} - {2}" -f $ComputerName, $port, $portStatus) -ForegroundColor $portColor
            }
        }
    }
}

# --- Run the report ---
Get-HealthReport -PortsToCheck @(80, 443, 22, 3389)
