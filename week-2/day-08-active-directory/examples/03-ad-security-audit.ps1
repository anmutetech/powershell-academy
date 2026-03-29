# =============================================================================
# Day 8 — AD Security Audit (Simulation Mode)
# =============================================================================

# --- Simulated AD data for security audit ---
$adUsers = @(
    [PSCustomObject]@{ Name="John Doe"; SamAccountName="jdoe"; Enabled=$true; PasswordNeverExpires=$false; PasswordLastSet=(Get-Date).AddDays(-45); LastLogonDate=(Get-Date).AddDays(-1); MemberOf=@("IT-Staff","DevOps-Team"); AccountType="User" }
    [PSCustomObject]@{ Name="Jane Smith"; SamAccountName="jsmith"; Enabled=$true; PasswordNeverExpires=$false; PasswordLastSet=(Get-Date).AddDays(-80); LastLogonDate=(Get-Date).AddDays(-2); MemberOf=@("HR-Staff"); AccountType="User" }
    [PSCustomObject]@{ Name="Admin Bob"; SamAccountName="admin.bob"; Enabled=$true; PasswordNeverExpires=$true; PasswordLastSet=(Get-Date).AddDays(-200); LastLogonDate=(Get-Date).AddDays(-1); MemberOf=@("Domain Admins","IT-Staff"); AccountType="Admin" }
    [PSCustomObject]@{ Name="Old Account"; SamAccountName="olduser"; Enabled=$true; PasswordNeverExpires=$false; PasswordLastSet=(Get-Date).AddDays(-400); LastLogonDate=(Get-Date).AddDays(-150); MemberOf=@("All-Employees"); AccountType="User" }
    [PSCustomObject]@{ Name="Disabled User"; SamAccountName="duser"; Enabled=$false; PasswordNeverExpires=$false; PasswordLastSet=(Get-Date).AddDays(-300); LastLogonDate=(Get-Date).AddDays(-300); MemberOf=@(); AccountType="User" }
    [PSCustomObject]@{ Name="SVC Backup"; SamAccountName="svc_backup"; Enabled=$true; PasswordNeverExpires=$true; PasswordLastSet=(Get-Date).AddDays(-500); LastLogonDate=(Get-Date).AddDays(-1); MemberOf=@("Backup-Operators"); AccountType="Service" }
    [PSCustomObject]@{ Name="SVC Monitor"; SamAccountName="svc_monitor"; Enabled=$true; PasswordNeverExpires=$true; PasswordLastSet=(Get-Date).AddDays(-365); LastLogonDate=(Get-Date).AddDays(-3); MemberOf=@("Monitoring"); AccountType="Service" }
    [PSCustomObject]@{ Name="Contractor Joe"; SamAccountName="cjoe"; Enabled=$true; PasswordNeverExpires=$false; PasswordLastSet=(Get-Date).AddDays(-30); LastLogonDate=(Get-Date).AddDays(-95); MemberOf=@("Contractors"); AccountType="Contractor" }
)

Write-Host "===== AD Security Audit Report =====" -ForegroundColor Cyan
Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

# --- 1. Password Never Expires ---
Write-Host "1. ACCOUNTS WITH PASSWORD NEVER EXPIRES" -ForegroundColor Red
$neverExpires = $adUsers | Where-Object PasswordNeverExpires
$neverExpires | ForEach-Object {
    $daysSinceChange = ((Get-Date) - $_.PasswordLastSet).Days
    Write-Host ("  {0,-20} Type: {1,-12} Password Age: {2} days" -f $_.SamAccountName, $_.AccountType, $daysSinceChange) -ForegroundColor Yellow
}
Write-Host "  Finding: $($neverExpires.Count) accounts with non-expiring passwords`n" -ForegroundColor Yellow

# --- 2. Stale/Inactive Accounts ---
Write-Host "2. INACTIVE ACCOUNTS (90+ days since last logon)" -ForegroundColor Red
$staleCutoff = (Get-Date).AddDays(-90)
$staleAccounts = $adUsers | Where-Object { $_.Enabled -and $_.LastLogonDate -lt $staleCutoff }
$staleAccounts | ForEach-Object {
    $daysInactive = ((Get-Date) - $_.LastLogonDate).Days
    Write-Host ("  {0,-20} Last Logon: {1:yyyy-MM-dd} ({2} days ago)" -f $_.SamAccountName, $_.LastLogonDate, $daysInactive) -ForegroundColor Yellow
}
Write-Host "  Finding: $($staleAccounts.Count) stale enabled accounts`n" -ForegroundColor Yellow

# --- 3. Privileged Accounts ---
Write-Host "3. PRIVILEGED ACCOUNTS (Domain Admins)" -ForegroundColor Red
$admins = $adUsers | Where-Object { $_.MemberOf -contains "Domain Admins" }
$admins | ForEach-Object {
    $flags = @()
    if ($_.PasswordNeverExpires) { $flags += "PwdNeverExpires" }
    if (((Get-Date) - $_.PasswordLastSet).Days -gt 90) { $flags += "OldPassword" }
    $flagStr = if ($flags) { "  ISSUES: $($flags -join ', ')" } else { "  No issues" }
    Write-Host "  $($_.SamAccountName) - $($_.Name)" -ForegroundColor Yellow
    Write-Host "  $flagStr" -ForegroundColor $(if ($flags) { "Red" } else { "Green" })
}
Write-Host ""

# --- 4. Service Accounts ---
Write-Host "4. SERVICE ACCOUNTS" -ForegroundColor Red
$serviceAccounts = $adUsers | Where-Object AccountType -eq "Service"
$serviceAccounts | ForEach-Object {
    $pwdAge = ((Get-Date) - $_.PasswordLastSet).Days
    $status = if ($pwdAge -gt 365) { "CRITICAL" } elseif ($pwdAge -gt 180) { "WARNING" } else { "OK" }
    $color = switch ($status) { "CRITICAL" { "Red" }; "WARNING" { "Yellow" }; default { "Green" } }
    Write-Host ("  {0,-20} Password Age: {1} days [{2}]" -f $_.SamAccountName, $pwdAge, $status) -ForegroundColor $color
}
Write-Host ""

# --- 5. Disabled but Not Removed ---
Write-Host "5. DISABLED ACCOUNTS (cleanup candidates)" -ForegroundColor Red
$disabled = $adUsers | Where-Object { -not $_.Enabled }
$disabled | ForEach-Object {
    $daysSinceLogon = ((Get-Date) - $_.LastLogonDate).Days
    Write-Host ("  {0,-20} Disabled, last logon {1} days ago" -f $_.SamAccountName, $daysSinceLogon) -ForegroundColor Gray
}
Write-Host ""

# --- Summary ---
Write-Host "===== AUDIT SUMMARY =====" -ForegroundColor Cyan
$issues = @(
    [PSCustomObject]@{ Finding="Password Never Expires"; Count=$neverExpires.Count; Severity="High" }
    [PSCustomObject]@{ Finding="Inactive Accounts (90+ days)"; Count=$staleAccounts.Count; Severity="Medium" }
    [PSCustomObject]@{ Finding="Admin Accounts"; Count=$admins.Count; Severity="Info" }
    [PSCustomObject]@{ Finding="Service Accounts"; Count=$serviceAccounts.Count; Severity="Info" }
    [PSCustomObject]@{ Finding="Disabled Accounts"; Count=$disabled.Count; Severity="Low" }
)
$issues | Format-Table -AutoSize

$totalIssues = ($issues | Where-Object Severity -in "High","Medium" | Measure-Object Count -Sum).Sum
if ($totalIssues -gt 0) {
    Write-Host "ACTION REQUIRED: $totalIssues high/medium severity findings" -ForegroundColor Red
} else {
    Write-Host "No critical findings." -ForegroundColor Green
}
