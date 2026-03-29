# =============================================================================
# Day 11 — Azure Automation Runbooks (Simulation Mode)
# =============================================================================

Write-Host "=== Azure Automation Runbooks (Simulated) ===" -ForegroundColor Cyan

# --- Simulated Runbook: Stop Dev VMs ---
Write-Host "`n--- Runbook: Stop-DevVMs ---" -ForegroundColor Yellow

function Invoke-StopDevVMs {
    [CmdletBinding()]
    param(
        [string]$Environment = "Dev",
        [switch]$DryRun
    )

    Write-Output "Runbook: Stop-DevVMs"
    Write-Output "Environment: $Environment"
    Write-Output "Execution Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Output ""

    # Simulated VMs
    $vms = @(
        [PSCustomObject]@{Name="vm-dev-01";RG="rg-dev";State="Running";Tags=@{Environment="Dev"}}
        [PSCustomObject]@{Name="vm-dev-02";RG="rg-dev";State="Running";Tags=@{Environment="Dev"}}
        [PSCustomObject]@{Name="vm-dev-03";RG="rg-dev";State="Deallocated";Tags=@{Environment="Dev"}}
        [PSCustomObject]@{Name="vm-staging-01";RG="rg-staging";State="Running";Tags=@{Environment="Staging"}}
    )

    $targets = $vms | Where-Object { $_.Tags.Environment -eq $Environment -and $_.State -eq "Running" }

    foreach ($vm in $targets) {
        if ($DryRun) {
            Write-Output "[DRY RUN] Would stop: $($vm.Name) in $($vm.RG)"
        } else {
            Write-Output "Stopping: $($vm.Name) in $($vm.RG)..."
            Start-Sleep -Milliseconds 500  # Simulate API call
            Write-Output "  -> Deallocated"
        }
    }

    Write-Output ""
    Write-Output "Summary: $($targets.Count) VMs targeted for $Environment environment"
}

Invoke-StopDevVMs -Environment "Dev" -DryRun

# --- Simulated Runbook: Start Prod VMs ---
Write-Host "`n--- Runbook: Start-ProdVMs ---" -ForegroundColor Yellow

function Invoke-StartProdVMs {
    [CmdletBinding()]
    param([string]$Environment = "Prod")

    $vms = @(
        [PSCustomObject]@{Name="vm-web-01";State="Deallocated";Priority=1}
        [PSCustomObject]@{Name="vm-web-02";State="Deallocated";Priority=1}
        [PSCustomObject]@{Name="vm-app-01";State="Deallocated";Priority=2}
        [PSCustomObject]@{Name="vm-db-01";State="Running";Priority=0}
    )

    $toStart = $vms | Where-Object State -eq "Deallocated" | Sort-Object Priority

    foreach ($vm in $toStart) {
        Write-Output "Starting: $($vm.Name) (Priority: $($vm.Priority))"
    }

    Write-Output "Started $($toStart.Count) VMs in priority order"
}

Invoke-StartProdVMs

# --- Schedule Simulation ---
Write-Host "`n--- Automation Schedules ---" -ForegroundColor Yellow
$schedules = @(
    [PSCustomObject]@{Name="Stop-Dev-7PM";Runbook="Stop-DevVMs";Frequency="Weekdays 19:00";Enabled=$true}
    [PSCustomObject]@{Name="Start-Prod-6AM";Runbook="Start-ProdVMs";Frequency="Weekdays 06:00";Enabled=$true}
    [PSCustomObject]@{Name="Weekly-Compliance";Runbook="Check-Compliance";Frequency="Sunday 02:00";Enabled=$true}
    [PSCustomObject]@{Name="Monthly-Cleanup";Runbook="Remove-OldSnapshots";Frequency="1st of month 03:00";Enabled=$false}
)

$schedules | Format-Table Name, Runbook, Frequency, Enabled -AutoSize
