# Day 12 — Security & Compliance

Security is not optional — it's a core requirement. As a Security Analyst or DevOps Engineer, you need PowerShell skills to audit systems, enforce compliance, manage credentials securely, and respond to incidents. Today covers the security essentials.

---

## Video Resources

- [PowerShell Security Best Practices](https://www.youtube.com/watch?v=xYB4YMUn-BI)
- [PowerShell SecretManagement](https://www.youtube.com/watch?v=dD_lnFjkilo)
- [Incident Response with PowerShell](https://www.youtube.com/watch?v=iKFfigVUBio)

---

## 1. Execution Policy

Execution policy controls which scripts can run. It's a safety feature, not a security boundary.

```powershell
# Check current policy
Get-ExecutionPolicy
Get-ExecutionPolicy -List  # Shows all scopes

# Set policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Bypass for a single script (common in CI/CD)
PowerShell.exe -ExecutionPolicy Bypass -File ".\script.ps1"
```

| Policy | Behavior |
|--------|----------|
| `Restricted` | No scripts can run (default on Windows clients) |
| `AllSigned` | Only scripts signed by trusted publisher |
| `RemoteSigned` | Downloaded scripts need signing; local scripts run freely |
| `Unrestricted` | All scripts run (warns on downloaded) |
| `Bypass` | Nothing blocked, no warnings |

## 2. Credential Management

**Never hardcode passwords.** Use these secure methods:

```powershell
# Interactive credential prompt
$cred = Get-Credential

# SecureString for passwords
$password = ConvertTo-SecureString "MyPassword" -AsPlainText -Force
$cred = New-Object PSCredential("admin", $password)

# Read password from encrypted file
$password | ConvertFrom-SecureString | Set-Content ".\encrypted-pwd.txt"
$savedPwd = Get-Content ".\encrypted-pwd.txt" | ConvertTo-SecureString
```

### SecretManagement Module (Recommended)

```powershell
# Install
Install-Module Microsoft.PowerShell.SecretManagement -Scope CurrentUser
Install-Module Microsoft.PowerShell.SecretStore -Scope CurrentUser

# Register a vault
Register-SecretVault -Name "MyVault" -ModuleName Microsoft.PowerShell.SecretStore

# Store a secret
Set-Secret -Name "DBPassword" -SecureStringSecret (ConvertTo-SecureString "P@ss123!" -AsPlainText -Force)

# Retrieve a secret
$dbPwd = Get-Secret -Name "DBPassword"
$dbPwd = Get-Secret -Name "DBPassword" -AsPlainText  # Returns plain text
```

## 3. Audit and Compliance Scripts

### File Permission Audit

```powershell
# Check ACLs on a path
Get-Acl "C:\ImportantData" | Format-List

# Find files with specific permissions
Get-ChildItem "C:\Shared" -Recurse -Directory | ForEach-Object {
    $acl = Get-Acl $_.FullName
    $openRules = $acl.Access | Where-Object {
        $_.IdentityReference -eq "Everyone" -and $_.FileSystemRights -match "FullControl|Write"
    }
    if ($openRules) {
        [PSCustomObject]@{
            Path       = $_.FullName
            Identity   = "Everyone"
            Rights     = $openRules.FileSystemRights
            AccessType = $openRules.AccessControlType
        }
    }
}
```

### Local Security Policy Audit

```powershell
# Password policy
net accounts

# Local administrators
Get-LocalGroupMember -Group "Administrators"

# Check for guest account
Get-LocalUser -Name "Guest" | Select-Object Name, Enabled

# Find accounts that never expire
Get-LocalUser | Where-Object { $_.PasswordExpires -eq $null -and $_.Enabled } |
    Select-Object Name, Enabled, PasswordLastSet
```

### Registry Security Check

```powershell
# Check common security registry keys
$checks = @(
    @{Path="HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"; Name="LmCompatibilityLevel"; Expected=5; Desc="NTLMv2 Only"}
    @{Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell"; Name="EnableScriptBlockLogging"; Expected=1; Desc="Script Block Logging"}
)

foreach ($check in $checks) {
    try {
        $value = Get-ItemProperty -Path $check.Path -Name $check.Name -ErrorAction Stop
        $actual = $value.($check.Name)
        $status = if ($actual -eq $check.Expected) { "PASS" } else { "FAIL (Expected: $($check.Expected), Got: $actual)" }
    } catch {
        $status = "NOT SET"
    }
    Write-Output "$($check.Desc): $status"
}
```

## 4. Log Analysis for Security

```powershell
# Failed login attempts
Get-WinEvent -FilterHashtable @{
    LogName = "Security"
    Id      = 4625  # Failed logon
} -MaxEvents 50 | Select-Object TimeCreated,
    @{N="Account";E={$_.Properties[5].Value}},
    @{N="SourceIP";E={$_.Properties[19].Value}},
    @{N="Reason";E={$_.Properties[8].Value}}

# Account lockouts
Get-WinEvent -FilterHashtable @{
    LogName = "Security"
    Id      = 4740  # Account lockout
} -MaxEvents 20

# Privilege escalation events
Get-WinEvent -FilterHashtable @{
    LogName = "Security"
    Id      = 4672  # Special privileges assigned
} -MaxEvents 10

# PowerShell script block logging
Get-WinEvent -FilterHashtable @{
    LogName = "Microsoft-Windows-PowerShell/Operational"
    Id      = 4104  # Script block logging
} -MaxEvents 5 | Select-Object TimeCreated, Message
```

## 5. Network Security Scanning

```powershell
# Port scanner
function Test-PortRange {
    param(
        [string]$Target = "localhost",
        [int[]]$Ports = @(22, 80, 443, 3389, 5985)
    )

    foreach ($port in $Ports) {
        $result = Test-NetConnection -ComputerName $Target -Port $port -WarningAction SilentlyContinue
        [PSCustomObject]@{
            Target = $Target
            Port   = $port
            Open   = $result.TcpTestSucceeded
        }
    }
}

Test-PortRange -Target "localhost" -Ports 80, 443, 22, 3389 | Format-Table

# DNS lookup
Resolve-DnsName "example.com" -Type A
Resolve-DnsName "example.com" -Type MX

# SSL certificate check
function Test-SSLCertificate {
    param([string]$Hostname, [int]$Port = 443)

    $tcp = New-Object System.Net.Sockets.TcpClient($Hostname, $Port)
    $ssl = New-Object System.Net.Security.SslStream($tcp.GetStream())
    $ssl.AuthenticateAsClient($Hostname)
    $cert = $ssl.RemoteCertificate

    [PSCustomObject]@{
        Subject   = $cert.Subject
        Issuer    = $cert.Issuer
        NotAfter  = $cert.GetExpirationDateString()
        DaysLeft  = ([datetime]$cert.GetExpirationDateString() - (Get-Date)).Days
    }

    $ssl.Close()
    $tcp.Close()
}
```

## 6. Incident Response

```powershell
# Snapshot running processes
Get-Process | Select-Object Name, Id, Path, StartTime, CPU |
    Export-Csv ".\incident-processes.csv" -NoTypeInformation

# Active network connections
Get-NetTCPConnection -State Established |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess,
        @{N="Process";E={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}} |
    Export-Csv ".\incident-connections.csv" -NoTypeInformation

# Scheduled tasks (persistence check)
Get-ScheduledTask | Where-Object State -eq "Ready" |
    Select-Object TaskName, TaskPath, @{N="Actions";E={$_.Actions.Execute}} |
    Export-Csv ".\incident-tasks.csv" -NoTypeInformation

# Recent file modifications (potential indicators)
Get-ChildItem "C:\Windows\System32" -File |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-1) } |
    Select-Object Name, LastWriteTime, Length
```

---

## Key Takeaways

1. Never store credentials in scripts — use `SecretManagement` or Key Vault
2. Enable PowerShell script block logging for security monitoring
3. Regular audit scripts for permissions, accounts, and compliance are essential
4. `Get-WinEvent` with security event IDs is your primary forensics tool
5. Port scanning and certificate checking catch misconfigurations early
6. Incident response scripts should be pre-written and tested before you need them

---

## Interview Prep

**Q: How do you securely handle credentials in PowerShell scripts?**
A: Never hardcode passwords. Use `Get-Credential` for interactive prompts, `SecretManagement` module for stored secrets, Azure Key Vault for cloud workloads, or environment variables in CI/CD pipelines. For service accounts, use Managed Identities in Azure or gMSAs in AD.

**Q: How would you detect brute-force login attempts with PowerShell?**
A: Query the Security event log for Event ID 4625 (failed logons) using `Get-WinEvent -FilterHashtable`. Group by source IP and account name, then flag IPs with more than N failures in a time window. For AD, also check Event ID 4740 (account lockout).

**Q: What PowerShell security features should be enabled in an enterprise?**
A: Script Block Logging (logs all PowerShell code that runs), Module Logging (logs module usage), Transcription (records full session transcripts), Constrained Language Mode (limits dangerous .NET access), and AMSI integration (Anti-Malware Scan Interface). Set execution policy to `AllSigned` in production.
