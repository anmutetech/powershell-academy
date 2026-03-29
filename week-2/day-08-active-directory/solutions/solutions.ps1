# =============================================================================
# Day 8 — Exercise Solutions
# =============================================================================

# Shared simulated AD data
$script:adUsers = @(
    [PSCustomObject]@{Name="John Doe";SamAccountName="jdoe";Department="IT";Title="DevOps Engineer";Enabled=$true;LastLogonDate=(Get-Date).AddDays(-5);PasswordLastSet=(Get-Date).AddDays(-45);PasswordNeverExpires=$false;MemberOf=@("IT-Staff","DevOps-Team")}
    [PSCustomObject]@{Name="Jane Smith";SamAccountName="jsmith";Department="HR";Title="Recruiter";Enabled=$true;LastLogonDate=(Get-Date).AddDays(-2);PasswordLastSet=(Get-Date).AddDays(-80);PasswordNeverExpires=$false;MemberOf=@("HR-Staff")}
    [PSCustomObject]@{Name="Bob Wilson";SamAccountName="bwilson";Department="IT";Title="Sysadmin";Enabled=$true;LastLogonDate=(Get-Date).AddDays(-100);PasswordLastSet=(Get-Date).AddDays(-200);PasswordNeverExpires=$true;MemberOf=@("IT-Staff","Domain Admins")}
    [PSCustomObject]@{Name="Alice Brown";SamAccountName="abrown";Department="Finance";Title="Analyst";Enabled=$false;LastLogonDate=(Get-Date).AddDays(-200);PasswordLastSet=(Get-Date).AddDays(-200);PasswordNeverExpires=$false;MemberOf=@("Finance-Staff")}
    [PSCustomObject]@{Name="Charlie Davis";SamAccountName="cdavis";Department="IT";Title="Security Analyst";Enabled=$true;LastLogonDate=(Get-Date).AddDays(-1);PasswordLastSet=(Get-Date).AddDays(-30);PasswordNeverExpires=$false;MemberOf=@("IT-Staff","Security-Team")}
    [PSCustomObject]@{Name="Eve Martinez";SamAccountName="emartinez";Department="Marketing";Title="Manager";Enabled=$true;LastLogonDate=(Get-Date).AddDays(-180);PasswordLastSet=(Get-Date).AddDays(-180);PasswordNeverExpires=$true;MemberOf=@("Marketing-Staff")}
)

# --- Exercise 1: User Lookup ---
Write-Host "=== Exercise 1: User Lookup ===" -ForegroundColor Cyan

function Find-ADUserInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$SearchTerm
    )

    process {
        $script:adUsers | Where-Object {
            $_.Name -like "*$SearchTerm*" -or $_.SamAccountName -like "*$SearchTerm*"
        } | Select-Object Name, SamAccountName, Department, Title, Enabled, LastLogonDate
    }
}

Find-ADUserInfo -SearchTerm "doe" | Format-Table
"IT" | ForEach-Object { $script:adUsers | Where-Object Department -eq $_ } | Select-Object Name, Department | Format-Table

# --- Exercise 2: Bulk User Creator ---
Write-Host "=== Exercise 2: Bulk User Creator ===" -ForegroundColor Cyan

function New-BulkADUsers {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [PSCustomObject[]]$Users,

        [securestring]$DefaultPassword = (ConvertTo-SecureString "Welcome2026!" -AsPlainText -Force)
    )

    $results = @()

    foreach ($user in $Users) {
        try {
            if ($PSCmdlet.ShouldProcess("$($user.FirstName) $($user.LastName)", "Create AD User")) {
                $results += [PSCustomObject]@{
                    Username   = $user.Username
                    Name       = "$($user.FirstName) $($user.LastName)"
                    Department = $user.Department
                    Status     = "Created"
                    Error      = $null
                }
                Write-Verbose "Created: $($user.Username)"
            }
        } catch {
            $results += [PSCustomObject]@{
                Username = $user.Username; Name = "N/A"; Department = $user.Department
                Status = "Failed"; Error = $_.Exception.Message
            }
        }
    }

    $results
}

$hires = @(
    [PSCustomObject]@{FirstName="Tom";LastName="Chen";Username="tchen";Department="IT"}
    [PSCustomObject]@{FirstName="Lisa";LastName="Park";Username="lpark";Department="HR"}
)
New-BulkADUsers -Users $hires -Verbose | Format-Table

# --- Exercise 3: Group Membership Report ---
Write-Host "=== Exercise 3: Group Membership ===" -ForegroundColor Cyan

$allGroups = $script:adUsers.MemberOf | ForEach-Object { $_ } | Sort-Object -Unique

Write-Host "Groups and Members:" -ForegroundColor Yellow
foreach ($group in $allGroups) {
    $members = $script:adUsers | Where-Object { $_.MemberOf -contains $group }
    Write-Output "  $group`: $($members.SamAccountName -join ', ')"
}

Write-Host "`nUsers in Multiple Groups:" -ForegroundColor Yellow
$script:adUsers | Where-Object { $_.MemberOf.Count -gt 1 } | ForEach-Object {
    Write-Output "  $($_.SamAccountName): $($_.MemberOf -join ', ')"
}

# --- Exercise 4: Account Cleanup ---
Write-Host "`n=== Exercise 4: Account Cleanup ===" -ForegroundColor Cyan

function Get-StaleAccounts {
    [CmdletBinding()]
    param(
        [int]$DisableAfterDays = 90,
        [int]$DeleteAfterDays = 180
    )

    $script:adUsers | Where-Object Enabled | ForEach-Object {
        $daysInactive = ((Get-Date) - $_.LastLogonDate).Days

        if ($daysInactive -ge $DeleteAfterDays) {
            $action = "DELETE"
        } elseif ($daysInactive -ge $DisableAfterDays) {
            $action = "DISABLE"
        } else {
            return
        }

        [PSCustomObject]@{
            Username     = $_.SamAccountName
            Name         = $_.Name
            DaysInactive = $daysInactive
            LastLogon    = $_.LastLogonDate.ToString("yyyy-MM-dd")
            Action       = $action
        }
    }
}

Get-StaleAccounts | Format-Table -AutoSize

# --- Exercise 5: Password Compliance ---
Write-Host "=== Exercise 5: Password Compliance ===" -ForegroundColor Cyan

$compliance = $script:adUsers | Where-Object Enabled | ForEach-Object {
    $pwdAge = ((Get-Date) - $_.PasswordLastSet).Days
    $status = if ($_.PasswordNeverExpires) { "Non-Compliant (Never Expires)" }
              elseif ($pwdAge -gt 180) { "Critical (>180 days)" }
              elseif ($pwdAge -gt 90) { "Warning (>90 days)" }
              else { "Compliant" }

    [PSCustomObject]@{
        Username    = $_.SamAccountName
        PasswordAge = $pwdAge
        NeverExpires = $_.PasswordNeverExpires
        Status      = $status
    }
}

$compliance | Format-Table -AutoSize

$total = $compliance.Count
$compliant = ($compliance | Where-Object Status -eq "Compliant").Count
$pct = [math]::Round(($compliant / $total) * 100, 1)
Write-Host "Password Compliance: $pct% ($compliant of $total accounts)" -ForegroundColor $(if ($pct -ge 80) {"Green"} else {"Red"})
