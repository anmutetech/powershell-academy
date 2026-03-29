# =============================================================================
# Day 11 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Automation Runbook ---
Write-Host "=== Exercise 1: VM Schedule Runbook ===" -ForegroundColor Cyan

function Invoke-VMScheduleRunbook {
    [CmdletBinding()]
    param()

    $currentHour = (Get-Date).Hour
    Write-Output "Current hour: $currentHour"

    $vms = @(
        [PSCustomObject]@{Name="vm-dev-01";State="Running";ShutdownHour=19;StartHour=7}
        [PSCustomObject]@{Name="vm-dev-02";State="Deallocated";ShutdownHour=19;StartHour=7}
        [PSCustomObject]@{Name="vm-batch-01";State="Deallocated";ShutdownHour=6;StartHour=22}
        [PSCustomObject]@{Name="vm-prod-01";State="Running";ShutdownHour=$null;StartHour=$null}
    )

    foreach ($vm in $vms) {
        if ($null -eq $vm.ShutdownHour) {
            Write-Output "  $($vm.Name): No schedule (always on)"
            continue
        }

        $shouldRun = ($currentHour -ge $vm.StartHour -and $currentHour -lt $vm.ShutdownHour)

        if ($shouldRun -and $vm.State -eq "Deallocated") {
            Write-Output "  $($vm.Name): Starting (scheduled on at $($vm.StartHour):00)"
        } elseif (-not $shouldRun -and $vm.State -eq "Running") {
            Write-Output "  $($vm.Name): Stopping (scheduled off at $($vm.ShutdownHour):00)"
        } else {
            Write-Output "  $($vm.Name): OK ($($vm.State))"
        }
    }
}

Invoke-VMScheduleRunbook

# --- Exercise 2: ARM Template Generator ---
Write-Host "`n=== Exercise 2: ARM Template Generator ===" -ForegroundColor Cyan

function New-ARMTemplate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("StorageAccount", "AppService", "VirtualNetwork")]
        [string]$ResourceType,

        [Parameter(Mandatory)]
        [string]$ResourceName,

        [string]$Location = "eastus"
    )

    $resourceDefinitions = @{
        StorageAccount = @{
            type = "Microsoft.Storage/storageAccounts"
            apiVersion = "2023-01-01"
            sku = @{ name = "Standard_LRS" }
            kind = "StorageV2"
        }
        AppService = @{
            type = "Microsoft.Web/sites"
            apiVersion = "2022-09-01"
            kind = "app"
            properties = @{ serverFarmId = "[parameters('appServicePlanId')]" }
        }
        VirtualNetwork = @{
            type = "Microsoft.Network/virtualNetworks"
            apiVersion = "2023-05-01"
            properties = @{
                addressSpace = @{ addressPrefixes = @("10.0.0.0/16") }
            }
        }
    }

    $resource = $resourceDefinitions[$ResourceType]
    $resource.name = $ResourceName
    $resource.location = $Location

    $template = @{
        '$schema' = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
        contentVersion = "1.0.0.0"
        resources = @($resource)
    }

    $json = $template | ConvertTo-Json -Depth 10
    Write-Output "Generated $ResourceType template for '$ResourceName'"
    Write-Output $json
}

New-ARMTemplate -ResourceType "StorageAccount" -ResourceName "stexample001" | Out-Null
Write-Output "Template generated successfully"

# --- Exercise 3: Pipeline Simulator ---
Write-Host "`n=== Exercise 3: Pipeline Simulator ===" -ForegroundColor Cyan

function Invoke-Pipeline {
    [CmdletBinding()]
    param(
        [PSCustomObject[]]$Stages,
        [int]$MaxRetries = 1
    )

    $results = @()
    $pipelineStart = Get-Date

    foreach ($stage in $Stages) {
        $stageStart = Get-Date
        $attempt = 0
        $success = $false

        Write-Host "  Stage: $($stage.Name)" -NoNewline

        while ($attempt -lt $MaxRetries -and -not $success) {
            $attempt++
            try {
                & $stage.Action
                $success = $true
            } catch {
                if ($attempt -lt $MaxRetries) {
                    Write-Host " (retry $attempt)" -ForegroundColor Yellow -NoNewline
                }
            }
        }

        $duration = (Get-Date) - $stageStart
        if ($success) {
            Write-Host " PASSED ($([math]::Round($duration.TotalMilliseconds))ms)" -ForegroundColor Green
        } else {
            Write-Host " FAILED" -ForegroundColor Red
        }

        $results += [PSCustomObject]@{
            Stage = $stage.Name; Success = $success; Duration = $duration.TotalMilliseconds; Attempts = $attempt
        }
    }

    $totalDuration = (Get-Date) - $pipelineStart
    $passed = ($results | Where-Object Success).Count

    Write-Host "`n  Pipeline: $passed/$($results.Count) stages passed in $([math]::Round($totalDuration.TotalSeconds, 1))s"
    $results
}

$stages = @(
    [PSCustomObject]@{Name="Build"; Action={ Start-Sleep -Milliseconds 100 }}
    [PSCustomObject]@{Name="Test"; Action={ Start-Sleep -Milliseconds 200 }}
    [PSCustomObject]@{Name="Deploy"; Action={ Start-Sleep -Milliseconds 150 }}
)

Invoke-Pipeline -Stages $stages | Format-Table

# --- Exercise 4: REST API Client ---
Write-Host "=== Exercise 4: REST API Client ===" -ForegroundColor Cyan

function Invoke-ApiWithRetry {
    [CmdletBinding()]
    param(
        [string]$Uri,
        [string]$Method = "Get",
        [int]$MaxRetries = 3,
        [int]$DelaySeconds = 2
    )

    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Write-Verbose "API call attempt $i: $Method $Uri"
            $result = Invoke-RestMethod -Uri $Uri -Method $Method -ErrorAction Stop
            Write-Verbose "Success on attempt $i"
            return $result
        } catch {
            Write-Warning "Attempt $i failed: $($_.Exception.Message)"
            if ($i -lt $MaxRetries) {
                Start-Sleep -Seconds ($DelaySeconds * $i)
            } else {
                throw "API call failed after $MaxRetries attempts"
            }
        }
    }
}

try {
    $data = Invoke-ApiWithRetry -Uri "https://api.github.com/repos/PowerShell/PowerShell" -Verbose
    Write-Output "API Result: $($data.full_name) ($($data.stargazers_count) stars)"
} catch {
    Write-Output "API unavailable: $($_.Exception.Message)"
}

# --- Exercise 5: Deployment Orchestrator (simplified) ---
Write-Host "`n=== Exercise 5: Deployment Orchestrator ===" -ForegroundColor Cyan

$manifest = @{
    Environment = "staging"
    Resources = @(
        @{Name="rg-staging";Type="ResourceGroup";DependsOn=@()}
        @{Name="vnet-staging";Type="VirtualNetwork";DependsOn=@("rg-staging")}
        @{Name="st-staging";Type="StorageAccount";DependsOn=@("rg-staging")}
        @{Name="vm-staging";Type="VirtualMachine";DependsOn=@("vnet-staging","st-staging")}
    )
}

$deployed = @()
foreach ($resource in $manifest.Resources) {
    $depsReady = ($resource.DependsOn | Where-Object { $_ -notin $deployed }).Count -eq 0

    if ($depsReady) {
        Write-Host "  Deploying: $($resource.Name) ($($resource.Type))" -ForegroundColor Green
        $deployed += $resource.Name
    } else {
        Write-Host "  Waiting: $($resource.Name) (deps: $($resource.DependsOn -join ', '))" -ForegroundColor Yellow
    }
}
Write-Output "Deployed $($deployed.Count) resources"
