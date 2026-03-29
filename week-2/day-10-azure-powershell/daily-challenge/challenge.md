# Day 10 — Daily Challenge: Azure Infrastructure Provisioner

## The Task

Build a simulated Azure infrastructure provisioning script that creates a complete environment (resource group, VNet, NSG, VM, storage) with proper tagging and generates a deployment report.

## Requirements

1. Accept environment parameters (environment name, location, VM size)
2. Create resources in order:
   - Resource Group with tags
   - Virtual Network with subnets
   - Network Security Group with rules
   - Storage Account
   - Virtual Machine
3. Validate all inputs before starting
4. Use splatting for Azure cmdlet parameters
5. Handle errors at each step (rollback on failure)
6. Generate a deployment report (console + JSON)
7. Calculate estimated monthly cost

## Example Output

```
===== Azure Infrastructure Provisioner =====

Environment: staging
Location:    westus2
VM Size:     Standard_B2s

[1/5] Creating Resource Group...     rg-staging-westus2     OK
[2/5] Creating Virtual Network...    vnet-staging           OK
[3/5] Creating NSG...                nsg-staging-web        OK
[4/5] Creating Storage Account...    ststaging001           OK
[5/5] Creating Virtual Machine...    vm-staging-web-01      OK

===== Deployment Summary =====
  All 5 resources created successfully
  Estimated monthly cost: $62.05
  Tags applied: Env=Staging, ManagedBy=PowerShell, CreatedDate=2026-03-29

  Report saved to: deployment-staging-2026-03-29.json
```

## Hints

- Use a hashtable for resource naming conventions
- Use `try/catch` with a `$deployedResources` array for rollback tracking
- Use splatting heavily for clean code
- Calculate cost from VM size lookup table
