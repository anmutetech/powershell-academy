# Day 10 — Exercises

## Exercise 1: Resource Group Manager
Write functions to:
- Create a resource group with mandatory tags (Env, Owner, CostCenter)
- List all resource groups with their tag info
- Find resource groups missing required tags
- Delete empty resource groups (simulated with `-WhatIf`)

## Exercise 2: VM Fleet Manager
Write a script that:
- Manages a fleet of simulated VMs
- Can start/stop/deallocate VMs by tag (e.g., all "Dev" VMs)
- Calculates cost savings from deallocating stopped VMs
- Generates a VM inventory report (CSV)

## Exercise 3: Storage Account Auditor
Write a function that:
- Lists all storage accounts and their containers
- Identifies old blobs (not modified in 30+ days)
- Calculates storage used per container
- Reports containers with public access (security risk)
- Recommends lifecycle policies

## Exercise 4: Network Security Auditor
Write a script that:
- Lists all NSGs and their rules
- Identifies overly permissive rules (e.g., allow all from any)
- Checks for common security issues (SSH/RDP open to 0.0.0.0/0)
- Generates a security compliance report

## Exercise 5: Azure Resource Dashboard
Build a comprehensive dashboard that:
- Shows resource counts by type
- Displays cost by resource group
- Highlights untagged resources
- Shows VM power states
- Lists storage consumption
- Exports everything to JSON
