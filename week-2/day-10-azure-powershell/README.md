# Day 10 — Azure PowerShell

Cloud is where the jobs are. Azure PowerShell lets you manage Azure resources programmatically — create VMs, manage storage, configure networking, and automate deployments. Today covers the essential Azure cmdlets every Cloud Engineer needs.

---

## Video Resources

- [Azure PowerShell Getting Started](https://www.youtube.com/watch?v=ataIPhKfzTo)
- [Manage Azure Resources with PowerShell](https://www.youtube.com/watch?v=dL-G1K6PRMQ)
- [Azure PowerShell Tutorial](https://www.youtube.com/watch?v=ZcbBuVVa5MY)

---

## Prerequisites

```powershell
# Install Azure PowerShell module
Install-Module -Name Az -Scope CurrentUser -Force

# Or update if already installed
Update-Module -Name Az

# Verify installation
Get-Module -Name Az -ListAvailable | Select-Object Name, Version

# Login to Azure
Connect-AzAccount

# If you have multiple subscriptions
Get-AzSubscription
Set-AzContext -SubscriptionId "your-subscription-id"
```

## 1. Resource Groups

Resource groups are containers for Azure resources.

```powershell
# List resource groups
Get-AzResourceGroup | Format-Table ResourceGroupName, Location

# Create a resource group
New-AzResourceGroup -Name "rg-powershell-lab" -Location "eastus" -Tag @{
    Environment = "Lab"
    Owner       = "PowerShell Academy"
}

# Get resources in a group
Get-AzResource -ResourceGroupName "rg-powershell-lab" | Format-Table Name, ResourceType

# Delete resource group (deletes everything in it!)
Remove-AzResourceGroup -Name "rg-powershell-lab" -Force
```

## 2. Virtual Machines

```powershell
# List VMs
Get-AzVM | Format-Table Name, ResourceGroupName, Location

# Get VM details
Get-AzVM -Name "myVM" -ResourceGroupName "myRG" -Status |
    Select-Object Name, PowerState, OsType

# Create a VM (simplified)
$vmParams = @{
    ResourceGroupName = "rg-powershell-lab"
    Name              = "vm-web-01"
    Location          = "eastus"
    Image             = "Win2022AzureEditionCore"
    Size              = "Standard_B2s"
    Credential        = (Get-Credential)
}
New-AzVM @vmParams

# Start, Stop, Restart
Start-AzVM -Name "vm-web-01" -ResourceGroupName "rg-powershell-lab"
Stop-AzVM -Name "vm-web-01" -ResourceGroupName "rg-powershell-lab" -Force
Restart-AzVM -Name "vm-web-01" -ResourceGroupName "rg-powershell-lab"

# Deallocate (stop billing)
Stop-AzVM -Name "vm-web-01" -ResourceGroupName "rg-powershell-lab" -Force

# Get all VM sizes in a region
Get-AzVMSize -Location "eastus" | Where-Object NumberOfCores -le 4 |
    Sort-Object MemoryInMB | Select-Object -First 10
```

## 3. Storage Accounts

```powershell
# List storage accounts
Get-AzStorageAccount | Format-Table StorageAccountName, ResourceGroupName, Location

# Create storage account
$storageParams = @{
    ResourceGroupName = "rg-powershell-lab"
    Name              = "stpowershelllab001"  # Must be globally unique
    Location          = "eastus"
    SkuName           = "Standard_LRS"
    Kind              = "StorageV2"
}
New-AzStorageAccount @storageParams

# Get storage account context (needed for blob operations)
$context = (Get-AzStorageAccount -ResourceGroupName "rg-powershell-lab" -Name "stpowershelllab001").Context

# Create container
New-AzStorageContainer -Name "scripts" -Context $context -Permission Off

# Upload blob
Set-AzStorageBlobContent -File ".\backup.ps1" -Container "scripts" -Blob "backup.ps1" -Context $context

# List blobs
Get-AzStorageBlob -Container "scripts" -Context $context

# Download blob
Get-AzStorageBlobContent -Container "scripts" -Blob "backup.ps1" -Destination ".\downloaded.ps1" -Context $context
```

## 4. Networking

```powershell
# List virtual networks
Get-AzVirtualNetwork | Format-Table Name, ResourceGroupName, Location

# Create VNet and Subnet
$subnet = New-AzVirtualNetworkSubnetConfig -Name "snet-web" -AddressPrefix "10.0.1.0/24"
$vnet = New-AzVirtualNetwork -Name "vnet-lab" -ResourceGroupName "rg-powershell-lab" `
    -Location "eastus" -AddressPrefix "10.0.0.0/16" -Subnet $subnet

# Network Security Group
$rule1 = New-AzNetworkSecurityRuleConfig -Name "AllowHTTP" -Protocol Tcp `
    -Direction Inbound -Priority 100 -SourceAddressPrefix "*" `
    -SourcePortRange "*" -DestinationAddressPrefix "*" `
    -DestinationPortRange 80 -Access Allow

$nsg = New-AzNetworkSecurityGroup -Name "nsg-web" -ResourceGroupName "rg-powershell-lab" `
    -Location "eastus" -SecurityRules $rule1

# List NSG rules
Get-AzNetworkSecurityGroup -Name "nsg-web" -ResourceGroupName "rg-powershell-lab" |
    Get-AzNetworkSecurityRuleConfig | Format-Table Name, Direction, Access, DestinationPortRange
```

## 5. Azure App Service

```powershell
# List web apps
Get-AzWebApp | Format-Table Name, ResourceGroup, DefaultHostName, State

# Create App Service Plan
New-AzAppServicePlan -Name "plan-lab" -ResourceGroupName "rg-powershell-lab" `
    -Location "eastus" -Tier "Free"

# Create Web App
New-AzWebApp -Name "webapp-ps-lab-001" -ResourceGroupName "rg-powershell-lab" `
    -AppServicePlan "plan-lab" -Location "eastus"

# Get app settings
Get-AzWebApp -Name "webapp-ps-lab-001" -ResourceGroupName "rg-powershell-lab" |
    Select-Object -ExpandProperty SiteConfig | Select-Object -ExpandProperty AppSettings

# Set app settings
$settings = @{ "ENVIRONMENT" = "production"; "LOG_LEVEL" = "info" }
Set-AzWebApp -Name "webapp-ps-lab-001" -ResourceGroupName "rg-powershell-lab" -AppSettings $settings

# Restart
Restart-AzWebApp -Name "webapp-ps-lab-001" -ResourceGroupName "rg-powershell-lab"
```

## 6. Tags and Resource Management

```powershell
# Add tags to resource
$tags = @{ Environment = "Production"; CostCenter = "IT-001"; Owner = "DevOps" }
Set-AzResource -ResourceGroupName "rg-powershell-lab" -Name "vm-web-01" `
    -ResourceType "Microsoft.Compute/virtualMachines" -Tag $tags -Force

# Find resources by tag
Get-AzResource -TagName "Environment" -TagValue "Production" |
    Format-Table Name, ResourceType, ResourceGroupName

# Find untagged resources (compliance)
Get-AzResource | Where-Object { $null -eq $_.Tags -or $_.Tags.Count -eq 0 } |
    Format-Table Name, ResourceType
```

## 7. Cost Management

```powershell
# Get resource usage
Get-AzConsumptionUsageDetail -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date) |
    Group-Object InstanceName |
    Select-Object Name, @{N="TotalCost";E={($_.Group | Measure-Object PretaxCost -Sum).Sum}} |
    Sort-Object TotalCost -Descending |
    Select-Object -First 10
```

---

## Key Takeaways

1. Always start with `Connect-AzAccount` and set the right subscription
2. Use `New-Az*` to create, `Get-Az*` to read, `Set-Az*` to update, `Remove-Az*` to delete
3. Splatting (`@params`) keeps Azure commands clean and readable
4. Tags are essential for cost management and compliance — automate tag enforcement
5. Always clean up lab resources to avoid unexpected charges
6. Use `-WhatIf` before destructive operations (`Remove-Az*`)

---

## Interview Prep

**Q: How do you manage Azure resources with PowerShell?**
A: Install the Az module, authenticate with `Connect-AzAccount`, then use the Az cmdlets which follow the pattern `Verb-AzResourceType`. For example, `New-AzVM` to create VMs, `Get-AzStorageAccount` to list storage, `Set-AzWebApp` to configure web apps. Use splatting for complex parameter sets and `-WhatIf` for safety.

**Q: How do you automate Azure VM provisioning?**
A: Use `New-AzVM` with splatted parameters for the configuration (size, image, credentials, networking). For production, create the NIC, NSG, and public IP separately for full control. Wrap it in a function with error handling, and use tags for tracking. For scale, use ARM templates or Bicep deployed via `New-AzResourceGroupDeployment`.

**Q: How do you ensure Azure resources are tagged for compliance?**
A: Use `Get-AzResource` to find untagged resources, `Set-AzResource -Tag` to apply tags. For enforcement, use Azure Policy to require tags at creation time. Automate regular compliance scans with a PowerShell script that reports untagged resources and optionally applies default tags.
