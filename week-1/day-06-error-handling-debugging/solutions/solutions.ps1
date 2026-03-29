# =============================================================================
# Day 6 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Safe File Reader ---
Write-Host "=== Exercise 1: Safe File Reader ===" -ForegroundColor Cyan

function Read-FileSafely {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    try {
        $content = Get-Content -Path $Path -ErrorAction Stop
        [PSCustomObject]@{
            Success = $true
            Path    = $Path
            Content = $content
            Error   = $null
        }
    }
    catch [System.Management.Automation.ItemNotFoundException] {
        [PSCustomObject]@{
            Success = $false
            Path    = $Path
            Content = $null
            Error   = "File not found: $Path"
        }
    }
    catch [System.UnauthorizedAccessException] {
        [PSCustomObject]@{
            Success = $false
            Path    = $Path
            Content = $null
            Error   = "Access denied: $Path"
        }
    }
    catch {
        [PSCustomObject]@{
            Success = $false
            Path    = $Path
            Content = $null
            Error   = "Unexpected error: $($_.Exception.Message)"
        }
    }
}

Read-FileSafely -Path "C:\nonexistent-file.txt"
Read-FileSafely -Path $PROFILE | Select-Object Success, Path, Error

# --- Exercise 2: Input Validator ---
Write-Host "`n=== Exercise 2: Input Validator ===" -ForegroundColor Cyan

function Test-UserInput {
    [CmdletBinding()]
    param(
        [string]$Email,
        [string]$Port,
        [string]$Date
    )

    $results = @()

    # Email
    if ($Email) {
        $isValid = $Email -match '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        $results += [PSCustomObject]@{
            Field = "Email"; Value = $Email
            IsValid = $isValid
            ErrorMessage = if (-not $isValid) { "Invalid email format" } else { $null }
        }
    }

    # Port
    if ($Port) {
        try {
            $portNum = [int]$Port
            if ($portNum -lt 1 -or $portNum -gt 65535) {
                throw [System.ArgumentOutOfRangeException]::new("Port must be 1-65535")
            }
            $results += [PSCustomObject]@{
                Field = "Port"; Value = $portNum; IsValid = $true; ErrorMessage = $null
            }
        } catch {
            $results += [PSCustomObject]@{
                Field = "Port"; Value = $Port; IsValid = $false
                ErrorMessage = $_.Exception.Message
            }
        }
    }

    # Date
    if ($Date) {
        try {
            $parsed = [datetime]::Parse($Date)
            $results += [PSCustomObject]@{
                Field = "Date"; Value = $parsed.ToString("yyyy-MM-dd"); IsValid = $true; ErrorMessage = $null
            }
        } catch {
            $results += [PSCustomObject]@{
                Field = "Date"; Value = $Date; IsValid = $false; ErrorMessage = "Invalid date format"
            }
        }
    }

    $results
}

Test-UserInput -Email "test@example.com" -Port "8080" -Date "2026-03-15" | Format-Table
Test-UserInput -Email "invalid" -Port "99999" -Date "not-a-date" | Format-Table

# --- Exercise 3: Error Logger ---
Write-Host "=== Exercise 3: Error Logger ===" -ForegroundColor Cyan

function Write-ErrorLog {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [string]$Path = (Join-Path $env:TEMP "error-log.txt"),
        [switch]$Append
    )

    begin {
        if (-not $Append -and (Test-Path $Path)) {
            Remove-Item $Path -Force
        }
    }

    process {
        if ($null -eq $ErrorRecord) { return }

        $entry = @"
=== Error at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") ===
Message:    $($ErrorRecord.Exception.Message)
Type:       $($ErrorRecord.Exception.GetType().FullName)
Line:       $($ErrorRecord.InvocationInfo.ScriptLineNumber)
Command:    $($ErrorRecord.InvocationInfo.MyCommand)
StackTrace: $($ErrorRecord.ScriptStackTrace)

"@
        Add-Content -Path $Path -Value $entry
    }

    end {
        Write-Verbose "Errors logged to: $Path"
    }
}

# Generate some errors then log them
$Error.Clear()
Get-Item "fake.txt" -ErrorAction SilentlyContinue
Get-Service "FakeService" -ErrorAction SilentlyContinue

$logPath = Join-Path $env:TEMP "demo-errors.log"
$Error | Write-ErrorLog -Path $logPath -Verbose
Write-Output "Logged $($Error.Count) errors to $logPath"
Get-Content $logPath -Head 10
Remove-Item $logPath -Force

# --- Exercise 4: Graceful Service Restart ---
Write-Host "`n=== Exercise 4: Graceful Service Restart ===" -ForegroundColor Cyan

function Restart-ServiceSafely {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ServiceName,

        [int]$TimeoutSeconds = 30
    )

    # Check service exists
    $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($null -eq $svc) {
        Write-Warning "Service '$ServiceName' not found"
        return [PSCustomObject]@{ Service = $ServiceName; Status = "NotFound"; Success = $false }
    }

    Write-Verbose "Service found: $($svc.DisplayName) (Status: $($svc.Status))"

    try {
        # Stop
        if ($svc.Status -eq "Running") {
            Write-Verbose "Stopping $ServiceName..."
            Stop-Service -Name $ServiceName -Force -ErrorAction Stop
            $svc.WaitForStatus("Stopped", [TimeSpan]::FromSeconds($TimeoutSeconds))
            Write-Verbose "Service stopped"
        }

        # Start
        Write-Verbose "Starting $ServiceName..."
        Start-Service -Name $ServiceName -ErrorAction Stop
        $svc.WaitForStatus("Running", [TimeSpan]::FromSeconds($TimeoutSeconds))
        Write-Verbose "Service running"

        [PSCustomObject]@{ Service = $ServiceName; Status = "Running"; Success = $true }
    }
    catch {
        Write-Error "Failed to restart $ServiceName`: $($_.Exception.Message)"
        [PSCustomObject]@{ Service = $ServiceName; Status = "Error"; Success = $false }
    }
    finally {
        $finalStatus = (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).Status
        Write-Verbose "Final status of $ServiceName`: $finalStatus"
    }
}

# Demo (uses Spooler which is safe to restart)
# Restart-ServiceSafely -ServiceName "Spooler" -Verbose
Write-Output "(Skipping actual restart — uncomment to test with a real service)"
Restart-ServiceSafely -ServiceName "FakeService123" -Verbose

# --- Exercise 5: Defensive Script (wrapped calculator) ---
Write-Host "`n=== Exercise 5: Defensive Calculator ===" -ForegroundColor Cyan

function Invoke-SafeCalculation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Expression
    )

    if ([string]::IsNullOrWhiteSpace($Expression)) {
        throw "Expression cannot be empty"
    }

    if ($Expression -notmatch '^\s*-?\d+(\.\d+)?\s*[+\-*/]\s*-?\d+(\.\d+)?\s*$') {
        throw "Invalid expression format. Use: number operator number (e.g., '5 + 3')"
    }

    try {
        $result = Invoke-Expression $Expression
        Write-Verbose "Calculated: $Expression = $result"
        [PSCustomObject]@{
            Expression = $Expression
            Result     = $result
            Success    = $true
            Error      = $null
        }
    } catch {
        [PSCustomObject]@{
            Expression = $Expression
            Result     = $null
            Success    = $false
            Error      = $_.Exception.Message
        }
    }
}

Invoke-SafeCalculation -Expression "10 + 5" -Verbose
Invoke-SafeCalculation -Expression "100 / 4"
try { Invoke-SafeCalculation -Expression "DROP TABLE" } catch { Write-Output "Caught: $_" }
