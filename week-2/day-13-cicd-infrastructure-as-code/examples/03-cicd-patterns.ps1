# =============================================================================
# Day 13 — CI/CD Patterns
# =============================================================================

Write-Host "=== CI/CD Patterns ===" -ForegroundColor Cyan

# --- Build Script ---
Write-Host "`n--- Build Script Pattern ---" -ForegroundColor Yellow

function Invoke-Build {
    [CmdletBinding()]
    param(
        [ValidateSet("Debug", "Release")]
        [string]$Configuration = "Release",

        [string]$Version = "1.0.0",
        [string]$OutputPath = (Join-Path $env:TEMP "build-output")
    )

    $ErrorActionPreference = "Stop"
    $buildStart = Get-Date

    Write-Output "Build Configuration: $Configuration"
    Write-Output "Version: $Version"
    Write-Output "Output: $OutputPath"

    # Step 1: Clean
    Write-Output "`n[Clean] Removing old build artifacts..."
    if (Test-Path $OutputPath) { Remove-Item $OutputPath -Recurse -Force }
    New-Item $OutputPath -ItemType Directory -Force | Out-Null

    # Step 2: Analyze
    Write-Output "[Analyze] Running script analyzer..."
    # Invoke-ScriptAnalyzer -Path ".\src" -Recurse -Severity Error

    # Step 3: Test
    Write-Output "[Test] Running Pester tests..."
    # $testResults = Invoke-Pester -PassThru
    # if ($testResults.FailedCount -gt 0) { throw "$($testResults.FailedCount) tests failed" }

    # Step 4: Package
    Write-Output "[Package] Creating module package..."
    $manifest = @{
        ModuleVersion = $Version
        BuildDate     = Get-Date -Format "yyyy-MM-dd"
        Configuration = $Configuration
    }
    $manifest | ConvertTo-Json | Set-Content (Join-Path $OutputPath "build-info.json")

    $duration = (Get-Date) - $buildStart
    Write-Output "`n[Done] Build completed in $([math]::Round($duration.TotalSeconds, 1))s"

    Remove-Item $OutputPath -Recurse -Force
}

Invoke-Build -Configuration "Release" -Version "2.1.0"

# --- GitHub Actions YAML Generator ---
Write-Host "`n--- GitHub Actions Generator ---" -ForegroundColor Yellow

function New-GitHubActionsWorkflow {
    param(
        [string]$ModuleName,
        [string[]]$TestPaths = @("./tests"),
        [switch]$IncludeDeploy
    )

    $yaml = @"
name: $ModuleName CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Dependencies
        shell: pwsh
        run: |
          Install-Module Pester -Force -Scope CurrentUser
          Install-Module PSScriptAnalyzer -Force -Scope CurrentUser

      - name: Run Script Analyzer
        shell: pwsh
        run: |
          `$results = Invoke-ScriptAnalyzer -Path . -Recurse -Severity Error
          if (`$results) {
              `$results | Format-Table -AutoSize
              throw "Script Analyzer found `$(`$results.Count) errors"
          }

      - name: Run Pester Tests
        shell: pwsh
        run: |
          `$config = New-PesterConfiguration
          `$config.TestResult.Enabled = `$true
          `$config.TestResult.OutputPath = 'TestResults.xml'
          `$config.Output.Verbosity = 'Detailed'
          Invoke-Pester -Configuration `$config

      - name: Upload Test Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: TestResults.xml
"@

    if ($IncludeDeploy) {
        $yaml += @"

  deploy:
    needs: test
    runs-on: windows-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4

      - name: Publish Module
        shell: pwsh
        run: |
          Publish-Module -Path ./$ModuleName -NuGetApiKey `${{ secrets.PS_GALLERY_KEY }}
"@
    }

    $yaml
}

$workflow = New-GitHubActionsWorkflow -ModuleName "ServerTools" -IncludeDeploy
Write-Output $workflow

# --- IaC Configuration Data ---
Write-Host "`n--- Infrastructure Config ---" -ForegroundColor Yellow

$envConfig = @{
    Dev = @{
        ResourceGroup = "rg-dev-eastus"
        VMSize = "Standard_B1s"
        Replicas = 1
        AutoShutdown = $true
    }
    Staging = @{
        ResourceGroup = "rg-staging-eastus"
        VMSize = "Standard_B2s"
        Replicas = 2
        AutoShutdown = $false
    }
    Production = @{
        ResourceGroup = "rg-prod-eastus"
        VMSize = "Standard_D4s_v3"
        Replicas = 3
        AutoShutdown = $false
    }
}

foreach ($env in $envConfig.GetEnumerator()) {
    Write-Output "  $($env.Key): $($env.Value.Replicas)x $($env.Value.VMSize) in $($env.Value.ResourceGroup)"
}
