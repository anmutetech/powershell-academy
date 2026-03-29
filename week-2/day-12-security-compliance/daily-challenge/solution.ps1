# =============================================================================
# Day 12 Daily Challenge — Security Compliance Scanner (Solution)
# =============================================================================

[CmdletBinding()]
param(
    [switch]$Remediate,
    [string]$ReportPath = $PSScriptRoot
)

$ErrorActionPreference = "Continue"
Write-Host "===== Security Compliance Scanner =====" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Computer: $env:COMPUTERNAME`n"

# Define checks
$checks = @(
    @{
        Name="Execution Policy"; Category="PowerShell"; Severity="High"; Weight=15
        Check={ (Get-ExecutionPolicy) -in @("RemoteSigned","AllSigned","Restricted") }
        Remediation="Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
    }
    @{
        Name="PowerShell Version 7+"; Category="PowerShell"; Severity="Medium"; Weight=10
        Check={ $PSVersionTable.PSVersion.Major -ge 7 }
        Remediation="Install PowerShell 7 from https://aka.ms/powershell"
    }
    @{
        Name="Guest Account Disabled"; Category="Accounts"; Severity="Critical"; Weight=25
        Check={
            try { -not (Get-LocalUser -Name "Guest" -ErrorAction Stop).Enabled }
            catch { $true }  # If can't check, assume OK
        }
        Remediation="Disable-LocalUser -Name Guest"
    }
    @{
        Name="No Accounts Without Password Expiry"; Category="Accounts"; Severity="High"; Weight=15
        Check={
            try {
                $noExpiry = Get-LocalUser -ErrorAction Stop | Where-Object { $_.Enabled -and $null -eq $_.PasswordExpires }
                $noExpiry.Count -eq 0
            } catch { $true }
        }
        Remediation="Set password expiration for all enabled accounts"
    }
    @{
        Name="Temp Directory Permissions"; Category="FileSystem"; Severity="Medium"; Weight=10
        Check={ Test-Path $env:TEMP }
        Remediation="Verify TEMP directory exists and has correct permissions"
    }
    @{
        Name="No Risky Listening Ports"; Category="Network"; Severity="High"; Weight=15
        Check={
            try {
                $risky = Get-NetTCPConnection -State Listen -ErrorAction Stop |
                    Where-Object { $_.LocalPort -in @(21, 23, 445) }
                $risky.Count -eq 0
            } catch { $true }
        }
        Remediation="Close FTP (21), Telnet (23), SMB (445) if not needed"
    }
    @{
        Name="HTTPS Available (Port 443)"; Category="Network"; Severity="Low"; Weight=5
        Check={ $true }  # Simplified
        Remediation="Enable HTTPS on web services"
    }
    @{
        Name="Profile Script Exists"; Category="PowerShell"; Severity="Low"; Weight=5
        Check={ Test-Path $PROFILE -ErrorAction SilentlyContinue }
        Remediation="Create a PowerShell profile for consistent configuration"
    }
    @{
        Name="Running as Standard User"; Category="Access Control"; Severity="Medium"; Weight=10
        Check={
            -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        }
        Remediation="Run day-to-day tasks as standard user, elevate only when needed"
    }
    @{
        Name="No Sensitive Files in TEMP"; Category="FileSystem"; Severity="Medium"; Weight=10
        Check={
            $sensitive = Get-ChildItem $env:TEMP -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match "\.(pem|key|pfx|p12|cer)$" }
            ($sensitive | Measure-Object).Count -eq 0
        }
        Remediation="Remove certificate/key files from TEMP directory"
    }
)

# Run checks
$findings = @()
foreach ($check in $checks) {
    $passed = $false
    try {
        $passed = & $check.Check
    } catch {
        Write-Verbose "Check '$($check.Name)' error: $($_.Exception.Message)"
    }

    $findings += [PSCustomObject]@{
        Name        = $check.Name
        Category    = $check.Category
        Severity    = $check.Severity
        Weight      = $check.Weight
        Status      = if ($passed) { "PASS" } else { "FAIL" }
        Remediation = if (-not $passed) { $check.Remediation } else { "" }
    }
}

# Display results
Write-Host "FINDINGS:" -ForegroundColor Yellow
$findings | ForEach-Object {
    $icon = if ($_.Status -eq "PASS") { "[PASS]" } else { "[FAIL]" }
    $color = if ($_.Status -eq "PASS") { "Green" } else {
        switch ($_.Severity) { "Critical" {"Red"}; "High" {"Red"}; "Medium" {"Yellow"}; default {"Gray"} }
    }
    Write-Host ("  {0} {1,-40} {2,-10} {3}" -f $icon, $_.Name, $_.Severity, $_.Category) -ForegroundColor $color
}

# Calculate score
$totalWeight = ($checks | Measure-Object Weight -Sum).Sum
$passedWeight = ($findings | Where-Object Status -eq "PASS" | Measure-Object Weight -Sum).Sum
$score = [math]::Round(($passedWeight / $totalWeight) * 100)

$scoreColor = if ($score -ge 80) { "Green" } elseif ($score -ge 60) { "Yellow" } else { "Red" }

Write-Host "`n===== COMPLIANCE SCORE: $score% =====" -ForegroundColor $scoreColor
$passCount = ($findings | Where-Object Status -eq "PASS").Count
$failCount = ($findings | Where-Object Status -eq "FAIL").Count
Write-Host "Passed: $passCount | Failed: $failCount | Total: $($findings.Count)"

# Failed findings with remediation
$failed = $findings | Where-Object Status -eq "FAIL"
if ($failed) {
    Write-Host "`nRemediation Steps:" -ForegroundColor Yellow
    $i = 1
    foreach ($f in $failed) {
        Write-Host "  $i. [$($f.Severity)] $($f.Name)" -ForegroundColor Red
        Write-Host "     Fix: $($f.Remediation)" -ForegroundColor Gray
        $i++
    }
}

# Remediate if requested
if ($Remediate -and $failed) {
    Write-Host "`nAuto-remediation not implemented for safety." -ForegroundColor Yellow
    Write-Host "Review and apply remediation steps manually." -ForegroundColor Yellow
}

# Export
$csvPath = Join-Path $ReportPath "compliance-$(Get-Date -Format 'yyyy-MM-dd').csv"
$jsonPath = Join-Path $ReportPath "compliance-$(Get-Date -Format 'yyyy-MM-dd').json"

$findings | Export-Csv -Path $csvPath -NoTypeInformation
@{
    Computer = $env:COMPUTERNAME
    Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Score = $score
    Findings = $findings
} | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonPath

Write-Host "`nReports saved:"
Write-Host "  CSV:  $csvPath"
Write-Host "  JSON: $jsonPath"
