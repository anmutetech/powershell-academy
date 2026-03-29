# =============================================================================
# Day 13 Daily Challenge — Build a Tested Module (Starter)
# =============================================================================

# This starter creates the module directory structure.
# Your job: fill in the function implementations and tests.

$moduleName = "ServerTools"
$moduleBase = Join-Path $PSScriptRoot $moduleName

# Create structure
@("Public", "Private", "Tests", ".github\workflows") | ForEach-Object {
    New-Item -Path (Join-Path $moduleBase $_) -ItemType Directory -Force | Out-Null
}

# TODO: Create Public/Get-ServerHealth.ps1
# - [CmdletBinding()] with ComputerName parameter
# - Return PSCustomObject with Computer, CPUPercent, MemoryPercent, DiskPercent, Status

# TODO: Create Public/Test-PortConnection.ps1
# - [CmdletBinding()] with ComputerName and Port parameters
# - Return PSCustomObject with ComputerName, Port, IsOpen

# TODO: Create Public/Get-DiskReport.ps1
# - [CmdletBinding()] with optional DriveFilter parameter
# - Return PSCustomObject array with Drive, TotalGB, FreeGB, UsedPercent, Status

# TODO: Create Private/Get-HealthStatus.ps1
# - Helper function that takes percentages and returns Healthy/Warning/Critical

# TODO: Create ServerTools.psm1 (module loader)

# TODO: Create ServerTools.psd1 (module manifest)

# TODO: Create Tests/*.Tests.ps1 (Pester tests)

# TODO: Create .github/workflows/ci.yml

Write-Host "Module structure created at: $moduleBase" -ForegroundColor Cyan
Write-Host "Fill in the TODO items to complete the challenge."
