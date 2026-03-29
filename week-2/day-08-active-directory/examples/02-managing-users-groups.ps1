# =============================================================================
# Day 8 — Managing Users and Groups (Simulation Mode)
# =============================================================================

# --- Simulated AD Functions ---
# These mirror real AD cmdlet behavior for practice without a domain controller

function New-SimADUser {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$GivenName,
        [string]$Surname,
        [Parameter(Mandatory)][string]$SamAccountName,
        [string]$Department,
        [string]$Title,
        [securestring]$AccountPassword,
        [bool]$Enabled = $true
    )

    if ($PSCmdlet.ShouldProcess($Name, "Create AD User")) {
        [PSCustomObject]@{
            Name           = $Name
            SamAccountName = $SamAccountName
            Department     = $Department
            Title          = $Title
            Enabled        = $Enabled
            Created        = Get-Date
        }
    }
}

function Add-SimADGroupMember {
    [CmdletBinding()]
    param(
        [string]$GroupName,
        [string[]]$Members
    )
    Write-Output "Added [$($Members -join ', ')] to group '$GroupName'"
}

# === Create Single User ===
Write-Host "=== Creating Single User ===" -ForegroundColor Cyan

$password = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

$newUser = New-SimADUser `
    -Name "Sarah Johnson" `
    -GivenName "Sarah" `
    -Surname "Johnson" `
    -SamAccountName "sjohnson" `
    -Department "IT" `
    -Title "Cloud Engineer" `
    -AccountPassword $password `
    -Enabled $true

Write-Output "Created user: $($newUser.Name) ($($newUser.SamAccountName))"

# === Bulk User Creation from CSV ===
Write-Host "`n=== Bulk User Creation ===" -ForegroundColor Cyan

# Simulate CSV data (in real use: Import-Csv "new-hires.csv")
$newHires = @(
    [PSCustomObject]@{ FirstName="Tom"; LastName="Chen"; Username="tchen"; Department="IT"; Title="Developer" }
    [PSCustomObject]@{ FirstName="Lisa"; LastName="Park"; Username="lpark"; Department="HR"; Title="HR Specialist" }
    [PSCustomObject]@{ FirstName="Mike"; LastName="Ross"; Username="mross"; Department="Finance"; Title="Accountant" }
    [PSCustomObject]@{ FirstName="Anna"; LastName="Lee"; Username="alee"; Department="IT"; Title="QA Engineer" }
)

$defaultPwd = ConvertTo-SecureString "Welcome2026!" -AsPlainText -Force
$createdUsers = @()
$failedUsers = @()

foreach ($hire in $newHires) {
    try {
        $params = @{
            Name           = "$($hire.FirstName) $($hire.LastName)"
            GivenName      = $hire.FirstName
            Surname        = $hire.LastName
            SamAccountName = $hire.Username
            Department     = $hire.Department
            Title          = $hire.Title
            AccountPassword = $defaultPwd
            Enabled        = $true
        }

        $created = New-SimADUser @params
        $createdUsers += $created
        Write-Host "  Created: $($hire.Username)" -ForegroundColor Green
    } catch {
        $failedUsers += $hire.Username
        Write-Host "  Failed: $($hire.Username) - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nResults: $($createdUsers.Count) created, $($failedUsers.Count) failed"

# === Group Management ===
Write-Host "`n=== Group Management ===" -ForegroundColor Cyan

# Simulated groups
$groups = @(
    [PSCustomObject]@{ Name="IT-Staff"; Members=@("jdoe","cdavis","tchen","alee"); Scope="Global"; Category="Security" }
    [PSCustomObject]@{ Name="DevOps-Team"; Members=@("jdoe","tchen"); Scope="Global"; Category="Security" }
    [PSCustomObject]@{ Name="All-Employees"; Members=@("jdoe","jsmith","bwilson","abrown","cdavis"); Scope="Global"; Category="Distribution" }
)

# Display groups
foreach ($group in $groups) {
    Write-Host "`nGroup: $($group.Name) ($($group.Category) - $($group.Scope))" -ForegroundColor Yellow
    Write-Output "  Members: $($group.Members -join ', ')"
}

# Add new hires to their department group
Write-Host "`n=== Adding New Hires to Groups ===" -ForegroundColor Cyan
$itHires = $newHires | Where-Object Department -eq "IT"
if ($itHires) {
    Add-SimADGroupMember -GroupName "IT-Staff" -Members ($itHires.Username)
}
Add-SimADGroupMember -GroupName "All-Employees" -Members ($newHires.Username)

# === User Report ===
Write-Host "`n=== New Hire Report ===" -ForegroundColor Cyan
$createdUsers | Format-Table Name, SamAccountName, Department, Title -AutoSize
