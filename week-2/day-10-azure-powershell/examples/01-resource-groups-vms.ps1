# =============================================================================
# Day 10 — Azure Resource Groups and VMs (Simulation Mode)
# =============================================================================
# These examples simulate Azure operations for learning without an Azure subscription.
# On a real Azure subscription, replace simulated data with actual Az cmdlets.

Write-Host "=== Azure Resource Management (Simulated) ===" -ForegroundColor Cyan

# --- Simulated Azure Data ---
$resourceGroups = @(
    [PSCustomObject]@{Name="rg-production-web";Location="eastus";Tags=@{Env="Prod";Team="Web"}}
    [PSCustomObject]@{Name="rg-production-db";Location="eastus";Tags=@{Env="Prod";Team="DB"}}
    [PSCustomObject]@{Name="rg-staging";Location="westus2";Tags=@{Env="Staging"}}
    [PSCustomObject]@{Name="rg-dev";Location="eastus";Tags=@{Env="Dev"}}
    [PSCustomObject]@{Name="rg-monitoring";Location="eastus";Tags=@{Env="Prod";Team="DevOps"}}
)

$virtualMachines = @(
    [PSCustomObject]@{Name="vm-web-01";RG="rg-production-web";Location="eastus";Size="Standard_B2s";OS="Windows 2022";State="Running";CPU_Cores=2;RAM_GB=4}
    [PSCustomObject]@{Name="vm-web-02";RG="rg-production-web";Location="eastus";Size="Standard_B2s";OS="Windows 2022";State="Running";CPU_Cores=2;RAM_GB=4}
    [PSCustomObject]@{Name="vm-db-01";RG="rg-production-db";Location="eastus";Size="Standard_D4s_v3";OS="Windows 2022";State="Running";CPU_Cores=4;RAM_GB=16}
    [PSCustomObject]@{Name="vm-staging-01";RG="rg-staging";Location="westus2";Size="Standard_B1s";OS="Ubuntu 22.04";State="Deallocated";CPU_Cores=1;RAM_GB=1}
    [PSCustomObject]@{Name="vm-dev-01";RG="rg-dev";Location="eastus";Size="Standard_B1ms";OS="Ubuntu 22.04";State="Running";CPU_Cores=1;RAM_GB=2}
)

# --- List Resource Groups ---
Write-Host "`n=== Resource Groups ===" -ForegroundColor Yellow
$resourceGroups | Format-Table Name, Location, @{N="Tags";E={($_.Tags.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ", "}}

# --- List VMs ---
Write-Host "=== Virtual Machines ===" -ForegroundColor Yellow
$virtualMachines | ForEach-Object {
    $color = if ($_.State -eq "Running") { "Green" } else { "Yellow" }
    Write-Host ("{0,-18} {1,-22} {2,-15} {3,-10} {4}" -f $_.Name, $_.RG, $_.Size, $_.State, $_.OS) -ForegroundColor $color
}

# --- VMs by Resource Group ---
Write-Host "`n=== VMs by Resource Group ===" -ForegroundColor Yellow
$virtualMachines | Group-Object RG | ForEach-Object {
    Write-Host "  $($_.Name): $($_.Count) VM(s)" -ForegroundColor Cyan
    $_.Group | ForEach-Object { Write-Output "    - $($_.Name) ($($_.State))" }
}

# --- Cost Estimation ---
Write-Host "`n=== Estimated Monthly Cost ===" -ForegroundColor Yellow
$costPerCore = 30  # Simplified: $30/core/month
$virtualMachines | Where-Object State -eq "Running" | ForEach-Object {
    $monthlyCost = $_.CPU_Cores * $costPerCore
    Write-Output ("  {0,-18} {1} cores x `${2} = `${3}/month" -f $_.Name, $_.CPU_Cores, $costPerCore, $monthlyCost)
}
$totalCost = ($virtualMachines | Where-Object State -eq "Running" | ForEach-Object { $_.CPU_Cores * $costPerCore } | Measure-Object -Sum).Sum
Write-Host "  Total estimated: `$$totalCost/month" -ForegroundColor Green

# --- Deallocated VMs (savings opportunity) ---
Write-Host "`n=== Deallocated VMs ===" -ForegroundColor Yellow
$deallocated = $virtualMachines | Where-Object State -eq "Deallocated"
if ($deallocated) {
    $deallocated | ForEach-Object { Write-Output "  $($_.Name) in $($_.RG) - consider removing if unused" }
} else {
    Write-Output "  No deallocated VMs"
}

Write-Host @"

NOTE: In a real Azure environment, use:
  Connect-AzAccount
  Get-AzResourceGroup
  Get-AzVM -Status
"@ -ForegroundColor Gray
