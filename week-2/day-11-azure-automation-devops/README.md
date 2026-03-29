# Day 11 — Azure Automation & DevOps

Azure Automation and DevOps practices bring PowerShell into the CI/CD world. Today you learn runbooks, ARM/Bicep templates, Azure DevOps pipelines, and how to integrate PowerShell into automated workflows.

---

## Video Resources

- [Azure Automation Runbooks](https://www.youtube.com/watch?v=iJH2bS1wGBs)
- [ARM Templates Explained](https://www.youtube.com/watch?v=Ge_Sp-1lWZ4)
- [Azure DevOps Pipelines](https://www.youtube.com/watch?v=NuYDAs3kNV8)

---

## 1. Azure Automation Accounts

Azure Automation lets you run PowerShell scripts (runbooks) on a schedule or on-demand in the cloud.

```powershell
# Create automation account
New-AzAutomationAccount -Name "auto-devops-lab" `
    -ResourceGroupName "rg-automation" `
    -Location "eastus"

# Import a runbook
Import-AzAutomationRunbook -Name "Stop-DevVMs" `
    -ResourceGroupName "rg-automation" `
    -AutomationAccountName "auto-devops-lab" `
    -Path ".\Stop-DevVMs.ps1" `
    -Type PowerShell

# Publish the runbook
Publish-AzAutomationRunbook -Name "Stop-DevVMs" `
    -ResourceGroupName "rg-automation" `
    -AutomationAccountName "auto-devops-lab"

# Start a runbook
Start-AzAutomationRunbook -Name "Stop-DevVMs" `
    -ResourceGroupName "rg-automation" `
    -AutomationAccountName "auto-devops-lab" `
    -Parameters @{ Environment = "Dev" }
```

### Example Runbook: Stop Dev VMs at Night

```powershell
# Stop-DevVMs.ps1
param(
    [string]$Environment = "Dev",
    [string]$TagName = "Environment"
)

# Authenticate using Managed Identity
Connect-AzAccount -Identity

# Find and stop VMs
$vms = Get-AzVM -Status | Where-Object {
    $_.Tags[$TagName] -eq $Environment -and
    $_.PowerState -eq "VM running"
}

foreach ($vm in $vms) {
    Write-Output "Stopping: $($vm.Name)"
    Stop-AzVM -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force
}

Write-Output "Stopped $($vms.Count) $Environment VMs"
```

## 2. Schedules

```powershell
# Create a schedule (weekdays at 7 PM)
New-AzAutomationSchedule -Name "Weekday-7PM" `
    -ResourceGroupName "rg-automation" `
    -AutomationAccountName "auto-devops-lab" `
    -StartTime (Get-Date "19:00:00").AddDays(1) `
    -WeekInterval 1 `
    -DaysOfWeek Monday, Tuesday, Wednesday, Thursday, Friday

# Link runbook to schedule
Register-AzAutomationScheduledRunbook -RunbookName "Stop-DevVMs" `
    -ScheduleName "Weekday-7PM" `
    -ResourceGroupName "rg-automation" `
    -AutomationAccountName "auto-devops-lab" `
    -Parameters @{ Environment = "Dev" }
```

## 3. ARM Templates with PowerShell

ARM (Azure Resource Manager) templates define infrastructure as JSON.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "storageAccountName": {
            "type": "string",
            "metadata": { "description": "Storage account name" }
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]"
        }
    },
    "resources": [
        {
            "type": "Microsoft.Storage/storageAccounts",
            "apiVersion": "2023-01-01",
            "name": "[parameters('storageAccountName')]",
            "location": "[parameters('location')]",
            "sku": { "name": "Standard_LRS" },
            "kind": "StorageV2"
        }
    ],
    "outputs": {
        "storageEndpoint": {
            "type": "string",
            "value": "[reference(parameters('storageAccountName')).primaryEndpoints.blob]"
        }
    }
}
```

### Deploy ARM Template with PowerShell

```powershell
# Deploy template
New-AzResourceGroupDeployment -Name "deploy-storage" `
    -ResourceGroupName "rg-powershell-lab" `
    -TemplateFile ".\storage-template.json" `
    -storageAccountName "stmyapp001" `
    -Verbose

# Deploy with parameter file
New-AzResourceGroupDeployment -Name "deploy-storage" `
    -ResourceGroupName "rg-powershell-lab" `
    -TemplateFile ".\storage-template.json" `
    -TemplateParameterFile ".\storage-params.json"

# What-if deployment (preview changes)
New-AzResourceGroupDeployment -Name "deploy-storage" `
    -ResourceGroupName "rg-powershell-lab" `
    -TemplateFile ".\storage-template.json" `
    -storageAccountName "stmyapp001" `
    -WhatIf

# Test template validity
Test-AzResourceGroupDeployment -ResourceGroupName "rg-powershell-lab" `
    -TemplateFile ".\storage-template.json" `
    -storageAccountName "stmyapp001"
```

## 4. Azure DevOps Integration

### PowerShell in Azure Pipelines (YAML)

```yaml
# azure-pipelines.yml
trigger:
  - main

pool:
  vmImage: 'windows-latest'

steps:
  - task: PowerShell@2
    displayName: 'Run Tests'
    inputs:
      targetType: 'inline'
      script: |
        $results = Invoke-Pester -Path ./tests -PassThru
        if ($results.FailedCount -gt 0) {
            throw "$($results.FailedCount) tests failed"
        }

  - task: AzurePowerShell@5
    displayName: 'Deploy to Azure'
    inputs:
      azureSubscription: 'my-service-connection'
      ScriptType: 'FilePath'
      ScriptPath: './deploy/deploy.ps1'
      azurePowerShellVersion: 'LatestVersion'
      ScriptArguments: '-Environment production'
```

### PowerShell Deploy Script for Pipelines

```powershell
# deploy/deploy.ps1
param(
    [Parameter(Mandatory)]
    [ValidateSet("dev", "staging", "production")]
    [string]$Environment
)

$ErrorActionPreference = "Stop"

Write-Output "Deploying to $Environment..."

# Deploy ARM template
$params = @{
    ResourceGroupName  = "rg-$Environment"
    TemplateFile       = "./templates/main.json"
    TemplateParameterFile = "./templates/params-$Environment.json"
    Name               = "deploy-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
}

$result = New-AzResourceGroupDeployment @params -Verbose
Write-Output "Deployment status: $($result.ProvisioningState)"
```

## 5. Desired State Configuration (DSC)

DSC ensures servers stay in a defined configuration.

```powershell
# Define a configuration
Configuration WebServerConfig {
    Node "localhost" {
        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        WindowsFeature IISManagement {
            Ensure    = "Present"
            Name      = "Web-Mgmt-Console"
            DependsOn = "[WindowsFeature]IIS"
        }

        File WebContent {
            Ensure          = "Present"
            DestinationPath = "C:\inetpub\wwwroot\index.html"
            Contents        = "<html><body><h1>Hello from DSC!</h1></body></html>"
            DependsOn       = "[WindowsFeature]IIS"
        }
    }
}

# Compile the configuration
WebServerConfig -OutputPath ".\WebServerConfig"

# Apply it
Start-DscConfiguration -Path ".\WebServerConfig" -Wait -Verbose -Force
```

## 6. REST API Calls

PowerShell can call any REST API — essential for integrating with DevOps tools.

```powershell
# GET request
$response = Invoke-RestMethod -Uri "https://api.github.com/repos/PowerShell/PowerShell" -Method Get
Write-Output "$($response.full_name): $($response.stargazers_count) stars"

# POST with JSON body
$body = @{
    title = "Bug: Script fails on empty input"
    body  = "Steps to reproduce..."
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.github.com/repos/owner/repo/issues" `
    -Method Post -Body $body -ContentType "application/json" `
    -Headers @{ Authorization = "token $env:GITHUB_TOKEN" }

# Azure REST API with token
$token = (Get-AzAccessToken).Token
$headers = @{ Authorization = "Bearer $token" }
$subscriptionId = (Get-AzContext).Subscription.Id

$resources = Invoke-RestMethod `
    -Uri "https://management.azure.com/subscriptions/$subscriptionId/resources?api-version=2021-04-01" `
    -Headers $headers
```

---

## Key Takeaways

1. Azure Automation runbooks let you schedule PowerShell scripts in the cloud
2. ARM templates + `New-AzResourceGroupDeployment` = Infrastructure as Code
3. Always use `-WhatIf` to preview ARM deployments before applying
4. Azure DevOps pipelines can run PowerShell scripts as build/deploy steps
5. DSC ensures servers maintain a desired configuration over time
6. `Invoke-RestMethod` lets PowerShell talk to any API

---

## Interview Prep

**Q: How do you deploy Azure resources using PowerShell?**
A: Two main approaches: (1) Imperative — use Az cmdlets like `New-AzVM`, `New-AzStorageAccount` directly. (2) Declarative — define infrastructure in ARM templates or Bicep, then deploy with `New-AzResourceGroupDeployment`. The declarative approach is preferred for production as it's idempotent and version-controlled.

**Q: What is Azure Automation and when would you use it?**
A: Azure Automation is a cloud service that runs PowerShell or Python runbooks on schedules or triggers. Common uses: stopping dev VMs at night to save costs, patching servers, compliance reporting, and incident response automation. It uses Managed Identities for secure authentication.

**Q: How do you integrate PowerShell into CI/CD pipelines?**
A: In Azure DevOps, use the `PowerShell@2` task for general scripts or `AzurePowerShell@5` for Az-authenticated scripts. In GitHub Actions, use `shell: pwsh` in run steps. Scripts should accept parameters for environment targeting, use `$ErrorActionPreference = "Stop"` for fail-fast behavior, and return proper exit codes.
