# =============================================================================
# Day 14 Capstone — Enterprise Infrastructure Automation Platform (Starter)
# =============================================================================

$moduleName = "EnterpriseTools"
$moduleBase = Join-Path $PSScriptRoot $moduleName

# Create module structure
@("Public", "Private", "Tests", "Config") | ForEach-Object {
    New-Item -Path (Join-Path $moduleBase $_) -ItemType Directory -Force | Out-Null
}

Write-Host "Module structure created at: $moduleBase" -ForegroundColor Cyan
Write-Host @"

Directory structure:
  EnterpriseTools/
  ├── EnterpriseTools.psd1     # TODO: Module manifest
  ├── EnterpriseTools.psm1     # TODO: Module loader
  ├── Config/
  │   └── environments.psd1    # TODO: Environment configs
  ├── Public/
  │   ├── New-UserOnboarding.ps1        # TODO: AD onboarding
  │   ├── Get-InfrastructureHealth.ps1  # TODO: Health monitoring
  │   ├── Invoke-SecurityAudit.ps1      # TODO: Security scanning
  │   ├── Deploy-AzureEnvironment.ps1   # TODO: Azure IaC
  │   └── Export-DashboardReport.ps1    # TODO: Reporting
  ├── Private/
  │   ├── Write-Log.ps1                 # TODO: Logging helper
  │   └── Get-HealthStatus.ps1          # TODO: Status helper
  └── Tests/
      ├── Get-InfrastructureHealth.Tests.ps1
      ├── Invoke-SecurityAudit.Tests.ps1
      └── Export-DashboardReport.Tests.ps1

Steps:
  1. Implement Private/ helpers first
  2. Build Public/ functions one at a time
  3. Write Tests/ alongside each function
  4. Create the .psm1 loader and .psd1 manifest
  5. Test: Import-Module ./EnterpriseTools -Force
  6. Add CI workflow

Good luck!
"@ -ForegroundColor Yellow
