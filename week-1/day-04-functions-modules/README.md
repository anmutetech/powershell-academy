# Day 4 — Functions & Modules

Functions let you package reusable logic. Modules let you share that logic across scripts and teams. Today you learn to write professional-grade functions with parameters, validation, and pipeline support.

---

## Video Resources

- [PowerShell Functions](https://www.youtube.com/watch?v=OSoss1GFHSQ)
- [PowerShell Advanced Functions](https://www.youtube.com/watch?v=NMu1U5FBcBo)
- [PowerShell for Beginners Playlist](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) — Episodes 10-11

---

## 1. Basic Functions

A function is a named block of code you can call repeatedly.

```powershell
function Get-Greeting {
    Write-Output "Hello, World!"
}

Get-Greeting   # Output: Hello, World!
```

### Functions with Parameters

```powershell
function Get-Greeting {
    param(
        [string]$Name
    )
    Write-Output "Hello, $Name!"
}

Get-Greeting -Name "Alice"   # Output: Hello, Alice!
```

### Multiple Parameters with Defaults

```powershell
function New-ServerReport {
    param(
        [string]$ServerName = $env:COMPUTERNAME,
        [int]$TopProcesses = 5
    )

    Write-Output "=== Report for $ServerName ==="
    Get-Process | Sort-Object CPU -Descending |
        Select-Object -First $TopProcesses Name, CPU
}

New-ServerReport                                    # Uses defaults
New-ServerReport -ServerName "WEB01" -TopProcesses 3  # Custom values
```

## 2. Advanced Functions (CmdletBinding)

Adding `[CmdletBinding()]` turns your function into an advanced function with professional features: `-Verbose`, `-WhatIf`, common parameters, and more.

```powershell
function Restart-WebService {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ServiceName,

        [Parameter()]
        [int]$WaitSeconds = 5
    )

    if ($PSCmdlet.ShouldProcess($ServiceName, "Restart service")) {
        Write-Verbose "Stopping $ServiceName..."
        Stop-Service -Name $ServiceName -Force
        Start-Sleep -Seconds $WaitSeconds
        Write-Verbose "Starting $ServiceName..."
        Start-Service -Name $ServiceName
        Write-Output "$ServiceName restarted successfully."
    }
}

# -WhatIf shows what would happen without doing it
Restart-WebService -ServiceName "Spooler" -WhatIf

# -Verbose shows detailed progress
Restart-WebService -ServiceName "Spooler" -Verbose
```

## 3. Parameter Validation

PowerShell has built-in validation attributes so you don't need manual `if` checks.

```powershell
function Set-ServerEnvironment {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ServerName,

        [Parameter(Mandatory)]
        [ValidateSet("Development", "Staging", "Production")]
        [string]$Environment,

        [ValidateRange(1, 65535)]
        [int]$Port = 8080,

        [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')]
        [string]$AdminEmail
    )

    Write-Output "Server: $ServerName | Env: $Environment | Port: $Port"
}

# These work:
Set-ServerEnvironment -ServerName "web01" -Environment "Production"
Set-ServerEnvironment -ServerName "web01" -Environment "Staging" -Port 3000

# These fail with helpful errors:
# Set-ServerEnvironment -ServerName "web01" -Environment "Testing"   # Not in ValidateSet
# Set-ServerEnvironment -ServerName "web01" -Environment "Production" -Port 0  # Out of range
```

### Common Validation Attributes

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `[ValidateNotNullOrEmpty()]` | Must have a value | Strings, arrays |
| `[ValidateSet()]` | Must be one of listed values | Environment names |
| `[ValidateRange()]` | Must be within min-max | Port numbers, counts |
| `[ValidatePattern()]` | Must match regex | Email, IP addresses |
| `[ValidateScript()]` | Must pass custom test | File exists, path valid |
| `[ValidateLength()]` | String length min-max | Usernames |

## 4. Pipeline Input

Functions can accept input from the pipeline using `ValueFromPipeline`.

```powershell
function Test-ServerConnection {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ComputerName
    )

    process {
        $result = Test-Connection -ComputerName $ComputerName -Count 1 -Quiet -ErrorAction SilentlyContinue
        [PSCustomObject]@{
            Server = $ComputerName
            Online = $result
        }
    }
}

# Use via pipeline
"web01", "web02", "db01" | Test-ServerConnection

# Or directly
Test-ServerConnection -ComputerName "web01"
```

**Important:** The `process` block runs once per pipeline item. Without it, only the last piped item is processed.

### Begin / Process / End

```powershell
function ConvertTo-Uppercase {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Text
    )

    begin   { Write-Verbose "Starting conversion..." }
    process { Write-Output $Text.ToUpper() }
    end     { Write-Verbose "Conversion complete." }
}

"hello", "world" | ConvertTo-Uppercase
# Output: HELLO, WORLD
```

## 5. Return Values and Output

PowerShell functions return **everything** that isn't captured or suppressed.

```powershell
function Get-DiskInfo {
    param([string]$Drive = "C")

    $disk = Get-PSDrive -Name $Drive
    [PSCustomObject]@{
        Drive     = "$Drive`:"
        UsedGB    = [math]::Round($disk.Used / 1GB, 2)
        FreeGB    = [math]::Round($disk.Free / 1GB, 2)
        TotalGB   = [math]::Round(($disk.Used + $disk.Free) / 1GB, 2)
    }
}

$info = Get-DiskInfo -Drive "C"
$info | Format-Table
```

**Tip:** Use `[PSCustomObject]` for structured output. Avoid `Write-Host` for data — it can't be captured. Use `Write-Output` or just let the value fall through.

## 6. Modules Basics

A module is a package of related functions. The simplest module is a `.psm1` file.

```powershell
# Save as: MyServerTools.psm1

function Get-ServerUptime {
    param([string]$ComputerName = $env:COMPUTERNAME)
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
    $uptime = (Get-Date) - $os.LastBootUpTime
    [PSCustomObject]@{
        Computer = $ComputerName
        Days     = $uptime.Days
        Hours    = $uptime.Hours
        Minutes  = $uptime.Minutes
    }
}

function Get-DiskSpace {
    param([string]$ComputerName = $env:COMPUTERNAME)
    Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ComputerName -Filter "DriveType=3" |
        Select-Object DeviceID,
            @{Name="SizeGB"; Expression={[math]::Round($_.Size / 1GB, 2)}},
            @{Name="FreeGB"; Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}
}
```

### Using Modules

```powershell
# Import a module file
Import-Module .\MyServerTools.psm1

# Use the functions
Get-ServerUptime
Get-DiskSpace

# See what's in the module
Get-Command -Module MyServerTools

# Remove when done
Remove-Module MyServerTools
```

## 7. Scope

Variables have scope — where they're visible.

```powershell
$globalVar = "I'm global"

function Test-Scope {
    $localVar = "I'm local"
    Write-Output "Inside function: $globalVar"   # Can see global
    Write-Output "Inside function: $localVar"    # Can see local
}

Test-Scope
Write-Output "Outside function: $globalVar"     # Works
Write-Output "Outside function: $localVar"      # Empty — local is gone
```

**Best practice:** Don't modify global variables inside functions. Pass data in via parameters and return results via output.

---

## Key Takeaways

1. Use `param()` blocks for function parameters — not positional arguments
2. Add `[CmdletBinding()]` to every serious function for `-Verbose`, `-WhatIf` support
3. Use validation attributes instead of manual `if` checks
4. Use `ValueFromPipeline` and a `process` block for pipeline-capable functions
5. Return structured `[PSCustomObject]` data, not formatted strings
6. Package related functions into `.psm1` modules for reuse

---

## Interview Prep

**Q: What is the difference between a basic function and an advanced function in PowerShell?**
A: A basic function is a simple named script block. An advanced function uses `[CmdletBinding()]` which adds support for common parameters like `-Verbose`, `-Debug`, `-ErrorAction`, `-WhatIf`, and `-Confirm`. It also enables parameter validation attributes and better pipeline support.

**Q: How do you make a function accept pipeline input?**
A: Add `[Parameter(ValueFromPipeline)]` to the parameter and put your logic in a `process` block. The `process` block runs once per pipeline item. Without it, only the last item is processed.

**Q: What is the difference between Write-Output and Write-Host?**
A: `Write-Output` sends data to the pipeline — it can be captured in a variable, piped to another command, or redirected. `Write-Host` writes directly to the console — it cannot be captured or piped. Use `Write-Output` (or just let values fall through) for data, and `Write-Host` only for user-facing messages like progress or formatting.
