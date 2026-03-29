# =============================================================================
# Day 12 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Password Policy Checker ---
Write-Host "=== Exercise 1: Password Checker ===" -ForegroundColor Cyan

function Test-PasswordComplexity {
    param(
        [Parameter(Mandatory)]
        [string]$Password,
        [int]$MinLength = 12
    )

    $commonPasswords = @("password", "password123", "admin123", "qwerty", "letmein", "welcome1")

    $rules = @(
        [PSCustomObject]@{Rule="Minimum Length ($MinLength)";Pass=$Password.Length -ge $MinLength}
        [PSCustomObject]@{Rule="Has Uppercase";Pass=$Password -cmatch "[A-Z]"}
        [PSCustomObject]@{Rule="Has Lowercase";Pass=$Password -cmatch "[a-z]"}
        [PSCustomObject]@{Rule="Has Number";Pass=$Password -match "\d"}
        [PSCustomObject]@{Rule="Has Special Char";Pass=$Password -match "[!@#$%^&*()_+\-=\[\]{};':,.<>?]"}
        [PSCustomObject]@{Rule="Not Common Password";Pass=$Password.ToLower() -notin $commonPasswords}
    )

    $passedCount = ($rules | Where-Object Pass).Count
    $totalRules = $rules.Count

    [PSCustomObject]@{
        Score   = "$passedCount/$totalRules"
        Percent = [math]::Round(($passedCount / $totalRules) * 100)
        Status  = if ($passedCount -eq $totalRules) { "COMPLIANT" } else { "NON-COMPLIANT" }
        Details = $rules
    }
}

$result = Test-PasswordComplexity -Password "MyS3cure!Pass"
Write-Output "Score: $($result.Score) ($($result.Percent)%) - $($result.Status)"
$result.Details | ForEach-Object {
    $icon = if ($_.Pass) { "[PASS]" } else { "[FAIL]" }
    $color = if ($_.Pass) { "Green" } else { "Red" }
    Write-Host "  $icon $($_.Rule)" -ForegroundColor $color
}

# --- Exercise 2: File Integrity Monitor ---
Write-Host "`n=== Exercise 2: File Integrity ===" -ForegroundColor Cyan

function New-FileBaseline {
    param([string]$Path)

    Get-ChildItem $Path -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
        [PSCustomObject]@{
            Path     = $_.FullName
            Hash     = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
            Size     = $_.Length
            Modified = $_.LastWriteTime.ToString("o")
        }
    }
}

function Compare-FileBaseline {
    param(
        [PSCustomObject[]]$Baseline,
        [string]$Path
    )

    $current = New-FileBaseline -Path $Path
    $changes = @{New=@();Deleted=@();Modified=@()}

    $baselineMap = @{}
    $Baseline | ForEach-Object { $baselineMap[$_.Path] = $_ }

    $currentMap = @{}
    $current | ForEach-Object { $currentMap[$_.Path] = $_ }

    # New files
    $current | Where-Object { -not $baselineMap.ContainsKey($_.Path) } | ForEach-Object { $changes.New += $_.Path }

    # Deleted files
    $Baseline | Where-Object { -not $currentMap.ContainsKey($_.Path) } | ForEach-Object { $changes.Deleted += $_.Path }

    # Modified files
    $Baseline | Where-Object {
        $currentMap.ContainsKey($_.Path) -and $currentMap[$_.Path].Hash -ne $_.Hash
    } | ForEach-Object { $changes.Modified += $_.Path }

    $changes
}

# Demo
$demoDir = Join-Path $env:TEMP "fim-demo"
New-Item $demoDir -ItemType Directory -Force | Out-Null
"File1" | Set-Content (Join-Path $demoDir "a.txt")
"File2" | Set-Content (Join-Path $demoDir "b.txt")

$baseline = New-FileBaseline -Path $demoDir
Write-Output "Baseline: $($baseline.Count) files"

# Modify
"Modified" | Set-Content (Join-Path $demoDir "a.txt")
"NewFile" | Set-Content (Join-Path $demoDir "c.txt")

$changes = Compare-FileBaseline -Baseline $baseline -Path $demoDir
Write-Output "New: $($changes.New.Count), Modified: $($changes.Modified.Count), Deleted: $($changes.Deleted.Count)"
Remove-Item $demoDir -Recurse -Force

# --- Exercise 3: Security Event Monitor ---
Write-Host "`n=== Exercise 3: Event Monitor ===" -ForegroundColor Cyan

# Simulated security events
$events = @(
    [PSCustomObject]@{Time=(Get-Date).AddMinutes(-5);Type="FailedLogin";Account="admin";SourceIP="192.168.1.100"}
    [PSCustomObject]@{Time=(Get-Date).AddMinutes(-4);Type="FailedLogin";Account="admin";SourceIP="192.168.1.100"}
    [PSCustomObject]@{Time=(Get-Date).AddMinutes(-3);Type="FailedLogin";Account="admin";SourceIP="192.168.1.100"}
    [PSCustomObject]@{Time=(Get-Date).AddMinutes(-3);Type="FailedLogin";Account="admin";SourceIP="192.168.1.100"}
    [PSCustomObject]@{Time=(Get-Date).AddMinutes(-2);Type="FailedLogin";Account="admin";SourceIP="192.168.1.100"}
    [PSCustomObject]@{Time=(Get-Date).AddMinutes(-1);Type="FailedLogin";Account="admin";SourceIP="192.168.1.100"}
    [PSCustomObject]@{Time=(Get-Date).AddMinutes(-8);Type="FailedLogin";Account="user1";SourceIP="10.0.0.50"}
    [PSCustomObject]@{Time=(Get-Date).AddMinutes(-1);Type="SuccessLogin";Account="admin";SourceIP="192.168.1.100"}
)

# Detect brute force (>5 failures in 10 min from same IP)
$grouped = $events | Where-Object Type -eq "FailedLogin" |
    Group-Object SourceIP

$alerts = $grouped | Where-Object Count -ge 5 | ForEach-Object {
    [PSCustomObject]@{
        SourceIP    = $_.Name
        Attempts    = $_.Count
        Accounts    = ($_.Group.Account | Sort-Object -Unique) -join ", "
        Alert       = "BRUTE FORCE DETECTED"
    }
}

if ($alerts) {
    Write-Host "ALERTS:" -ForegroundColor Red
    $alerts | Format-Table -AutoSize
}

# --- Exercise 4: Compliance Scanner ---
Write-Host "=== Exercise 4: Compliance Scanner ===" -ForegroundColor Cyan

$checks = @(
    [PSCustomObject]@{Check="Execution Policy";Pass=(Get-ExecutionPolicy) -in "RemoteSigned","AllSigned";Weight=15}
    [PSCustomObject]@{Check="PS Version 7+";Pass=$PSVersionTable.PSVersion.Major -ge 7;Weight=10}
    [PSCustomObject]@{Check="Running as Non-Admin";Pass=-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator);Weight=10}
    [PSCustomObject]@{Check="TEMP dir exists";Pass=Test-Path $env:TEMP;Weight=5}
)

$totalWeight = ($checks | Measure-Object Weight -Sum).Sum
$passedWeight = ($checks | Where-Object Pass | Measure-Object Weight -Sum).Sum
$score = [math]::Round(($passedWeight / $totalWeight) * 100)

$checks | ForEach-Object {
    $icon = if ($_.Pass) { "PASS" } else { "FAIL" }
    $color = if ($_.Pass) { "Green" } else { "Red" }
    Write-Host ("  [{0}] {1} (weight: {2})" -f $icon, $_.Check, $_.Weight) -ForegroundColor $color
}
Write-Host "`nCompliance Score: $score%" -ForegroundColor $(if ($score -ge 80) {"Green"} else {"Red"})

# --- Exercise 5: Secure Template ---
Write-Host "`n=== Exercise 5: Secure Script Template ===" -ForegroundColor Cyan
Write-Output @"
  A secure script template should include:
  1. Set-StrictMode -Version Latest
  2. `$ErrorActionPreference = "Stop"
  3. No hardcoded credentials
  4. Input validation on all parameters
  5. try/catch around all external operations
  6. Logging that never logs sensitive data
  7. Cleanup in finally blocks
"@
