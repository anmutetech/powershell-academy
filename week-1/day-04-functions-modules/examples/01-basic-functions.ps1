# =============================================================================
# Day 4 — Basic Functions
# =============================================================================

# --- Simple function ---
function Get-Greeting {
    Write-Output "Hello, World!"
}
Get-Greeting

# --- Function with parameter ---
function Get-Greeting {
    param(
        [string]$Name = "World"
    )
    Write-Output "Hello, $Name!"
}

Get-Greeting                # Hello, World!
Get-Greeting -Name "Alice"  # Hello, Alice!

# --- Multiple parameters with defaults ---
function Get-ServerSummary {
    param(
        [string]$ServerName = $env:COMPUTERNAME,
        [int]$TopCount = 5
    )

    Write-Host "`n=== $ServerName Summary ===" -ForegroundColor Cyan
    Write-Output "Top $TopCount processes by CPU:"
    Get-Process | Sort-Object CPU -Descending |
        Select-Object -First $TopCount Name, CPU, @{N="MemMB";E={[math]::Round($_.WorkingSet64/1MB)}}
}

Get-ServerSummary
Get-ServerSummary -TopCount 3

# --- Return values ---
function Get-DiskPercent {
    param([string]$Drive = "C")
    $disk = Get-PSDrive -Name $Drive -ErrorAction SilentlyContinue
    if ($null -eq $disk) { return -1 }
    $total = $disk.Used + $disk.Free
    if ($total -eq 0) { return 0 }
    [math]::Round(($disk.Used / $total) * 100, 1)
}

$usage = Get-DiskPercent
Write-Output "`nDisk C usage: $usage%"

# --- PSCustomObject output ---
function Get-SystemInfo {
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OS           = $PSVersionTable.OS
        PSVersion    = $PSVersionTable.PSVersion.ToString()
        Uptime       = (Get-Uptime -ErrorAction SilentlyContinue)
    }
}

Get-SystemInfo | Format-List
