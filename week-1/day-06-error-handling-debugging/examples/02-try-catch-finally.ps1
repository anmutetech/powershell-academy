# =============================================================================
# Day 6 — try/catch/finally
# =============================================================================

# --- Basic try/catch ---
Write-Host "=== Basic Try/Catch ===" -ForegroundColor Cyan
try {
    $result = 10 / 0
} catch {
    Write-Output "Error: $($_.Exception.Message)"
}

# --- Catch specific exception types ---
Write-Host "`n=== Typed Catch Blocks ===" -ForegroundColor Cyan
try {
    [int]::Parse("not-a-number")
} catch [System.FormatException] {
    Write-Output "Format error: Cannot parse to integer"
} catch [System.OverflowException] {
    Write-Output "Overflow: Number too large"
} catch {
    Write-Output "Other error: $($_.Exception.Message)"
}

# --- Inspecting the error record ---
Write-Host "`n=== Error Record Details ===" -ForegroundColor Cyan
try {
    Get-Content "C:\nonexistent\file.txt" -ErrorAction Stop
} catch {
    Write-Output "Message:     $($_.Exception.Message)"
    Write-Output "Type:        $($_.Exception.GetType().FullName)"
    Write-Output "Category:    $($_.CategoryInfo.Category)"
    Write-Output "Target:      $($_.TargetObject)"
    Write-Output "Script Line: $($_.InvocationInfo.ScriptLineNumber)"
    Write-Output "Stack Trace:"
    Write-Output $_.ScriptStackTrace
}

# --- finally block ---
Write-Host "`n=== Finally Block ===" -ForegroundColor Cyan
$tempFile = Join-Path $env:TEMP "finally-demo.txt"

try {
    "Important data" | Set-Content $tempFile
    Write-Output "File created: $tempFile"
    # Simulate an error
    throw "Something went wrong during processing"
} catch {
    Write-Output "Error caught: $($_.Exception.Message)"
} finally {
    # Cleanup always runs
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
        Write-Output "Temp file cleaned up in finally block"
    }
}

# --- Nested try/catch ---
Write-Host "`n=== Nested Try/Catch ===" -ForegroundColor Cyan
try {
    Write-Output "Outer try: Starting process"
    try {
        Write-Output "Inner try: Connecting to database"
        throw "Connection refused"
    } catch {
        Write-Output "Inner catch: $($_.Exception.Message)"
        Write-Output "Inner catch: Falling back to cache"
    }
    Write-Output "Outer try: Continuing with cached data"
} catch {
    Write-Output "Outer catch: $($_.Exception.Message)"
}

# --- throw and re-throw ---
Write-Host "`n=== Throw and Re-throw ===" -ForegroundColor Cyan
function Get-CriticalData {
    try {
        Get-Content "missing-critical.dat" -ErrorAction Stop
    } catch {
        # Log it, then re-throw
        Write-Warning "Failed to load critical data"
        throw  # Re-throws the same error
    }
}

try {
    Get-CriticalData
} catch {
    Write-Output "Caller caught: $($_.Exception.Message)"
}
