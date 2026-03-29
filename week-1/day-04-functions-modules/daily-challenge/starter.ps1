# =============================================================================
# Day 4 Daily Challenge — Server Health Check Toolkit (Starter)
# =============================================================================

# TODO: Create Get-SystemHealth function
# - Use [CmdletBinding()]
# - Get CPU, Memory, and Disk usage percentages
# - Return a [PSCustomObject]
# - Determine status based on thresholds

function Get-SystemHealth {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )

    # TODO: Get CPU usage
    # Hint: Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average

    # TODO: Get Memory usage
    # Hint: $os = Get-CimInstance Win32_OperatingSystem
    #       $memPercent = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)

    # TODO: Get Disk usage
    # Hint: Use Get-PSDrive -Name C

    # TODO: Determine status (Healthy, Warning, Critical)

    # TODO: Return [PSCustomObject]
}

# TODO: Create Test-PortConnection function
# - Use [CmdletBinding()]
# - Validate port range
# - Test connection
# - Return [PSCustomObject]

function Test-PortConnection {
    [CmdletBinding()]
    param(
        [string]$ComputerName = "localhost",
        [Parameter(Mandatory)]
        [ValidateRange(1, 65535)]
        [int]$Port
    )

    # TODO: Test the port connection
    # TODO: Return [PSCustomObject] with ComputerName, Port, IsOpen
}

# TODO: Create Get-HealthReport function that ties it all together

# --- Test your functions ---
# Get-SystemHealth
# Test-PortConnection -Port 80
# Get-HealthReport
