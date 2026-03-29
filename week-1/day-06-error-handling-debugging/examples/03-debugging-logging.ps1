# =============================================================================
# Day 6 — Debugging and Logging
# =============================================================================

# === Logging Function ===
Write-Host "=== Logging ===" -ForegroundColor Cyan

$logFile = Join-Path $env:TEMP "ps-academy-debug.log"

function Write-Log {
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $entry

    $color = switch ($Level) {
        "INFO"  { "White" }
        "WARN"  { "Yellow" }
        "ERROR" { "Red" }
        "DEBUG" { "Gray" }
    }
    Write-Host $entry -ForegroundColor $color
}

# Demo logging
Write-Log "Application starting"
Write-Log "Loading configuration"
Write-Log "Config file not found, using defaults" -Level "WARN"
Write-Log "Processing 100 records"
Write-Log "Record 55 has invalid format" -Level "ERROR"
Write-Log "Processing complete"

# === Write-Debug and Write-Verbose ===
Write-Host "`n=== Debug and Verbose Output ===" -ForegroundColor Cyan

function Process-DataSet {
    [CmdletBinding()]
    param(
        [string[]]$Items
    )

    Write-Verbose "Starting data processing with $($Items.Count) items"

    foreach ($item in $Items) {
        Write-Debug "Current item: '$item' (Length: $($item.Length))"

        if ($item.Length -lt 3) {
            Write-Verbose "Skipping short item: '$item'"
            continue
        }

        Write-Output $item.ToUpper()
    }

    Write-Verbose "Processing complete"
}

# Normal run (debug/verbose hidden)
Write-Host "Normal run:" -ForegroundColor Yellow
Process-DataSet -Items "hi", "hello", "ab", "world"

# Verbose run
Write-Host "`nVerbose run:" -ForegroundColor Yellow
Process-DataSet -Items "hi", "hello", "ab", "world" -Verbose

# === Retry Pattern ===
Write-Host "`n=== Retry Pattern ===" -ForegroundColor Cyan

function Invoke-WithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,

        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 1
    )

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        try {
            Write-Verbose "Attempt $attempt of $MaxAttempts"
            $result = & $ScriptBlock
            Write-Verbose "Success on attempt $attempt"
            return $result
        } catch {
            Write-Log "Attempt $attempt failed: $($_.Exception.Message)" -Level "WARN"
            if ($attempt -eq $MaxAttempts) {
                Write-Log "All $MaxAttempts attempts failed" -Level "ERROR"
                throw
            }
            $delay = $DelaySeconds * $attempt
            Write-Verbose "Waiting $delay seconds before retry..."
            Start-Sleep -Seconds $delay
        }
    }
}

# Demo retry (will fail all attempts)
try {
    Invoke-WithRetry -ScriptBlock {
        Get-Content "totally-fake-file.txt" -ErrorAction Stop
    } -MaxAttempts 3 -DelaySeconds 1 -Verbose
} catch {
    Write-Log "Retry demo completed (expected failure)" -Level "INFO"
}

# === Error Summary Report ===
Write-Host "`n=== Error Summary ===" -ForegroundColor Cyan

$Error.Clear()
Get-Item "fake1.txt" -ErrorAction SilentlyContinue
Get-Service "FakeService" -ErrorAction SilentlyContinue
[int]::Parse("nope") 2>$null

Write-Output "Errors in this session: $($Error.Count)"
foreach ($err in $Error) {
    Write-Output "  - [$($err.Exception.GetType().Name)] $($err.Exception.Message)"
}

# Cleanup
Remove-Item $logFile -Force -ErrorAction SilentlyContinue
