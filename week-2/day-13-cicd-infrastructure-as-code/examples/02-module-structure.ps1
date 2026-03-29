# =============================================================================
# Day 13 — Module Structure and Best Practices
# =============================================================================

Write-Host "=== Module Structure ===" -ForegroundColor Cyan

# --- Demonstrate module creation ---
$moduleDir = Join-Path $env:TEMP "DemoServerTools"
$publicDir = Join-Path $moduleDir "Public"
$privateDir = Join-Path $moduleDir "Private"
$testsDir = Join-Path $moduleDir "Tests"

# Create structure
@($moduleDir, $publicDir, $privateDir, $testsDir) | ForEach-Object {
    New-Item -Path $_ -ItemType Directory -Force | Out-Null
}

# --- Public function ---
$getHealthContent = @'
function Get-ServerHealth {
    [CmdletBinding()]
    param(
        [string]$ComputerName = $env:COMPUTERNAME
    )

    $cpuPercent = Get-CPUAverage  # Private function
    $memPercent = Get-MemoryPercent  # Private function

    [PSCustomObject]@{
        Computer     = $ComputerName
        CPUPercent   = $cpuPercent
        MemoryPercent = $memPercent
        Status       = Get-HealthStatus -CPU $cpuPercent -Memory $memPercent
    }
}
'@
Set-Content -Path (Join-Path $publicDir "Get-ServerHealth.ps1") -Value $getHealthContent

# --- Private helpers ---
$privateContent = @'
function Get-CPUAverage {
    try {
        (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average
    } catch { 0 }
}

function Get-MemoryPercent {
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)
    } catch { 0 }
}

function Get-HealthStatus {
    param([double]$CPU, [double]$Memory)
    if ($CPU -ge 90 -or $Memory -ge 90) { "Critical" }
    elseif ($CPU -ge 70 -or $Memory -ge 80) { "Warning" }
    else { "Healthy" }
}
'@
Set-Content -Path (Join-Path $privateDir "Helpers.ps1") -Value $privateContent

# --- Module loader ---
$psmContent = @'
# Load private functions
Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
}

# Load and export public functions
Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}
'@
Set-Content -Path (Join-Path $moduleDir "DemoServerTools.psm1") -Value $psmContent

# --- Module manifest ---
$manifestParams = @{
    Path              = Join-Path $moduleDir "DemoServerTools.psd1"
    RootModule        = "DemoServerTools.psm1"
    ModuleVersion     = "1.0.0"
    Author            = "PowerShell Academy"
    Description       = "Server health monitoring tools"
    FunctionsToExport = @("Get-ServerHealth")
    PowerShellVersion = "7.0"
}
New-ModuleManifest @manifestParams

# --- Test file ---
$testContent = @'
BeforeAll {
    Import-Module "$PSScriptRoot\..\DemoServerTools.psd1" -Force
}

Describe "Get-ServerHealth" {
    It "Returns a PSCustomObject" {
        $result = Get-ServerHealth
        $result | Should -BeOfType [PSCustomObject]
    }

    It "Has required properties" {
        $result = Get-ServerHealth
        $result.PSObject.Properties.Name | Should -Contain "Computer"
        $result.PSObject.Properties.Name | Should -Contain "CPUPercent"
        $result.PSObject.Properties.Name | Should -Contain "Status"
    }

    It "Returns valid status" {
        $result = Get-ServerHealth
        $result.Status | Should -BeIn @("Healthy", "Warning", "Critical")
    }
}

AfterAll {
    Remove-Module DemoServerTools -Force -ErrorAction SilentlyContinue
}
'@
Set-Content -Path (Join-Path $testsDir "Get-ServerHealth.Tests.ps1") -Value $testContent

# --- Display structure ---
Write-Host "`nModule structure:" -ForegroundColor Yellow
Get-ChildItem $moduleDir -Recurse -File | ForEach-Object {
    $relative = $_.FullName.Replace($moduleDir, "DemoServerTools")
    Write-Output "  $relative"
}

# --- Import and test ---
Write-Host "`n--- Import Module ---" -ForegroundColor Yellow
Import-Module $moduleDir -Force
$commands = Get-Command -Module DemoServerTools
Write-Output "Exported commands: $($commands.Name -join ', ')"

$health = Get-ServerHealth
Write-Output "Health check: CPU=$($health.CPUPercent)% Mem=$($health.MemoryPercent)% Status=$($health.Status)"

Remove-Module DemoServerTools -Force
Remove-Item $moduleDir -Recurse -Force
Write-Output "`nModule demo cleaned up."
