# =============================================================================
# Day 8 — Querying Active Directory (Simulation Mode)
# =============================================================================
# These examples work WITHOUT an AD environment by simulating AD data.
# On a real domain-joined machine, replace simulated functions with AD cmdlets.

# --- Simulated AD Data ---
$simulatedUsers = @(
    [PSCustomObject]@{ Name="John Doe"; SamAccountName="jdoe"; Department="IT"; Title="DevOps Engineer"; Enabled=$true; LastLogonDate=(Get-Date).AddDays(-5); Created=(Get-Date).AddDays(-365); PasswordNeverExpires=$false }
    [PSCustomObject]@{ Name="Jane Smith"; SamAccountName="jsmith"; Department="HR"; Title="Recruiter"; Enabled=$true; LastLogonDate=(Get-Date).AddDays(-2); Created=(Get-Date).AddDays(-200); PasswordNeverExpires=$false }
    [PSCustomObject]@{ Name="Bob Wilson"; SamAccountName="bwilson"; Department="IT"; Title="Sysadmin"; Enabled=$true; LastLogonDate=(Get-Date).AddDays(-100); Created=(Get-Date).AddDays(-500); PasswordNeverExpires=$true }
    [PSCustomObject]@{ Name="Alice Brown"; SamAccountName="abrown"; Department="Finance"; Title="Analyst"; Enabled=$false; LastLogonDate=(Get-Date).AddDays(-200); Created=(Get-Date).AddDays(-400); PasswordNeverExpires=$false }
    [PSCustomObject]@{ Name="Charlie Davis"; SamAccountName="cdavis"; Department="IT"; Title="Security Analyst"; Enabled=$true; LastLogonDate=(Get-Date).AddDays(-1); Created=(Get-Date).AddDays(-30); PasswordNeverExpires=$false }
    [PSCustomObject]@{ Name="Eve Martinez"; SamAccountName="emartinez"; Department="Marketing"; Title="Manager"; Enabled=$true; LastLogonDate=(Get-Date).AddDays(-15); Created=(Get-Date).AddDays(-180); PasswordNeverExpires=$true }
    [PSCustomObject]@{ Name="Service Account"; SamAccountName="svc_backup"; Department="IT"; Title="Service Account"; Enabled=$true; LastLogonDate=(Get-Date).AddDays(-1); Created=(Get-Date).AddDays(-700); PasswordNeverExpires=$true }
)

# --- List all users ---
Write-Host "=== All AD Users ===" -ForegroundColor Cyan
$simulatedUsers | Select-Object Name, SamAccountName, Department, Enabled | Format-Table

# --- Filter by department ---
Write-Host "=== IT Department ===" -ForegroundColor Cyan
$simulatedUsers | Where-Object Department -eq "IT" | Select-Object Name, Title | Format-Table

# --- Find disabled accounts ---
Write-Host "=== Disabled Accounts ===" -ForegroundColor Cyan
$simulatedUsers | Where-Object { -not $_.Enabled } | Select-Object Name, SamAccountName | Format-Table

# --- Find inactive accounts (90+ days) ---
Write-Host "=== Inactive Accounts (90+ days) ===" -ForegroundColor Cyan
$cutoff = (Get-Date).AddDays(-90)
$simulatedUsers | Where-Object { $_.LastLogonDate -lt $cutoff } |
    Select-Object Name, SamAccountName, LastLogonDate | Format-Table

# --- Accounts with Password Never Expires ---
Write-Host "=== Password Never Expires ===" -ForegroundColor Red
$simulatedUsers | Where-Object PasswordNeverExpires |
    Select-Object Name, SamAccountName, Title | Format-Table

# --- Users by department count ---
Write-Host "=== Users per Department ===" -ForegroundColor Cyan
$simulatedUsers | Group-Object Department |
    Select-Object Name, Count |
    Sort-Object Count -Descending | Format-Table

# --- Recently created accounts (last 60 days) ---
Write-Host "=== Recently Created (last 60 days) ===" -ForegroundColor Cyan
$recentCutoff = (Get-Date).AddDays(-60)
$simulatedUsers | Where-Object { $_.Created -gt $recentCutoff } |
    Select-Object Name, Created | Format-Table

Write-Host @"

NOTE: These examples use simulated data. In a real AD environment, replace
`$simulatedUsers with actual AD cmdlets:
  Get-ADUser -Filter * -Properties Department, LastLogonDate, Created
"@ -ForegroundColor Yellow
