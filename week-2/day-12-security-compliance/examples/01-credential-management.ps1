# =============================================================================
# Day 12 — Credential Management
# =============================================================================

Write-Host "=== Credential Management ===" -ForegroundColor Cyan

# --- BAD: Hardcoded credentials (NEVER DO THIS) ---
Write-Host "`n--- BAD Practice: Hardcoded Credentials ---" -ForegroundColor Red
Write-Host '  $password = "MyP@ssw0rd"  # NEVER DO THIS!' -ForegroundColor Red
Write-Host '  Passwords in scripts end up in git history, logs, and memory dumps' -ForegroundColor Red

# --- GOOD: SecureString ---
Write-Host "`n--- GOOD Practice: SecureString ---" -ForegroundColor Green

$securePassword = ConvertTo-SecureString "DemoPassword123!" -AsPlainText -Force
Write-Output "  SecureString created (encrypted in memory)"
Write-Output "  Type: $($securePassword.GetType().Name)"
Write-Output "  Length: $($securePassword.Length)"

# Create credential object
$credential = New-Object PSCredential("admin@company.com", $securePassword)
Write-Output "  Credential: $($credential.UserName)"

# --- Saving/Loading encrypted passwords ---
Write-Host "`n--- Encrypted Password File ---" -ForegroundColor Yellow

$encFile = Join-Path $env:TEMP "encrypted-demo.txt"

# Save (encrypted with current user's DPAPI key — only this user on this machine can decrypt)
$securePassword | ConvertFrom-SecureString | Set-Content $encFile
Write-Output "  Password saved to: $encFile"

# Load
$loadedPwd = Get-Content $encFile | ConvertTo-SecureString
$loadedCred = New-Object PSCredential("admin", $loadedPwd)
Write-Output "  Password loaded and decrypted: $($loadedCred.UserName)"

# Cleanup
Remove-Item $encFile -Force

# --- Environment Variables (for CI/CD) ---
Write-Host "`n--- Environment Variables (CI/CD Pattern) ---" -ForegroundColor Yellow

# In CI/CD, secrets are injected as environment variables
# $dbPassword = $env:DB_PASSWORD
# $apiKey = $env:API_KEY

Write-Output "  CI/CD pattern: Read from `$env:SECRET_NAME"
Write-Output "  GitHub Actions: `${{ secrets.MY_SECRET }}"
Write-Output "  Azure DevOps: `$(MY_SECRET) in pipeline variables"

# --- Key Vault Pattern (Simulated) ---
Write-Host "`n--- Azure Key Vault Pattern ---" -ForegroundColor Yellow

function Get-SimKeyVaultSecret {
    param(
        [string]$VaultName,
        [string]$SecretName
    )

    Write-Verbose "Retrieving secret '$SecretName' from vault '$VaultName'"

    # In real Azure:
    # $secret = Get-AzKeyVaultSecret -VaultName $VaultName -Name $SecretName -AsPlainText
    # return $secret

    # Simulated
    $secrets = @{
        "db-connection" = "Server=db01;Database=app;User=admin;Password=***"
        "api-key"       = "sk-abc123..."
        "ssl-cert-pwd"  = "cert-password-***"
    }

    if ($secrets.ContainsKey($SecretName)) {
        return $secrets[$SecretName]
    }
    throw "Secret '$SecretName' not found in vault '$VaultName'"
}

$dbConn = Get-SimKeyVaultSecret -VaultName "kv-production" -SecretName "db-connection"
Write-Output "  Retrieved: db-connection = $dbConn"
