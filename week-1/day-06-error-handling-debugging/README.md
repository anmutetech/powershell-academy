# Day 6 — Error Handling & Debugging

Production scripts must handle errors gracefully. Today you learn try/catch/finally, error actions, error records, and debugging techniques that separate amateur scripts from production-ready automation.

---

## Video Resources

- [PowerShell Error Handling](https://www.youtube.com/watch?v=wiajkWfGNAg)
- [PowerShell Try Catch Finally](https://www.youtube.com/watch?v=6_Mqpx4hMf4)
- [PowerShell for Beginners Playlist](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) — Episodes 15-16

---

## 1. Terminating vs Non-Terminating Errors

PowerShell has two types of errors:

| Type | Behavior | Example |
|------|----------|---------|
| **Terminating** | Stops execution | `throw`, divide by zero, type cast failures |
| **Non-Terminating** | Continues to next command | `Get-Item` on a missing file, `Get-Service` with bad name |

**Key insight:** `try/catch` only catches **terminating** errors by default. To catch non-terminating errors, use `-ErrorAction Stop`.

```powershell
# This does NOT get caught (non-terminating)
try {
    Get-Item "C:\nonexistent.txt"   # Error, but continues
    Write-Output "This still runs"
} catch {
    Write-Output "Caught!"          # Never reaches here
}

# This DOES get caught (forced to terminating)
try {
    Get-Item "C:\nonexistent.txt" -ErrorAction Stop
} catch {
    Write-Output "Caught: $($_.Exception.Message)"
}
```

## 2. -ErrorAction Parameter

Every cmdlet supports `-ErrorAction`:

| Value | Behavior |
|-------|----------|
| `Continue` | Show error, keep going (default) |
| `Stop` | Convert to terminating error (catchable) |
| `SilentlyContinue` | Suppress error, keep going |
| `Ignore` | Suppress error completely (not even in $Error) |

```powershell
# Suppress errors silently
$svc = Get-Service -Name "FakeService" -ErrorAction SilentlyContinue

# Set default for entire script
$ErrorActionPreference = "Stop"   # Now all errors are terminating
```

## 3. try / catch / finally

```powershell
try {
    # Code that might fail
    $data = Get-Content -Path ".\important.txt" -ErrorAction Stop
    $parsed = $data | ConvertFrom-Json
    Write-Output "Data loaded successfully"
}
catch [System.IO.FileNotFoundException] {
    # Handle specific exception type
    Write-Warning "File not found: $($_.Exception.Message)"
}
catch [System.InvalidOperationException] {
    Write-Warning "Invalid operation: $($_.Exception.Message)"
}
catch {
    # Catch-all for any other errors
    Write-Error "Unexpected error: $($_.Exception.Message)"
}
finally {
    # Always runs — cleanup code
    Write-Verbose "Operation complete (success or failure)"
}
```

### The Error Record ($_)

Inside a `catch` block, `$_` is an **ErrorRecord** object with rich information:

```powershell
try {
    1/0
} catch {
    Write-Output "Message:    $($_.Exception.Message)"
    Write-Output "Type:       $($_.Exception.GetType().FullName)"
    Write-Output "Line:       $($_.InvocationInfo.ScriptLineNumber)"
    Write-Output "Command:    $($_.InvocationInfo.MyCommand)"
    Write-Output "StackTrace: $($_.ScriptStackTrace)"
}
```

## 4. throw and Custom Errors

```powershell
# Simple throw
function Get-UserData {
    param([string]$Username)

    if ([string]::IsNullOrEmpty($Username)) {
        throw "Username cannot be empty"
    }

    # ... lookup user
}

# Throw specific exception types
function Set-Port {
    param([int]$Port)

    if ($Port -lt 1 -or $Port -gt 65535) {
        throw [System.ArgumentOutOfRangeException]::new(
            "Port", $Port, "Port must be between 1 and 65535"
        )
    }
}
```

## 5. $Error Automatic Variable

PowerShell stores all recent errors in the `$Error` array:

```powershell
$Error.Clear()          # Clear error history
Get-Item "nope.txt" -ErrorAction SilentlyContinue

$Error.Count            # 1
$Error[0]               # Most recent error
$Error[0].Exception     # The exception object
```

## 6. Logging Errors

```powershell
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] $Message"
    Add-Content -Path ".\script.log" -Value $entry

    switch ($Level) {
        "INFO"  { Write-Host $entry -ForegroundColor Gray }
        "WARN"  { Write-Host $entry -ForegroundColor Yellow }
        "ERROR" { Write-Host $entry -ForegroundColor Red }
    }
}

# Usage
try {
    Write-Log "Starting backup process"
    # ... do work ...
    Write-Log "Backup completed successfully"
} catch {
    Write-Log "Backup failed: $($_.Exception.Message)" -Level "ERROR"
}
```

## 7. Debugging Techniques

### Write-Debug

```powershell
function Process-Data {
    [CmdletBinding()]
    param([string[]]$Items)

    foreach ($item in $Items) {
        Write-Debug "Processing item: $item"
        # ... process ...
    }
}

# Debug messages are hidden by default
Process-Data -Items "a", "b", "c"

# Show debug messages
Process-Data -Items "a", "b", "c" -Debug
```

### Set-PSBreakpoint

```powershell
# Break on a line
Set-PSBreakpoint -Script ".\myscript.ps1" -Line 15

# Break when a variable changes
Set-PSBreakpoint -Variable "counter" -Mode Write

# Break when a command is called
Set-PSBreakpoint -Command "Get-Service"

# List and remove breakpoints
Get-PSBreakpoint
Remove-PSBreakpoint -Id 1
```

### Debugging in VS Code

1. Set breakpoints by clicking the gutter (left of line numbers)
2. Press F5 to start debugging
3. Use the Debug Console to inspect variables
4. Step through with F10 (over) or F11 (into)

## 8. Common Patterns

### Retry with Backoff

```powershell
function Invoke-WithRetry {
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 2
    )

    for ($i = 1; $i -le $MaxAttempts; $i++) {
        try {
            return & $ScriptBlock
        } catch {
            if ($i -eq $MaxAttempts) { throw }
            Write-Warning "Attempt $i failed: $($_.Exception.Message). Retrying in $DelaySeconds seconds..."
            Start-Sleep -Seconds ($DelaySeconds * $i)
        }
    }
}

# Usage
$result = Invoke-WithRetry -ScriptBlock {
    Invoke-RestMethod -Uri "https://api.example.com/data" -TimeoutSec 5
} -MaxAttempts 3
```

### Cleanup with finally

```powershell
$tempFile = [System.IO.Path]::GetTempFileName()
try {
    "Working data" | Set-Content $tempFile
    # ... process temp file ...
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
        Write-Verbose "Temp file cleaned up"
    }
}
```

---

## Key Takeaways

1. Use `-ErrorAction Stop` to make non-terminating errors catchable
2. Always use `try/catch` around external calls (files, network, services)
3. Catch specific exception types before the general `catch`
4. Use `finally` for cleanup that must always run
5. Log errors with timestamps and context — `$_.Exception.Message` is your friend
6. Use `Write-Debug` and `Write-Verbose` instead of `Write-Host` for diagnostic output
7. The `Invoke-WithRetry` pattern is essential for DevOps scripts

---

## Interview Prep

**Q: What is the difference between terminating and non-terminating errors?**
A: Terminating errors stop script execution and can be caught with `try/catch`. Non-terminating errors display an error message but continue execution. Most cmdlet errors are non-terminating. Use `-ErrorAction Stop` to convert non-terminating errors to terminating so they can be caught.

**Q: How do you implement retry logic in PowerShell?**
A: Use a `for` loop with `try/catch` inside. On each failure, check if the max attempts are reached — if so, rethrow; otherwise, `Start-Sleep` with increasing delay (backoff) and retry. This pattern is critical for network operations, API calls, and service checks.

**Q: What is the $Error automatic variable?**
A: `$Error` is an ArrayList that stores all errors that occurred in the session, with `$Error[0]` being the most recent. Each entry is an ErrorRecord object containing the exception, invocation info, and stack trace. Use `$Error.Clear()` to reset it.
