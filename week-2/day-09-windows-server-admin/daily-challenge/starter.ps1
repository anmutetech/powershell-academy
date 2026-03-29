# =============================================================================
# Day 9 Daily Challenge — Server Monitoring Dashboard (Starter)
# =============================================================================

# Configuration
$refreshInterval = 30  # seconds
$servicesToMonitor = @("Spooler", "W32Time", "wuauserv", "WinRM")
$diskWarning = 80
$diskCritical = 90
$memWarning = 80

# TODO: Create a function to draw a progress bar
# function Get-ProgressBar { param([int]$Percent, [int]$Width = 10) ... }
# Example output: [####------] 42%

# TODO: Create function to get CPU usage
# function Get-CPUUsage { ... }

# TODO: Create function to get memory usage
# function Get-MemoryUsage { ... }

# TODO: Create function to get disk usage
# function Get-DiskUsage { ... }

# TODO: Create function to check services
# function Get-ServiceStatus { ... }

# TODO: Create function to get recent errors from event logs
# function Get-RecentErrors { ... }

# TODO: Create the main dashboard display function
# function Show-Dashboard { ... }

# TODO: Main loop
# - Clear screen
# - Collect metrics
# - Display dashboard
# - Sleep for refresh interval
# - Support Ctrl+C to exit
