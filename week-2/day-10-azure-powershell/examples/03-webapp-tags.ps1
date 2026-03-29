# =============================================================================
# Day 10 — Azure Web Apps and Tag Management (Simulation Mode)
# =============================================================================

Write-Host "=== Azure Web Apps & Tags (Simulated) ===" -ForegroundColor Cyan

# --- Simulated Web Apps ---
$webApps = @(
    [PSCustomObject]@{Name="app-meditrack-prod";RG="rg-production-web";Plan="plan-prod-p1v2";State="Running";URL="app-meditrack-prod.azurewebsites.net";Runtime=".NET 8";Tags=@{Env="Prod";Team="MediTrack"}}
    [PSCustomObject]@{Name="app-meditrack-staging";RG="rg-staging";Plan="plan-staging-b1";State="Running";URL="app-meditrack-staging.azurewebsites.net";Runtime=".NET 8";Tags=@{Env="Staging"}}
    [PSCustomObject]@{Name="app-api-prod";RG="rg-production-web";Plan="plan-prod-p1v2";State="Running";URL="app-api-prod.azurewebsites.net";Runtime="Node 20";Tags=@{Env="Prod";Team="API"}}
    [PSCustomObject]@{Name="app-legacy";RG="rg-production-web";Plan="plan-prod-b1";State="Stopped";URL="app-legacy.azurewebsites.net";Runtime=".NET Framework 4.8";Tags=@{}}
)

# List web apps
Write-Host "`n=== Web Apps ===" -ForegroundColor Yellow
$webApps | ForEach-Object {
    $color = if ($_.State -eq "Running") { "Green" } else { "Red" }
    Write-Host ("  {0,-30} {1,-10} {2,-10} {3}" -f $_.Name, $_.State, $_.Runtime, $_.URL) -ForegroundColor $color
}

# App Settings simulation
Write-Host "`n=== App Settings: app-meditrack-prod ===" -ForegroundColor Yellow
$appSettings = @{
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "ConnectionStrings__Default" = "Server=vm-db-01;Database=meditrack;..."
    "Logging__LogLevel" = "Warning"
    "FeatureFlags__DarkMode" = "false"
}

$appSettings.GetEnumerator() | Sort-Object Name | ForEach-Object {
    $masked = if ($_.Key -match "Connection|Secret|Key|Password") {
        $_.Value.Substring(0, [math]::Min(20, $_.Value.Length)) + "..."
    } else { $_.Value }
    Write-Output ("  {0,-40} = {1}" -f $_.Key, $masked)
}

# === Tag Management ===
Write-Host "`n=== Tag Compliance Check ===" -ForegroundColor Cyan

$allResources = @(
    [PSCustomObject]@{Name="vm-web-01";Type="VirtualMachine";Tags=@{Env="Prod";Team="Web";CostCenter="IT-001"}}
    [PSCustomObject]@{Name="vm-web-02";Type="VirtualMachine";Tags=@{Env="Prod";Team="Web";CostCenter="IT-001"}}
    [PSCustomObject]@{Name="vm-db-01";Type="VirtualMachine";Tags=@{Env="Prod";Team="DB"}}
    [PSCustomObject]@{Name="stprodweb001";Type="StorageAccount";Tags=@{Env="Prod"}}
    [PSCustomObject]@{Name="app-legacy";Type="WebApp";Tags=@{}}
    [PSCustomObject]@{Name="vnet-production";Type="VirtualNetwork";Tags=@{Env="Prod";Team="Network"}}
    [PSCustomObject]@{Name="nsg-web";Type="NSG";Tags=@{}}
)

$requiredTags = @("Env", "Team", "CostCenter")

Write-Host "`nRequired tags: $($requiredTags -join ', ')" -ForegroundColor Yellow
Write-Host ""

foreach ($resource in $allResources) {
    $missing = $requiredTags | Where-Object { -not $resource.Tags.ContainsKey($_) }

    if ($missing) {
        Write-Host ("  {0,-25} {1,-20} MISSING: {2}" -f $resource.Name, $resource.Type, ($missing -join ", ")) -ForegroundColor Red
    } else {
        Write-Host ("  {0,-25} {1,-20} COMPLIANT" -f $resource.Name, $resource.Type) -ForegroundColor Green
    }
}

$compliant = ($allResources | Where-Object {
    $tags = $_.Tags
    ($requiredTags | Where-Object { -not $tags.ContainsKey($_) }).Count -eq 0
}).Count
$total = $allResources.Count
$pct = [math]::Round(($compliant / $total) * 100, 1)

Write-Host ("`nTag Compliance: {0}% ({1}/{2} resources)" -f $pct, $compliant, $total) -ForegroundColor $(if ($pct -ge 80) {"Green"} else {"Red"})

# === Cost by Tag ===
Write-Host "`n=== Cost by Environment Tag ===" -ForegroundColor Yellow
$costData = @(
    [PSCustomObject]@{Resource="vm-web-01";Env="Prod";MonthlyCost=120}
    [PSCustomObject]@{Resource="vm-web-02";Env="Prod";MonthlyCost=120}
    [PSCustomObject]@{Resource="vm-db-01";Env="Prod";MonthlyCost=240}
    [PSCustomObject]@{Resource="vm-staging-01";Env="Staging";MonthlyCost=15}
    [PSCustomObject]@{Resource="vm-dev-01";Env="Dev";MonthlyCost=30}
)

$costData | Group-Object Env | ForEach-Object {
    $envCost = ($_.Group | Measure-Object MonthlyCost -Sum).Sum
    Write-Output ("  {0,-15} `${1:N0}/month ({2} resources)" -f $_.Name, $envCost, $_.Count)
}
