# =============================================================================
# Day 12 — Security Auditing
# =============================================================================

Write-Host "=== Security Audit Script ===" -ForegroundColor Cyan

# --- Execution Policy ---
Write-Host "`n--- Execution Policy ---" -ForegroundColor Yellow
$policy = Get-ExecutionPolicy
$policyColor = switch ($policy) {
    "Restricted" { "Green" }
    "AllSigned" { "Green" }
    "RemoteSigned" { "Yellow" }
    default { "Red" }
}
Write-Host "  Current policy: $policy" -ForegroundColor $policyColor

# --- Local Accounts Audit ---
Write-Host "`n--- Local Account Audit ---" -ForegroundColor Yellow

try {
    $localUsers = Get-LocalUser -ErrorAction Stop
    foreach ($user in $localUsers) {
        $issues = @()
        if ($user.Enabled -and $user.Name -eq "Guest") { $issues += "Guest enabled" }
        if ($user.Enabled -and $null -eq $user.PasswordExpires) { $issues += "Password never expires" }
        if ($user.Enabled -and $user.PasswordLastSet -lt (Get-Date).AddDays(-180)) { $issues += "Old password" }

        $color = if ($issues) { "Yellow" } else { "Green" }
        $status = if ($issues) { $issues -join ", " } else { "OK" }
        Write-Host ("  {0,-20} Enabled: {1,-5}  {2}" -f $user.Name, $user.Enabled, $status) -ForegroundColor $color
    }
} catch {
    # Fallback for non-Windows
    Write-Output "  Local user audit requires Windows (Get-LocalUser)"
}

# --- Admin Group Members ---
Write-Host "`n--- Local Administrators ---" -ForegroundColor Yellow
try {
    $admins = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop
    foreach ($admin in $admins) {
        $flag = if ($admin.ObjectClass -eq "User") { "" } else { " (Group)" }
        Write-Output "  $($admin.Name)$flag"
    }
} catch {
    Write-Output "  Admin group audit requires Windows"
}

# --- Open Ports ---
Write-Host "`n--- Listening Ports ---" -ForegroundColor Yellow
try {
    $listeners = Get-NetTCPConnection -State Listen -ErrorAction Stop |
        Select-Object LocalPort, @{N="Process";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}} |
        Sort-Object LocalPort -Unique

    $riskyPorts = @(21, 23, 445, 1433, 3306, 3389, 5985)
    foreach ($l in $listeners | Select-Object -First 15) {
        $risky = if ($l.LocalPort -in $riskyPorts) { " [REVIEW]" } else { "" }
        $color = if ($risky) { "Yellow" } else { "Gray" }
        Write-Host ("  Port {0,5}: {1}{2}" -f $l.LocalPort, $l.Process, $risky) -ForegroundColor $color
    }
} catch {
    Write-Output "  Port audit requires Windows (Get-NetTCPConnection)"
}

# --- PowerShell Logging Status ---
Write-Host "`n--- PowerShell Security Logging ---" -ForegroundColor Yellow
$loggingChecks = @(
    @{Name="Script Block Logging"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"; Key="EnableScriptBlockLogging"}
    @{Name="Module Logging"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging"; Key="EnableModuleLogging"}
    @{Name="Transcription"; Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription"; Key="EnableTranscripting"}
)

foreach ($check in $loggingChecks) {
    try {
        $val = (Get-ItemProperty -Path $check.Path -Name $check.Key -ErrorAction Stop).($check.Key)
        $enabled = $val -eq 1
    } catch {
        $enabled = $false
    }
    $color = if ($enabled) { "Green" } else { "Red" }
    $status = if ($enabled) { "ENABLED" } else { "DISABLED" }
    Write-Host ("  {0,-25} {1}" -f $check.Name, $status) -ForegroundColor $color
}

# --- Security Summary ---
Write-Host "`n--- Audit Summary ---" -ForegroundColor Cyan
Write-Output @"
  Recommendations:
  1. Set Execution Policy to RemoteSigned or AllSigned
  2. Disable the Guest account
  3. Enable password expiration for all accounts
  4. Review all members of the Administrators group
  5. Enable Script Block Logging and Module Logging
  6. Close unnecessary listening ports
"@
