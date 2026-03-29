# =============================================================================
# Day 11 — DevOps Pipelines and REST APIs
# =============================================================================

Write-Host "=== DevOps Pipeline Simulation ===" -ForegroundColor Cyan

# --- Pipeline Script Example ---
Write-Host "`n--- CI/CD Deploy Script ---" -ForegroundColor Yellow

function Invoke-DeployPipeline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("dev", "staging", "production")]
        [string]$Environment,

        [string]$Version = "1.0.0",
        [switch]$SkipTests
    )

    $ErrorActionPreference = "Stop"
    $pipelineStart = Get-Date

    Write-Host "`n==============================" -ForegroundColor Cyan
    Write-Host " DEPLOYMENT PIPELINE" -ForegroundColor Cyan
    Write-Host " Environment: $Environment" -ForegroundColor Cyan
    Write-Host " Version: $Version" -ForegroundColor Cyan
    Write-Host "==============================`n" -ForegroundColor Cyan

    $stages = @(
        @{Name="Checkout"; Action={ Write-Output "  Cloning repository..." }}
        @{Name="Restore"; Action={ Write-Output "  Restoring dependencies..." }}
        @{Name="Build"; Action={ Write-Output "  Building application v$Version..." }}
        @{Name="Test"; Action={
            if ($SkipTests) { Write-Output "  Tests SKIPPED"; return }
            Write-Output "  Running 42 unit tests..."
            Write-Output "  Running 15 integration tests..."
            Write-Output "  All 57 tests passed"
        }}
        @{Name="Package"; Action={ Write-Output "  Creating deployment package..." }}
        @{Name="Deploy"; Action={
            Write-Output "  Deploying to $Environment..."
            Write-Output "  Updating resource group: rg-$Environment"
            Write-Output "  Applying ARM template..."
            Write-Output "  Configuring app settings..."
        }}
        @{Name="Verify"; Action={
            Write-Output "  Running smoke tests..."
            Write-Output "  Health check: OK"
            Write-Output "  Response time: 145ms"
        }}
    )

    $passed = 0
    $failed = 0

    foreach ($stage in $stages) {
        Write-Host "[$($stage.Name)]" -ForegroundColor Yellow -NoNewline
        try {
            & $stage.Action
            Write-Host " PASSED" -ForegroundColor Green
            $passed++
        } catch {
            Write-Host " FAILED: $($_.Exception.Message)" -ForegroundColor Red
            $failed++
            if ($stage.Name -in "Build", "Deploy") { throw "Critical stage failed" }
        }
    }

    $duration = (Get-Date) - $pipelineStart

    Write-Host "`n=============================="
    Write-Host " Pipeline Complete"
    Write-Host " Stages: $passed passed, $failed failed"
    Write-Host " Duration: $([math]::Round($duration.TotalSeconds, 1))s"
    Write-Host "=============================="
}

Invoke-DeployPipeline -Environment "staging" -Version "2.1.0"

# --- REST API Examples ---
Write-Host "`n=== REST API Calls ===" -ForegroundColor Cyan

# GitHub API (public, no auth needed)
Write-Host "`n--- GitHub API ---" -ForegroundColor Yellow
try {
    $repo = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell" -Method Get -ErrorAction Stop
    Write-Output "Repo: $($repo.full_name)"
    Write-Output "Stars: $($repo.stargazers_count)"
    Write-Output "Language: $($repo.language)"
    Write-Output "Open Issues: $($repo.open_issues_count)"
} catch {
    Write-Output "API call failed (may need internet): $($_.Exception.Message)"
}

# Simulated API call pattern
Write-Host "`n--- Webhook Notification Pattern ---" -ForegroundColor Yellow

function Send-SimWebhook {
    param(
        [string]$WebhookUrl = "https://hooks.example.com/deploy",
        [hashtable]$Payload
    )

    $body = $Payload | ConvertTo-Json -Depth 3
    Write-Output "POST $WebhookUrl"
    Write-Output "Body: $body"
    Write-Output "Status: 200 OK (simulated)"
}

Send-SimWebhook -Payload @{
    event   = "deployment"
    env     = "staging"
    version = "2.1.0"
    status  = "success"
    time    = (Get-Date -Format "o")
}

# --- Pipeline YAML Generation ---
Write-Host "`n--- Generate Pipeline YAML ---" -ForegroundColor Yellow

$pipelineYaml = @"
# Generated Azure DevOps Pipeline
trigger:
  - main

pool:
  vmImage: 'windows-latest'

variables:
  environment: 'staging'

stages:
  - stage: Build
    jobs:
      - job: BuildJob
        steps:
          - task: PowerShell@2
            displayName: 'Build Application'
            inputs:
              targetType: 'filePath'
              filePath: './scripts/build.ps1'

  - stage: Test
    dependsOn: Build
    jobs:
      - job: TestJob
        steps:
          - task: PowerShell@2
            displayName: 'Run Pester Tests'
            inputs:
              targetType: 'inline'
              script: |
                Install-Module Pester -Force -Scope CurrentUser
                Invoke-Pester -Path ./tests -OutputFormat NUnitXml -OutputFile TestResults.xml

  - stage: Deploy
    dependsOn: Test
    jobs:
      - job: DeployJob
        steps:
          - task: AzurePowerShell@5
            displayName: 'Deploy to Azure'
            inputs:
              azureSubscription: 'my-connection'
              ScriptType: 'FilePath'
              ScriptPath: './scripts/deploy.ps1'
"@

Write-Output $pipelineYaml
