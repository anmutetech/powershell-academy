# =============================================================================
# Day 7 Capstone — Server Inventory & Health Dashboard (Starter)
# =============================================================================

# --- Configuration ---
$reportDir = Join-Path $PSScriptRoot "reports"
$timestamp = Get-Date -Format "yyyy-MM-dd"
$servicesToCheck = @("Spooler", "W32Time", "wuauserv", "WinRM")

# Create report directory
if (-not (Test-Path $reportDir)) {
    New-Item -Path $reportDir -ItemType Directory | Out-Null
}

# --- Logging Function ---
# TODO: Create Write-Log function (reuse from Day 6)

# --- Data Collection Functions ---

# TODO: Create Get-SystemInfo function
# Returns: ComputerName, OS, PSVersion, Uptime
function Get-SystemInfo {
    [CmdletBinding()]
    param()

    # TODO: Implement
}

# TODO: Create Get-DiskHealth function
# Returns: Drive, TotalGB, UsedGB, FreeGB, UsagePercent, Status
function Get-DiskHealth {
    [CmdletBinding()]
    param(
        [int]$WarningThreshold = 75,
        [int]$CriticalThreshold = 90
    )

    # TODO: Implement using Get-PSDrive or Get-CimInstance
}

# TODO: Create Get-MemoryHealth function
# Returns: TotalGB, UsedGB, FreeGB, UsagePercent, Status
function Get-MemoryHealth {
    [CmdletBinding()]
    param()

    # TODO: Implement using Get-CimInstance Win32_OperatingSystem
}

# TODO: Create Get-TopProcesses function
# Returns: array of PSCustomObjects with Name, CPU, MemoryMB
function Get-TopProcesses {
    [CmdletBinding()]
    param([int]$Count = 5)

    # TODO: Implement using Get-Process
}

# TODO: Create Get-ServiceStatus function
# Returns: array of PSCustomObjects with Name, Status, StartType
function Get-ServiceStatus {
    [CmdletBinding()]
    param([string[]]$ServiceName)

    # TODO: Implement using Get-Service with error handling
}

# --- Health Check Function ---
# TODO: Create Get-OverallStatus that analyzes all health data
# Returns: Status (Healthy/Warning/Critical), Issues array

# --- Dashboard Display ---
# TODO: Create Show-Dashboard function that displays formatted, color-coded output

# --- Export Functions ---
# TODO: Create Export-InventoryReport that saves CSV, JSON, and text reports

# === Main Execution ===
Write-Host "Starting inventory collection..." -ForegroundColor Cyan

# TODO: Call each data collection function
# TODO: Display the dashboard
# TODO: Export reports
# TODO: Show summary

Write-Host "Inventory complete." -ForegroundColor Cyan
