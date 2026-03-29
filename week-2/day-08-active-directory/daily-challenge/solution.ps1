# =============================================================================
# Day 8 Daily Challenge — AD User Onboarding (Solution)
# =============================================================================

Write-Host "===== User Onboarding Automation =====" -ForegroundColor Cyan

$logFile = Join-Path $PSScriptRoot "onboarding-$(Get-Date -Format 'yyyy-MM-dd').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $entry = "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $logFile -Value $entry
}

# Department-to-group mapping
$deptGroups = @{
    "IT"        = @("IT-Staff", "VPN-Users")
    "HR"        = @("HR-Staff")
    "Finance"   = @("Finance-Staff")
    "Marketing" = @("Marketing-Staff")
}

# Simulate existing accounts
$existingUsers = [System.Collections.ArrayList]@("jdoe", "jsmith", "bwilson", "abrown", "cdavis")

function New-Username {
    param(
        [string]$FirstName,
        [string]$LastName
    )

    $base = ($FirstName.Substring(0,1) + $LastName).ToLower() -replace '[^a-z0-9]', ''
    $candidate = $base

    $counter = 2
    while ($existingUsers -contains $candidate) {
        $candidate = "$base$counter"
        $counter++
    }

    $candidate
}

function New-TempPassword {
    param([int]$Length = 16)
    $chars = "abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#$%"
    -join (1..$Length | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

# Read CSV
$newHires = Import-Csv -Path (Join-Path $PSScriptRoot "new-hires.csv")
Write-Host "`nProcessing new-hires.csv ($($newHires.Count) new hires)...`n"
Write-Log "Starting onboarding for $($newHires.Count) new hires"

$results = @()
$index = 1

foreach ($hire in $newHires) {
    try {
        # Generate username
        $username = New-Username -FirstName $hire.FirstName -LastName $hire.LastName
        $tempPassword = New-TempPassword

        # Determine groups
        $groups = @("All-Employees")
        if ($deptGroups.ContainsKey($hire.Department)) {
            $groups += $deptGroups[$hire.Department]
        }

        # Simulate creation
        $existingUsers.Add($username) | Out-Null

        Write-Host "  [$index/$($newHires.Count)] $($hire.FirstName) $($hire.LastName) -> $username ($($hire.Department) - $($hire.Title))" -ForegroundColor White
        Write-Host "        Groups: $($groups -join ', ')" -ForegroundColor Gray
        Write-Host "        Status: CREATED" -ForegroundColor Green

        Write-Log "Created: $username ($($hire.FirstName) $($hire.LastName)) Dept=$($hire.Department)"

        $results += [PSCustomObject]@{
            Username    = $username
            FullName    = "$($hire.FirstName) $($hire.LastName)"
            Department  = $hire.Department
            Title       = $hire.Title
            Manager     = $hire.Manager
            StartDate   = $hire.StartDate
            Groups      = $groups -join "; "
            TempPassword = $tempPassword
            Status      = "Created"
            Error       = ""
        }
    }
    catch {
        Write-Host "  [$index/$($newHires.Count)] $($hire.FirstName) $($hire.LastName) - FAILED" -ForegroundColor Red
        Write-Log "FAILED: $($hire.FirstName) $($hire.LastName) - $($_.Exception.Message)" -Level "ERROR"

        $results += [PSCustomObject]@{
            Username = "N/A"; FullName = "$($hire.FirstName) $($hire.LastName)"
            Department = $hire.Department; Title = $hire.Title; Manager = $hire.Manager
            StartDate = $hire.StartDate; Groups = ""; TempPassword = ""
            Status = "Failed"; Error = $_.Exception.Message
        }
    }

    $index++
}

# Summary
$created = ($results | Where-Object Status -eq "Created").Count
$failed = ($results | Where-Object Status -eq "Failed").Count

Write-Host "`n===== Onboarding Summary =====" -ForegroundColor Cyan
Write-Host "  Total:   $($results.Count)"
Write-Host "  Created: $created" -ForegroundColor Green
Write-Host "  Failed:  $failed" -ForegroundColor $(if ($failed -gt 0) {"Red"} else {"Green"})

# Export
$reportPath = Join-Path $PSScriptRoot "onboarding-report-$(Get-Date -Format 'yyyy-MM-dd').csv"
$results | Export-Csv -Path $reportPath -NoTypeInformation
Write-Host "`n  Report saved to: $reportPath"
Write-Host "  Log saved to: $logFile"
Write-Log "Onboarding complete: $created created, $failed failed"
