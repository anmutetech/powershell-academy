# Day 11 — Exercises

## Exercise 1: Automation Runbook
Write a simulated Azure Automation runbook that:
- Finds all VMs with a "ShutdownTime" tag
- Compares current time to the tag value
- Stops VMs that should be shut down
- Starts VMs that should be running
- Logs all actions with timestamps

## Exercise 2: ARM Template Generator
Write a PowerShell function that generates ARM templates:
- Accept resource type, name, and location as parameters
- Support: Storage Account, App Service, Virtual Network
- Generate valid ARM JSON template
- Save to file
- Validate the template structure

## Exercise 3: Pipeline Simulator
Build a pipeline execution engine that:
- Reads pipeline stages from a JSON config
- Executes each stage in order
- Supports parallel stages
- Tracks timing per stage
- Generates a pipeline report
- Supports retry on failure

## Exercise 4: REST API Client
Write functions that interact with a REST API:
- `Get-ApiData` — GET requests with error handling
- `Send-ApiData` — POST/PUT with JSON body
- `Invoke-ApiWithRetry` — retry logic for transient failures
- Support authentication headers
- Log all API calls

## Exercise 5: Deployment Orchestrator
Combine runbooks, templates, and pipelines:
- Read a deployment manifest (JSON file listing what to deploy)
- Deploy resources in dependency order
- Run health checks after each deployment
- Rollback on failure
- Generate a deployment report
