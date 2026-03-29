# =============================================================================
# Day 11 — ARM Templates and Infrastructure as Code
# =============================================================================

Write-Host "=== ARM Templates & IaC ===" -ForegroundColor Cyan

# --- Generate an ARM Template ---
Write-Host "`n--- Generating ARM Template ---" -ForegroundColor Yellow

$armTemplate = @{
    '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    contentVersion = "1.0.0.0"
    parameters = @{
        storageAccountName = @{
            type = "string"
            metadata = @{ description = "Name of the storage account" }
        }
        location = @{
            type = "string"
            defaultValue = "[resourceGroup().location]"
        }
        environment = @{
            type = "string"
            allowedValues = @("dev", "staging", "production")
        }
    }
    resources = @(
        @{
            type = "Microsoft.Storage/storageAccounts"
            apiVersion = "2023-01-01"
            name = "[parameters('storageAccountName')]"
            location = "[parameters('location')]"
            sku = @{ name = "Standard_LRS" }
            kind = "StorageV2"
            tags = @{
                Environment = "[parameters('environment')]"
                ManagedBy = "ARM Template"
            }
        }
    )
    outputs = @{
        storageEndpoint = @{
            type = "string"
            value = "[reference(parameters('storageAccountName')).primaryEndpoints.blob]"
        }
    }
}

# Save template
$templatePath = Join-Path $env:TEMP "arm-template.json"
$armTemplate | ConvertTo-Json -Depth 10 | Set-Content -Path $templatePath
Write-Output "Template saved to: $templatePath"

# Display template structure
Write-Host "`nTemplate structure:" -ForegroundColor Yellow
Write-Output "  Parameters: $($armTemplate.parameters.Keys -join ', ')"
Write-Output "  Resources:  $($armTemplate.resources.Count) resource(s)"
Write-Output "  Outputs:    $($armTemplate.outputs.Keys -join ', ')"

# --- Generate Parameter File ---
Write-Host "`n--- Parameter Files ---" -ForegroundColor Yellow

$environments = @{
    dev = @{
        storageAccountName = "stdevapp001"
        environment = "dev"
    }
    staging = @{
        storageAccountName = "ststagingapp001"
        environment = "staging"
    }
    production = @{
        storageAccountName = "stprodapp001"
        environment = "production"
    }
}

foreach ($env in $environments.GetEnumerator()) {
    $paramFile = @{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#"
        contentVersion = "1.0.0.0"
        parameters = @{}
    }
    foreach ($param in $env.Value.GetEnumerator()) {
        $paramFile.parameters[$param.Key] = @{ value = $param.Value }
    }

    Write-Output "  params-$($env.Key).json -> storageAccount: $($env.Value.storageAccountName)"
}

# --- Simulated Deployment ---
Write-Host "`n--- Simulated ARM Deployment ---" -ForegroundColor Yellow

function Deploy-SimARMTemplate {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$TemplatePath,
        [string]$Environment,
        [hashtable]$Parameters
    )

    $deployName = "deploy-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

    if ($PSCmdlet.ShouldProcess("$Environment ($deployName)", "Deploy ARM Template")) {
        Write-Output "Deployment: $deployName"
        Write-Output "Environment: $Environment"
        Write-Output "Parameters:"
        $Parameters.GetEnumerator() | ForEach-Object { Write-Output "  $($_.Key) = $($_.Value)" }

        # Simulate deployment steps
        $steps = @("Validating template...", "Creating resources...", "Configuring settings...", "Finalizing...")
        foreach ($step in $steps) {
            Write-Output "  $step"
            Start-Sleep -Milliseconds 300
        }

        Write-Output "Deployment Status: Succeeded"
    }
}

Deploy-SimARMTemplate -TemplatePath $templatePath -Environment "staging" -Parameters $environments.staging

# Cleanup
Remove-Item $templatePath -Force -ErrorAction SilentlyContinue
