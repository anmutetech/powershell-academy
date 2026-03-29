# =============================================================================
# Day 7 — Review Exercise Solutions
# =============================================================================

# --- Exercise 1: Quick Fire ---
Write-Host "=== Exercise 1: Quick Fire ===" -ForegroundColor Cyan
$a = "5"
$b = 3
$c = $a + $b        # "53" (string + int = string concatenation)
$d = [int]$a + $b   # 8 (int + int = addition)
$e = $a * $b        # "555" (string * int = repeat string)

Write-Output "c = $c (string concatenation: '5' + 3 = '53')"
Write-Output "d = $d (integer addition: 5 + 3 = 8)"
Write-Output "e = $e (string repeat: '5' * 3 = '555')"

# --- Exercise 2: Pipeline Challenge ---
Write-Host "`n=== Exercise 2: Pipeline Challenge ===" -ForegroundColor Cyan
Get-Process |
    Where-Object { $_.WorkingSet64 -gt 50MB } |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 3 Name, @{N="MemoryMB"; E={[math]::Round($_.WorkingSet64 / 1MB)}} |
    Format-Table -AutoSize

# --- Exercise 3: Function Debugging ---
Write-Host "=== Exercise 3: Function Debugging ===" -ForegroundColor Cyan
Write-Output "Bug 1: Missing comma between parameters (after [string]`$Path = '.')"
Write-Output "Bug 2: `$MinSize should be `$MinSizeKB (parameter name mismatch)"
Write-Output "Bug 3: [math]:Round should be [math]::Round (double colon)"

# Fixed version:
function Get-FileReport {
    [CmdletBinding()]
    param(
        [string]$Path = ".",  # Bug 1: Added comma
        [int]$MinSizeKB
    )

    $files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue

    foreach ($file in $files) {
        if ($file.Length / 1KB -gt $MinSizeKB) {  # Bug 2: $MinSize -> $MinSizeKB
            [PSCustomObject]@{
                Name     = $file.Name
                SizeKB   = [math]::Round($file.Length / 1KB, 2)  # Bug 3: : -> ::
                Modified = $file.LastWriteTime
            }
        }
    }
}

Get-FileReport -Path $env:TEMP -MinSizeKB 100 | Select-Object -First 5 | Format-Table

# --- Exercise 4: Error Handling Scenario ---
Write-Host "=== Exercise 4: Safe Config Reader ===" -ForegroundColor Cyan

function Get-ConfigSetting {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Key,

        $DefaultValue = $null
    )

    try {
        if (-not (Test-Path $Path)) {
            Write-Warning "Config file not found: $Path"
            return $DefaultValue
        }

        $content = Get-Content -Path $Path -Raw -ErrorAction Stop
        $config = $content | ConvertFrom-Json -ErrorAction Stop

        $value = $config.$Key
        if ($null -eq $value) {
            Write-Warning "Key '$Key' not found in config"
            return $DefaultValue
        }

        return $value
    }
    catch [System.ArgumentException] {
        Write-Warning "Invalid JSON in $Path"
        return $DefaultValue
    }
    catch {
        Write-Warning "Error reading config: $($_.Exception.Message)"
        return $DefaultValue
    }
}

# Test it
$testConfig = Join-Path $env:TEMP "test-config.json"
@{appName = "TestApp"; port = 8080} | ConvertTo-Json | Set-Content $testConfig

$result1 = Get-ConfigSetting -Path $testConfig -Key "appName"
$result2 = Get-ConfigSetting -Path $testConfig -Key "missingKey" -DefaultValue "fallback"
$result3 = Get-ConfigSetting -Path "nonexistent.json" -Key "any" -DefaultValue "default"

Write-Output "appName: $result1"
Write-Output "missingKey: $result2"
Write-Output "nonexistent: $result3"

Remove-Item $testConfig -Force

# --- Exercise 5: Complete Script ---
Write-Host "`n=== Exercise 5: Complete Server Audit ===" -ForegroundColor Cyan

# Create sample server CSV
$serverCsv = Join-Path $env:TEMP "servers-audit.csv"
@(
    [PSCustomObject]@{ServerName=$env:COMPUTERNAME; Role="Web"}
    [PSCustomObject]@{ServerName=$env:COMPUTERNAME; Role="Database"}
    [PSCustomObject]@{ServerName=$env:COMPUTERNAME; Role="App"}
) | Export-Csv -Path $serverCsv -NoTypeInformation

$auditLog = Join-Path $env:TEMP "audit.log"

function Write-AuditLog {
    param([string]$Message)
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
    Add-Content -Path $auditLog -Value $entry
}

Write-AuditLog "Audit started"

$servers = Import-Csv $serverCsv
$results = @()

foreach ($server in $servers) {
    Write-AuditLog "Checking $($server.ServerName) ($($server.Role))"

    try {
        $disk = Get-PSDrive -Name C -ErrorAction Stop
        $diskTotal = $disk.Used + $disk.Free
        $diskPct = [math]::Round(($disk.Used / $diskTotal) * 100, 1)

        $os = Get-CimInstance Win32_OperatingSystem
        $memPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)

        $status = if ($diskPct -ge 90 -or $memPct -ge 90) { "Critical" }
                  elseif ($diskPct -ge 75 -or $memPct -ge 80) { "Warning" }
                  else { "Healthy" }

        $results += [PSCustomObject]@{
            Server      = $server.ServerName
            Role        = $server.Role
            DiskPercent = $diskPct
            MemPercent  = $memPct
            Status      = $status
        }

        Write-AuditLog "$($server.ServerName): Disk=$diskPct%, Mem=$memPct%, Status=$status"
    } catch {
        Write-AuditLog "ERROR checking $($server.ServerName): $($_.Exception.Message)"
    }
}

# Display
$results | Format-Table -AutoSize

# Filter warnings
$warnings = $results | Where-Object { $_.Status -ne "Healthy" }
if ($warnings) {
    Write-Host "Servers with warnings:" -ForegroundColor Yellow
    $warnings | Format-Table -AutoSize
}

# Export
$results | Export-Csv -Path (Join-Path $env:TEMP "audit-results.csv") -NoTypeInformation
$results | ConvertTo-Json | Set-Content (Join-Path $env:TEMP "audit-results.json")

Write-AuditLog "Audit complete. $($results.Count) servers checked."
Write-Output "Audit complete. Log: $auditLog"

# Cleanup
Remove-Item $serverCsv, $auditLog, (Join-Path $env:TEMP "audit-results.*") -Force -ErrorAction SilentlyContinue
