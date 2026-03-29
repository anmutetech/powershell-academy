# Day 8 — Active Directory Automation

Active Directory (AD) is the backbone of enterprise identity management. As a Cloud/DevOps Engineer or Security Analyst, automating AD tasks saves hours of manual work and reduces human error. Today you learn to manage users, groups, OUs, and more with PowerShell.

---

## Video Resources

- [Active Directory PowerShell](https://www.youtube.com/watch?v=dGs9QPqFJSQ)
- [Managing AD Users with PowerShell](https://www.youtube.com/watch?v=GKJQR53gxpU)
- [PowerShell for Active Directory](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) — Episodes 17-19

---

## Prerequisites

The AD module is available on:
- Windows Server with AD DS role
- Windows 10/11 with RSAT tools installed
- Or use the simulation approach in our examples (works without AD)

```powershell
# Install RSAT AD tools (Windows 10/11)
Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0

# Import the module
Import-Module ActiveDirectory

# Verify
Get-Module ActiveDirectory
Get-Command -Module ActiveDirectory | Measure-Object  # ~150 cmdlets
```

## 1. Querying AD Users

```powershell
# Get all users
Get-ADUser -Filter * | Select-Object Name, SamAccountName, Enabled

# Search by name
Get-ADUser -Filter "Name -like 'John*'"

# Get specific user with all properties
Get-ADUser -Identity "jdoe" -Properties *

# Get users in a specific OU
Get-ADUser -Filter * -SearchBase "OU=IT,DC=company,DC=com"

# Find disabled accounts
Get-ADUser -Filter {Enabled -eq $false} | Select-Object Name, SamAccountName

# Find accounts with expired passwords
Search-ADAccount -PasswordExpired | Select-Object Name, PasswordLastSet

# Find inactive accounts (no login in 90 days)
$cutoff = (Get-Date).AddDays(-90)
Get-ADUser -Filter {LastLogonDate -lt $cutoff} -Properties LastLogonDate |
    Select-Object Name, LastLogonDate
```

## 2. Creating and Managing Users

```powershell
# Create a single user
New-ADUser -Name "Jane Smith" `
    -GivenName "Jane" `
    -Surname "Smith" `
    -SamAccountName "jsmith" `
    -UserPrincipalName "jsmith@company.com" `
    -Path "OU=IT,DC=company,DC=com" `
    -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
    -Enabled $true `
    -ChangePasswordAtLogon $true

# Modify user properties
Set-ADUser -Identity "jsmith" -Title "DevOps Engineer" -Department "IT" -Office "Building A"

# Enable/Disable accounts
Disable-ADAccount -Identity "jsmith"
Enable-ADAccount -Identity "jsmith"

# Unlock account
Unlock-ADAccount -Identity "jsmith"

# Reset password
Set-ADAccountPassword -Identity "jsmith" `
    -NewPassword (ConvertTo-SecureString "NewP@ss123!" -AsPlainText -Force) `
    -Reset

# Remove user
Remove-ADUser -Identity "jsmith" -Confirm:$false
```

## 3. Bulk User Operations from CSV

This is one of the most common real-world AD automation tasks.

```powershell
# CSV format: FirstName,LastName,Username,Department,Title
# new-hires.csv:
# John,Doe,jdoe,IT,Developer
# Jane,Smith,jsmith,HR,Recruiter

$users = Import-Csv ".\new-hires.csv"
$defaultPassword = ConvertTo-SecureString "Welcome2026!" -AsPlainText -Force

foreach ($user in $users) {
    try {
        $params = @{
            Name              = "$($user.FirstName) $($user.LastName)"
            GivenName         = $user.FirstName
            Surname           = $user.LastName
            SamAccountName    = $user.Username
            UserPrincipalName = "$($user.Username)@company.com"
            Path              = "OU=$($user.Department),DC=company,DC=com"
            Department        = $user.Department
            Title             = $user.Title
            AccountPassword   = $defaultPassword
            Enabled           = $true
            ChangePasswordAtLogon = $true
        }
        New-ADUser @params
        Write-Output "Created: $($user.Username)"
    } catch {
        Write-Warning "Failed to create $($user.Username): $($_.Exception.Message)"
    }
}
```

## 4. Groups

```powershell
# List groups
Get-ADGroup -Filter * | Select-Object Name, GroupScope, GroupCategory

# Create a group
New-ADGroup -Name "DevOps-Team" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=Groups,DC=company,DC=com" `
    -Description "DevOps Engineering Team"

# Add users to a group
Add-ADGroupMember -Identity "DevOps-Team" -Members "jdoe", "jsmith"

# Remove from group
Remove-ADGroupMember -Identity "DevOps-Team" -Members "jsmith" -Confirm:$false

# Get group members
Get-ADGroupMember -Identity "DevOps-Team" | Select-Object Name, SamAccountName

# Get all groups for a user
Get-ADPrincipalGroupMembership -Identity "jdoe" | Select-Object Name
```

## 5. Organizational Units (OUs)

```powershell
# List OUs
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

# Create OU
New-ADOrganizationalUnit -Name "Contractors" -Path "DC=company,DC=com" -ProtectedFromAccidentalDeletion $true

# Move user to different OU
Move-ADObject -Identity "CN=John Doe,OU=IT,DC=company,DC=com" `
    -TargetPath "OU=Contractors,DC=company,DC=com"
```

## 6. AD Reports

```powershell
# Users per department
Get-ADUser -Filter * -Properties Department |
    Group-Object Department |
    Select-Object Name, Count |
    Sort-Object Count -Descending

# Users created in the last 30 days
$since = (Get-Date).AddDays(-30)
Get-ADUser -Filter {Created -gt $since} -Properties Created |
    Select-Object Name, Created, Enabled |
    Sort-Object Created -Descending

# Export all users to CSV
Get-ADUser -Filter * -Properties Department, Title, Email, LastLogonDate |
    Select-Object Name, SamAccountName, Department, Title, Email, Enabled, LastLogonDate |
    Export-Csv -Path ".\ad-users-report.csv" -NoTypeInformation
```

## 7. Security Audit Queries

These queries are essential for Security Analyst roles:

```powershell
# Accounts with "Password Never Expires"
Get-ADUser -Filter {PasswordNeverExpires -eq $true} -Properties PasswordNeverExpires |
    Select-Object Name, SamAccountName

# Admin accounts
Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, SamAccountName

# Accounts not requiring password
Get-ADUser -Filter {PasswordNotRequired -eq $true}

# Stale computer accounts
$staleDays = 90
Get-ADComputer -Filter {LastLogonDate -lt $cutoff} -Properties LastLogonDate |
    Select-Object Name, LastLogonDate
```

---

## Key Takeaways

1. The `ActiveDirectory` module has ~150 cmdlets — `Get-Command -Module ActiveDirectory`
2. Always use `-ErrorAction` and `try/catch` for bulk operations
3. Use splatting (`@params`) for cmdlets with many parameters
4. CSV-based bulk user creation is one of the most requested AD automation tasks
5. Security auditing (stale accounts, password policies) is critical for compliance
6. Test with `-WhatIf` before making changes in production

---

## Interview Prep

**Q: How do you bulk-create AD users from a CSV file?**
A: Import the CSV with `Import-Csv`, loop through each row with `foreach`, and call `New-ADUser` with splatted parameters. Use `try/catch` for error handling and set initial passwords with `ConvertTo-SecureString`. Always set `-ChangePasswordAtLogon $true` for security.

**Q: How do you find inactive AD accounts?**
A: Use `Get-ADUser` with a filter on `LastLogonDate`: `Get-ADUser -Filter {LastLogonDate -lt $cutoff} -Properties LastLogonDate` where `$cutoff` is typically 90 days ago. Also check `Search-ADAccount -AccountInactive -TimeSpan 90.00:00:00` for a built-in approach.

**Q: What is the difference between a Security group and a Distribution group in AD?**
A: Security groups can be used to assign permissions to resources (file shares, applications) and can also receive emails. Distribution groups are used only for email distribution lists and cannot be used for security permissions. In automation, we primarily work with Security groups.
