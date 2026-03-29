# =============================================================================
# Day 13 Daily Challenge — Build a Tested Module (Solution)
# =============================================================================

$moduleName = "ServerTools"
$moduleBase = Join-Path $PSScriptRoot $moduleName

# Create structure
@("Public", "Private", "Tests") | ForEach-Object {
    New-Item -Path (Join-Path $moduleBase $_) -ItemType Directory -Force | Out-Null
}

# --- Private/Get-HealthStatus.ps1 ---
@'
function Get-HealthStatus {
    param([double]$Value, [int]$Warning = 80, [int]$Critical = 90)
    if ($Value -ge $Critical) { "Critical" }
    elseif ($Value -ge $Warning) { "Warning" }
    else { "Healthy" }
}
'@ | Set-Content (Join-Path $moduleBase "Private\Get-HealthStatus.ps1")

# --- Public/Get-ServerHealth.ps1 ---
@'
function Get-ServerHealth {
    [CmdletBinding()]
    param([string]$ComputerName = $env:COMPUTERNAME)

    try {
        $cpu = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average
        $os = Get-CimInstance Win32_OperatingSystem
        $memPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)
        $disk = Get-PSDrive C
        $diskPct = [math]::Round(($disk.Used / ($disk.Used + $disk.Free)) * 100, 1)
    } catch {
        $cpu = 0; $memPct = 0; $diskPct = 0
    }

    $maxVal = [math]::Max($cpu, [math]::Max($memPct, $diskPct))

    [PSCustomObject]@{
        Computer      = $ComputerName
        CPUPercent    = [math]::Round($cpu, 1)
        MemoryPercent = $memPct
        DiskPercent   = $diskPct
        Status        = Get-HealthStatus -Value $maxVal
    }
}
'@ | Set-Content (Join-Path $moduleBase "Public\Get-ServerHealth.ps1")

# --- Public/Test-PortConnection.ps1 ---
@'
function Test-PortConnection {
    [CmdletBinding()]
    param(
        [string]$ComputerName = "localhost",
        [Parameter(Mandatory)]
        [ValidateRange(1, 65535)]
        [int]$Port
    )

    $isOpen = $false
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $result = $client.BeginConnect($ComputerName, $Port, $null, $null)
        $isOpen = $result.AsyncWaitHandle.WaitOne(2000, $false) -and $client.Connected
        $client.Close()
    } catch { $isOpen = $false }

    [PSCustomObject]@{
        ComputerName = $ComputerName
        Port         = $Port
        IsOpen       = $isOpen
    }
}
'@ | Set-Content (Join-Path $moduleBase "Public\Test-PortConnection.ps1")

# --- Public/Get-DiskReport.ps1 ---
@'
function Get-DiskReport {
    [CmdletBinding()]
    param([string]$DriveFilter = "*")

    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction SilentlyContinue | ForEach-Object {
        $totalGB = [math]::Round($_.Size / 1GB, 2)
        $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
        $usedPct = if ($totalGB -gt 0) { [math]::Round((($totalGB - $freeGB) / $totalGB) * 100, 1) } else { 0 }

        [PSCustomObject]@{
            Drive       = $_.DeviceID
            TotalGB     = $totalGB
            FreeGB      = $freeGB
            UsedPercent = $usedPct
            Status      = Get-HealthStatus -Value $usedPct -Warning 75 -Critical 90
        }
    } | Where-Object { $_.Drive -like $DriveFilter }
}
'@ | Set-Content (Join-Path $moduleBase "Public\Get-DiskReport.ps1")

# --- Module Loader ---
@'
Get-ChildItem "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}
'@ | Set-Content (Join-Path $moduleBase "ServerTools.psm1")

# --- Manifest ---
$manifestParams = @{
    Path = Join-Path $moduleBase "ServerTools.psd1"
    RootModule = "ServerTools.psm1"
    ModuleVersion = "1.0.0"
    Author = "PowerShell Academy"
    Description = "Server health monitoring and reporting tools"
    FunctionsToExport = @("Get-ServerHealth", "Test-PortConnection", "Get-DiskReport")
    PowerShellVersion = "7.0"
}
New-ModuleManifest @manifestParams

# --- Tests ---
@'
BeforeAll { Import-Module "$PSScriptRoot\..\ServerTools.psd1" -Force }

Describe "Get-ServerHealth" {
    It "Returns a PSCustomObject" {
        Get-ServerHealth | Should -BeOfType [PSCustomObject]
    }
    It "Has Computer property" {
        (Get-ServerHealth).Computer | Should -Not -BeNullOrEmpty
    }
    It "Status is valid" {
        (Get-ServerHealth).Status | Should -BeIn @("Healthy", "Warning", "Critical")
    }
    It "CPU is between 0 and 100" {
        $h = Get-ServerHealth
        $h.CPUPercent | Should -BeGreaterOrEqual 0
        $h.CPUPercent | Should -BeLessOrEqual 100
    }
}

AfterAll { Remove-Module ServerTools -Force -ErrorAction SilentlyContinue }
'@ | Set-Content (Join-Path $moduleBase "Tests\Get-ServerHealth.Tests.ps1")

@'
BeforeAll { Import-Module "$PSScriptRoot\..\ServerTools.psd1" -Force }

Describe "Test-PortConnection" {
    It "Returns IsOpen property" {
        $r = Test-PortConnection -Port 80
        $r.PSObject.Properties.Name | Should -Contain "IsOpen"
    }
    It "IsOpen is boolean" {
        (Test-PortConnection -Port 99999).IsOpen | Should -BeOfType [bool]
    }
    It "Reports port correctly" {
        (Test-PortConnection -Port 12345).Port | Should -Be 12345
    }
}

AfterAll { Remove-Module ServerTools -Force -ErrorAction SilentlyContinue }
'@ | Set-Content (Join-Path $moduleBase "Tests\Test-PortConnection.Tests.ps1")

@'
BeforeAll { Import-Module "$PSScriptRoot\..\ServerTools.psd1" -Force }

Describe "Get-DiskReport" {
    It "Returns results" {
        Get-DiskReport | Should -Not -BeNullOrEmpty
    }
    It "Has Drive property" {
        (Get-DiskReport | Select-Object -First 1).Drive | Should -Not -BeNullOrEmpty
    }
    It "UsedPercent is between 0 and 100" {
        $disk = Get-DiskReport | Select-Object -First 1
        $disk.UsedPercent | Should -BeGreaterOrEqual 0
        $disk.UsedPercent | Should -BeLessOrEqual 100
    }
}

AfterAll { Remove-Module ServerTools -Force -ErrorAction SilentlyContinue }
'@ | Set-Content (Join-Path $moduleBase "Tests\Get-DiskReport.Tests.ps1")

# --- Verify ---
Write-Host "=== Module Created ===" -ForegroundColor Cyan
Get-ChildItem $moduleBase -Recurse -File | ForEach-Object {
    Write-Output "  $($_.FullName.Replace($moduleBase, 'ServerTools'))"
}

Import-Module $moduleBase -Force
Write-Host "`nExported:" -ForegroundColor Yellow
Get-Command -Module ServerTools | ForEach-Object { Write-Output "  $($_.Name)" }

$health = Get-ServerHealth
Write-Host "`nHealth: $($health.Status) (CPU:$($health.CPUPercent)% Mem:$($health.MemoryPercent)%)" -ForegroundColor Green

Remove-Module ServerTools -Force
Remove-Item $moduleBase -Recurse -Force
Write-Output "`nModule demo cleaned up."
