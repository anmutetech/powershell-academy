# =============================================================================
# Day 10 Daily Challenge — Azure Infrastructure Provisioner (Solution)
# =============================================================================

Write-Host "===== Azure Infrastructure Provisioner =====" -ForegroundColor Cyan

# Parameters
$environment = "staging"
$location = "westus2"
$vmSize = "Standard_B2s"

# Naming conventions
$naming = @{
    ResourceGroup  = "rg-$environment-$location"
    VNet           = "vnet-$environment"
    Subnet         = "snet-$environment-web"
    NSG            = "nsg-$environment-web"
    StorageAccount = "st$($environment)$(Get-Random -Minimum 100 -Maximum 999)"
    VM             = "vm-$environment-web-01"
}

# Tags
$tags = @{
    Environment = $environment
    ManagedBy   = "PowerShell"
    CreatedDate = (Get-Date -Format "yyyy-MM-dd")
    CostCenter  = "IT-LAB"
}

# VM costs (monthly estimates)
$vmCosts = @{
    "Standard_B1s"    = 7.59
    "Standard_B1ms"   = 15.18
    "Standard_B2s"    = 30.37
    "Standard_B2ms"   = 60.74
    "Standard_D2s_v3" = 70.08
    "Standard_D4s_v3" = 140.16
}

# Display plan
Write-Host "`nEnvironment: $environment" -ForegroundColor Yellow
Write-Host "Location:    $location"
Write-Host "VM Size:     $vmSize"
Write-Host ""

# Validate
$validLocations = @("eastus", "westus2", "centralus", "westeurope", "northeurope")
if ($location -notin $validLocations) {
    throw "Invalid location. Valid: $($validLocations -join ', ')"
}
if (-not $vmCosts.ContainsKey($vmSize)) {
    throw "Invalid VM size. Valid: $($vmCosts.Keys -join ', ')"
}

# Deployment tracking
$deployedResources = @()
$totalSteps = 5
$step = 0

function Deploy-Resource {
    param(
        [string]$Type,
        [string]$Name,
        [scriptblock]$Action
    )

    $script:step++
    Write-Host ("[$script:step/$totalSteps] Creating {0}...  " -f $Type) -NoNewline
    Write-Host ("{0,-25}" -f $Name) -NoNewline -ForegroundColor White

    try {
        & $Action
        Write-Host "OK" -ForegroundColor Green
        $script:deployedResources += [PSCustomObject]@{
            Step     = $script:step
            Type     = $Type
            Name     = $Name
            Status   = "Created"
            Location = $location
        }
    } catch {
        Write-Host "FAILED" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $script:deployedResources += [PSCustomObject]@{
            Step = $script:step; Type = $Type; Name = $Name; Status = "Failed"
            Location = $location
        }
        throw "Deployment failed at step $script:step"
    }
}

try {
    # 1. Resource Group
    Deploy-Resource -Type "Resource Group" -Name $naming.ResourceGroup -Action {
        # Simulated: New-AzResourceGroup -Name $naming.ResourceGroup -Location $location -Tag $tags
    }

    # 2. Virtual Network
    Deploy-Resource -Type "Virtual Network" -Name $naming.VNet -Action {
        # Simulated: New-AzVirtualNetwork with subnet config
    }

    # 3. NSG
    Deploy-Resource -Type "NSG" -Name $naming.NSG -Action {
        # Simulated: New-AzNetworkSecurityGroup with rules
    }

    # 4. Storage Account
    Deploy-Resource -Type "Storage Account" -Name $naming.StorageAccount -Action {
        # Simulated: New-AzStorageAccount
    }

    # 5. Virtual Machine
    Deploy-Resource -Type "Virtual Machine" -Name $naming.VM -Action {
        # Simulated: New-AzVM with all configurations
    }

} catch {
    Write-Host "`nDeployment failed. Deployed resources:" -ForegroundColor Red
    $deployedResources | Where-Object Status -eq "Created" | ForEach-Object {
        Write-Host "  Would rollback: $($_.Type) '$($_.Name)'" -ForegroundColor Yellow
    }
}

# Summary
$successful = ($deployedResources | Where-Object Status -eq "Created").Count
$failed = ($deployedResources | Where-Object Status -eq "Failed").Count

Write-Host "`n===== Deployment Summary =====" -ForegroundColor Cyan
Write-Host "  Resources created: $successful/$totalSteps" -ForegroundColor $(if ($failed -eq 0) {"Green"} else {"Yellow"})

# Cost
$monthlyCost = $vmCosts[$vmSize]
$storageCost = 5.00  # Estimate for Standard_LRS
$totalCost = $monthlyCost + $storageCost
Write-Host ("  Estimated monthly cost: `${0:N2}" -f $totalCost) -ForegroundColor Yellow
Write-Host "    VM ($vmSize): `$$monthlyCost"
Write-Host "    Storage: `$$storageCost"

# Tags
Write-Host "  Tags applied:" -ForegroundColor Cyan
$tags.GetEnumerator() | ForEach-Object { Write-Host "    $($_.Key) = $($_.Value)" }

# Export JSON
$report = @{
    DeploymentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Environment    = $environment
    Location       = $location
    Resources      = $deployedResources
    Tags           = $tags
    EstimatedCost  = @{ Monthly = $totalCost; VM = $monthlyCost; Storage = $storageCost }
    NamingUsed     = $naming
}

$reportPath = Join-Path $PSScriptRoot "deployment-$environment-$(Get-Date -Format 'yyyy-MM-dd').json"
$report | ConvertTo-Json -Depth 5 | Set-Content -Path $reportPath
Write-Host "`n  Report saved to: $reportPath" -ForegroundColor Green
