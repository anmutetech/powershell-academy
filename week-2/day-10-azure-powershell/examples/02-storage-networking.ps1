# =============================================================================
# Day 10 — Azure Storage and Networking (Simulation Mode)
# =============================================================================

Write-Host "=== Azure Storage & Networking (Simulated) ===" -ForegroundColor Cyan

# --- Simulated Storage ---
$storageAccounts = @(
    [PSCustomObject]@{Name="stprodweb001";RG="rg-production-web";Location="eastus";Kind="StorageV2";Sku="Standard_LRS";Containers=@("scripts","backups","logs")}
    [PSCustomObject]@{Name="stproddb001";RG="rg-production-db";Location="eastus";Kind="StorageV2";Sku="Standard_GRS";Containers=@("db-backups","snapshots")}
    [PSCustomObject]@{Name="ststaging001";RG="rg-staging";Location="westus2";Kind="StorageV2";Sku="Standard_LRS";Containers=@("artifacts")}
)

$blobs = @(
    [PSCustomObject]@{Container="scripts";Name="backup.ps1";SizeKB=12;LastModified=(Get-Date).AddDays(-3)}
    [PSCustomObject]@{Container="scripts";Name="deploy.ps1";SizeKB=8;LastModified=(Get-Date).AddDays(-1)}
    [PSCustomObject]@{Container="backups";Name="db-2026-03-28.bak";SizeKB=524288;LastModified=(Get-Date).AddDays(-1)}
    [PSCustomObject]@{Container="backups";Name="db-2026-03-27.bak";SizeKB=523776;LastModified=(Get-Date).AddDays(-2)}
    [PSCustomObject]@{Container="logs";Name="app-2026-03.log";SizeKB=2048;LastModified=(Get-Date)}
)

# Storage Accounts
Write-Host "`n=== Storage Accounts ===" -ForegroundColor Yellow
$storageAccounts | ForEach-Object {
    Write-Output "  $($_.Name) ($($_.Sku)) - $($_.Location)"
    Write-Output "    Containers: $($_.Containers -join ', ')"
}

# Blob listing
Write-Host "`n=== Blobs in stprodweb001 ===" -ForegroundColor Yellow
$blobs | ForEach-Object {
    $sizeMB = if ($_.SizeKB -gt 1024) { "{0:N1} MB" -f ($_.SizeKB / 1024) } else { "$($_.SizeKB) KB" }
    Write-Output ("  {0}/{1,-30} {2,10}  {3:yyyy-MM-dd}" -f $_.Container, $_.Name, $sizeMB, $_.LastModified)
}

# --- Simulated Networking ---
Write-Host "`n=== Virtual Networks ===" -ForegroundColor Yellow

$vnets = @(
    [PSCustomObject]@{Name="vnet-production";RG="rg-production-web";AddressSpace="10.0.0.0/16";Subnets=@(
        @{Name="snet-web";Prefix="10.0.1.0/24";NSG="nsg-web"}
        @{Name="snet-db";Prefix="10.0.2.0/24";NSG="nsg-db"}
        @{Name="snet-app";Prefix="10.0.3.0/24";NSG="nsg-app"}
    )}
    [PSCustomObject]@{Name="vnet-staging";RG="rg-staging";AddressSpace="10.1.0.0/16";Subnets=@(
        @{Name="snet-default";Prefix="10.1.1.0/24";NSG="nsg-staging"}
    )}
)

foreach ($vnet in $vnets) {
    Write-Host "`n  $($vnet.Name) ($($vnet.AddressSpace))" -ForegroundColor Cyan
    foreach ($subnet in $vnet.Subnets) {
        Write-Output "    Subnet: $($subnet.Name) ($($subnet.Prefix)) NSG: $($subnet.NSG)"
    }
}

# NSG Rules
Write-Host "`n=== NSG Rules: nsg-web ===" -ForegroundColor Yellow
$nsgRules = @(
    [PSCustomObject]@{Name="AllowHTTP";Priority=100;Direction="Inbound";Access="Allow";Protocol="TCP";DestPort="80"}
    [PSCustomObject]@{Name="AllowHTTPS";Priority=110;Direction="Inbound";Access="Allow";Protocol="TCP";DestPort="443"}
    [PSCustomObject]@{Name="AllowSSH";Priority=200;Direction="Inbound";Access="Allow";Protocol="TCP";DestPort="22"}
    [PSCustomObject]@{Name="DenyAll";Priority=4096;Direction="Inbound";Access="Deny";Protocol="*";DestPort="*"}
)
$nsgRules | Format-Table Name, Priority, Direction, Access, Protocol, DestPort -AutoSize

# --- Simulating Blob Upload ---
Write-Host "=== Simulated Blob Upload ===" -ForegroundColor Yellow
function Set-SimStorageBlob {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$File,
        [string]$Container,
        [string]$StorageAccount
    )

    if ($PSCmdlet.ShouldProcess("$Container/$File", "Upload to $StorageAccount")) {
        Write-Output "Uploaded '$File' to '$StorageAccount/$Container'"
    }
}

Set-SimStorageBlob -File "deploy.ps1" -Container "scripts" -StorageAccount "stprodweb001"
