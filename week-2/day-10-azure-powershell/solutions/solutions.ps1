# =============================================================================
# Day 10 — Exercise Solutions (Simulated Azure)
# =============================================================================

# --- Shared Simulated Data ---
$script:resourceGroups = @(
    @{Name="rg-prod-web";Location="eastus";Tags=@{Env="Prod";Owner="DevOps";CostCenter="IT-001"};Resources=3}
    @{Name="rg-prod-db";Location="eastus";Tags=@{Env="Prod";Owner="DBA";CostCenter="IT-002"};Resources=2}
    @{Name="rg-staging";Location="westus2";Tags=@{Env="Staging"};Resources=1}
    @{Name="rg-dev";Location="eastus";Tags=@{Env="Dev";Owner="Dev Team"};Resources=1}
    @{Name="rg-empty";Location="eastus";Tags=@{};Resources=0}
)

# --- Exercise 1: Resource Group Manager ---
Write-Host "=== Exercise 1: Resource Group Manager ===" -ForegroundColor Cyan

function New-SimResourceGroup {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Location,
        [Parameter(Mandatory)][hashtable]$Tags
    )

    $required = @("Env", "Owner", "CostCenter")
    $missing = $required | Where-Object { -not $Tags.ContainsKey($_) }
    if ($missing) { throw "Missing required tags: $($missing -join ', ')" }

    if ($PSCmdlet.ShouldProcess($Name, "Create resource group")) {
        Write-Output "Created: $Name in $Location"
    }
}

# Find non-compliant RGs
$requiredTags = @("Env", "Owner", "CostCenter")
Write-Host "Non-compliant resource groups:" -ForegroundColor Yellow
$script:resourceGroups | ForEach-Object {
    $missing = $requiredTags | Where-Object { -not $_.Tags.ContainsKey($_) }
    if ($missing) {
        Write-Output "  $($_.Name): missing $($missing -join ', ')"
    }
}

# Empty RGs
Write-Host "`nEmpty resource groups:" -ForegroundColor Yellow
$script:resourceGroups | Where-Object Resources -eq 0 | ForEach-Object { Write-Output "  $($_.Name)" }

# --- Exercise 2: VM Fleet Manager ---
Write-Host "`n=== Exercise 2: VM Fleet Manager ===" -ForegroundColor Cyan

$vms = @(
    [PSCustomObject]@{Name="vm-web-01";Env="Prod";State="Running";Cores=2;CostPerHour=0.10}
    [PSCustomObject]@{Name="vm-web-02";Env="Prod";State="Running";Cores=2;CostPerHour=0.10}
    [PSCustomObject]@{Name="vm-db-01";Env="Prod";State="Running";Cores=4;CostPerHour=0.25}
    [PSCustomObject]@{Name="vm-stg-01";Env="Staging";State="Running";Cores=1;CostPerHour=0.05}
    [PSCustomObject]@{Name="vm-dev-01";Env="Dev";State="Running";Cores=2;CostPerHour=0.10}
    [PSCustomObject]@{Name="vm-dev-02";Env="Dev";State="Deallocated";Cores=1;CostPerHour=0.05}
)

function Stop-VMsByTag {
    [CmdletBinding(SupportsShouldProcess)]
    param([string]$Environment)

    $targets = $vms | Where-Object { $_.Env -eq $Environment -and $_.State -eq "Running" }
    $savings = ($targets | Measure-Object CostPerHour -Sum).Sum * 730  # hours/month

    Write-Host "Deallocating $($targets.Count) $Environment VMs" -ForegroundColor Yellow
    Write-Host "Estimated monthly savings: `$$([math]::Round($savings, 2))" -ForegroundColor Green

    foreach ($vm in $targets) {
        if ($PSCmdlet.ShouldProcess($vm.Name, "Deallocate")) {
            Write-Output "  Deallocated: $($vm.Name)"
        }
    }
}

Stop-VMsByTag -Environment "Dev" -WhatIf

# --- Exercise 3: Storage Auditor ---
Write-Host "`n=== Exercise 3: Storage Auditor ===" -ForegroundColor Cyan

$containers = @(
    [PSCustomObject]@{Account="stprod001";Name="scripts";Access="Private";SizeMB=5;OldBlobs=0}
    [PSCustomObject]@{Account="stprod001";Name="backups";Access="Private";SizeMB=10240;OldBlobs=15}
    [PSCustomObject]@{Account="stprod001";Name="public-assets";Access="Blob";SizeMB=200;OldBlobs=50}
    [PSCustomObject]@{Account="ststaging";Name="temp";Access="Private";SizeMB=800;OldBlobs=100}
)

Write-Host "Security: Public containers:" -ForegroundColor Red
$containers | Where-Object Access -ne "Private" | ForEach-Object {
    Write-Output "  $($_.Account)/$($_.Name) - Access: $($_.Access) - REVIEW IMMEDIATELY"
}

Write-Host "`nCleanup opportunities:" -ForegroundColor Yellow
$containers | Where-Object OldBlobs -gt 0 | ForEach-Object {
    Write-Output "  $($_.Account)/$($_.Name): $($_.OldBlobs) old blobs ($($_.SizeMB) MB total)"
}

# --- Exercise 4: Network Security ---
Write-Host "`n=== Exercise 4: Network Security ===" -ForegroundColor Cyan

$nsgRules = @(
    [PSCustomObject]@{NSG="nsg-web";Rule="AllowHTTP";Src="*";Dest="80";Access="Allow";Risk="Low"}
    [PSCustomObject]@{NSG="nsg-web";Rule="AllowSSH";Src="0.0.0.0/0";Dest="22";Access="Allow";Risk="HIGH"}
    [PSCustomObject]@{NSG="nsg-db";Rule="AllowSQL";Src="10.0.1.0/24";Dest="1433";Access="Allow";Risk="Low"}
    [PSCustomObject]@{NSG="nsg-db";Rule="AllowRDP";Src="0.0.0.0/0";Dest="3389";Access="Allow";Risk="HIGH"}
)

$highRisk = $nsgRules | Where-Object Risk -eq "HIGH"
if ($highRisk) {
    Write-Host "HIGH RISK rules found:" -ForegroundColor Red
    $highRisk | ForEach-Object {
        Write-Host "  $($_.NSG) / $($_.Rule): Port $($_.Dest) open from $($_.Src)" -ForegroundColor Red
    }
}

# --- Exercise 5: Dashboard ---
Write-Host "`n=== Exercise 5: Resource Dashboard ===" -ForegroundColor Cyan
Write-Output "Resource Groups: $($script:resourceGroups.Count)"
Write-Output "Virtual Machines: $($vms.Count) ($($($vms | Where-Object State -eq 'Running').Count) running)"
Write-Output "Storage Containers: $($containers.Count)"
Write-Output "NSG Rules: $($nsgRules.Count) ($($highRisk.Count) high-risk)"

$totalMonthlyCost = ($vms | Where-Object State -eq "Running" | ForEach-Object { $_.CostPerHour * 730 } | Measure-Object -Sum).Sum
Write-Output "Estimated Monthly Cost: `$$([math]::Round($totalMonthlyCost, 2))"
