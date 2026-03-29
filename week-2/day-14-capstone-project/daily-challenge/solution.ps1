# =============================================================================
# Day 14 Capstone — Enterprise Tools (Solution)
# =============================================================================
# This creates and demonstrates the complete module.

$moduleName = "EnterpriseTools"
$moduleBase = Join-Path $PSScriptRoot $moduleName

# Create structure
@("Public", "Private", "Tests", "Config") | ForEach-Object {
    New-Item -Path (Join-Path $moduleBase $_) -ItemType Directory -Force | Out-Null
}

#region Private Functions
@'
function Write-Log {
    param([string]$Message, [string]$Level = "INFO", [string]$LogPath)
    $entry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    if ($LogPath) { Add-Content -Path $LogPath -Value $entry -ErrorAction SilentlyContinue }
    $color = switch($Level) { "ERROR" {"Red"}; "WARN" {"Yellow"}; "SUCCESS" {"Green"}; default {"Gray"} }
    Write-Host $entry -ForegroundColor $color
}
'@ | Set-Content (Join-Path $moduleBase "Private\Write-Log.ps1")

@'
function Get-HealthStatus {
    param([double]$Value, [int]$Warning = 80, [int]$Critical = 90)
    if ($Value -ge $Critical) { "Critical" }
    elseif ($Value -ge $Warning) { "Warning" }
    else { "Healthy" }
}
'@ | Set-Content (Join-Path $moduleBase "Private\Get-HealthStatus.ps1")
#endregion

#region Public Functions
@'
function New-UserOnboarding {
    [CmdletBinding(SupportsShouldProcess)]
    param([PSCustomObject[]]$NewHires)

    $results = @()
    foreach ($hire in $NewHires) {
        $username = ($hire.FirstName.Substring(0,1) + $hire.LastName).ToLower()
        if ($PSCmdlet.ShouldProcess($username, "Create AD User")) {
            $results += [PSCustomObject]@{
                Username = $username
                FullName = "$($hire.FirstName) $($hire.LastName)"
                Department = $hire.Department
                Status = "Created"
            }
            Write-Log "Created user: $username" -Level "SUCCESS"
        }
    }
    $results
}
'@ | Set-Content (Join-Path $moduleBase "Public\New-UserOnboarding.ps1")

@'
function Get-InfrastructureHealth {
    [CmdletBinding()]
    param([string]$ComputerName = $env:COMPUTERNAME)

    try {
        $cpu = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average
        $os = Get-CimInstance Win32_OperatingSystem
        $memPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)
        $disk = Get-PSDrive C -ErrorAction Stop
        $diskPct = [math]::Round(($disk.Used / ($disk.Used + $disk.Free)) * 100, 1)
    } catch {
        $cpu = 0; $memPct = 0; $diskPct = 0
    }

    $maxVal = [math]::Max($cpu, [math]::Max($memPct, $diskPct))

    [PSCustomObject]@{
        Computer = $ComputerName
        CPUPercent = [math]::Round($cpu, 1)
        MemoryPercent = $memPct
        DiskPercent = $diskPct
        Status = Get-HealthStatus -Value $maxVal
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}
'@ | Set-Content (Join-Path $moduleBase "Public\Get-InfrastructureHealth.ps1")

@'
function Invoke-SecurityAudit {
    [CmdletBinding()]
    param()

    $findings = @()
    $checks = @(
        @{Name="Execution Policy";Weight=15;Check={
            (Get-ExecutionPolicy) -in @("RemoteSigned","AllSigned","Restricted")
        }}
        @{Name="PS Version 7+";Weight=10;Check={
            $PSVersionTable.PSVersion.Major -ge 7
        }}
        @{Name="Running as Standard User";Weight=10;Check={
            -not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        }}
        @{Name="TEMP Directory Secure";Weight=5;Check={ Test-Path $env:TEMP }}
    )

    foreach ($c in $checks) {
        $pass = try { & $c.Check } catch { $false }
        $findings += [PSCustomObject]@{
            Check = $c.Name; Passed = $pass; Weight = $c.Weight
            Status = if ($pass) { "PASS" } else { "FAIL" }
        }
    }

    $totalWeight = ($checks | Measure-Object Weight -Sum).Sum
    $passedWeight = ($findings | Where-Object Passed | Measure-Object Weight -Sum).Sum
    $score = [math]::Round(($passedWeight / $totalWeight) * 100)

    [PSCustomObject]@{
        Score = $score
        Findings = $findings
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}
'@ | Set-Content (Join-Path $moduleBase "Public\Invoke-SecurityAudit.ps1")

@'
function Deploy-AzureEnvironment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateSet("Dev","Staging","Production")]
        [string]$Environment = "Dev"
    )

    $configs = @{
        Dev = @{RG="rg-dev";Location="eastus";VMSize="Standard_B1s";Cost=38}
        Staging = @{RG="rg-staging";Location="eastus";VMSize="Standard_B2s";Cost=62}
        Production = @{RG="rg-prod";Location="eastus";VMSize="Standard_D4s_v3";Cost=280}
    }

    $cfg = $configs[$Environment]
    $resources = @("ResourceGroup","VirtualNetwork","NSG","StorageAccount","VirtualMachine")
    $deployed = @()

    foreach ($res in $resources) {
        if ($PSCmdlet.ShouldProcess("$res ($($cfg.RG))", "Deploy")) {
            $deployed += [PSCustomObject]@{Resource=$res;Status="Created";Environment=$Environment}
        }
    }

    [PSCustomObject]@{
        Environment = $Environment
        Resources = $deployed
        EstimatedMonthlyCost = $cfg.Cost
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}
'@ | Set-Content (Join-Path $moduleBase "Public\Deploy-AzureEnvironment.ps1")

@'
function Export-DashboardReport {
    [CmdletBinding()]
    param([string]$OutputPath = $PWD)

    $health = Get-InfrastructureHealth
    $security = Invoke-SecurityAudit

    # Console output
    Write-Host "`n===== ENTERPRISE DASHBOARD =====" -ForegroundColor Cyan
    Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

    $hColor = switch($health.Status) {"Critical"{"Red"};"Warning"{"Yellow"};default{"Green"}}
    Write-Host "Infrastructure: $($health.Status)" -ForegroundColor $hColor
    Write-Host "  CPU: $($health.CPUPercent)% | Memory: $($health.MemoryPercent)% | Disk: $($health.DiskPercent)%"
    Write-Host "Security Score: $($security.Score)%" -ForegroundColor $(if($security.Score -ge 80){"Green"}else{"Red"})

    # Export
    $timestamp = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $csvPath = Join-Path $OutputPath "dashboard-$timestamp.csv"
    $jsonPath = Join-Path $OutputPath "dashboard-$timestamp.json"

    $security.Findings | Export-Csv $csvPath -NoTypeInformation
    @{Health=$health;Security=@{Score=$security.Score};Generated=$timestamp} |
        ConvertTo-Json -Depth 5 | Set-Content $jsonPath

    [PSCustomObject]@{
        CSVReport = $csvPath
        JSONReport = $jsonPath
        HealthStatus = $health.Status
        SecurityScore = $security.Score
    }
}
'@ | Set-Content (Join-Path $moduleBase "Public\Export-DashboardReport.ps1")
#endregion

#region Module Files
@'
Get-ChildItem "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
    Export-ModuleMember -Function $_.BaseName
}
'@ | Set-Content (Join-Path $moduleBase "EnterpriseTools.psm1")

New-ModuleManifest -Path (Join-Path $moduleBase "EnterpriseTools.psd1") `
    -RootModule "EnterpriseTools.psm1" -ModuleVersion "1.0.0" `
    -Author "PowerShell Academy" -Description "Enterprise infrastructure automation tools" `
    -FunctionsToExport @("New-UserOnboarding","Get-InfrastructureHealth","Invoke-SecurityAudit","Deploy-AzureEnvironment","Export-DashboardReport") `
    -PowerShellVersion "7.0"
#endregion

#region Tests
@'
BeforeAll { Import-Module "$PSScriptRoot\..\EnterpriseTools.psd1" -Force }
Describe "Get-InfrastructureHealth" {
    It "Returns PSCustomObject" { Get-InfrastructureHealth | Should -BeOfType [PSCustomObject] }
    It "Has Status property" { (Get-InfrastructureHealth).Status | Should -Not -BeNullOrEmpty }
    It "Status is valid" { (Get-InfrastructureHealth).Status | Should -BeIn @("Healthy","Warning","Critical") }
    It "CPU between 0-100" {
        $h = Get-InfrastructureHealth
        $h.CPUPercent | Should -BeGreaterOrEqual 0
        $h.CPUPercent | Should -BeLessOrEqual 100
    }
    It "Has Timestamp" { (Get-InfrastructureHealth).Timestamp | Should -Not -BeNullOrEmpty }
}
AfterAll { Remove-Module EnterpriseTools -Force -ErrorAction SilentlyContinue }
'@ | Set-Content (Join-Path $moduleBase "Tests\Get-InfrastructureHealth.Tests.ps1")

@'
BeforeAll { Import-Module "$PSScriptRoot\..\EnterpriseTools.psd1" -Force }
Describe "Invoke-SecurityAudit" {
    It "Returns object with Score" { (Invoke-SecurityAudit).Score | Should -Not -BeNullOrEmpty }
    It "Score is 0-100" {
        $s = (Invoke-SecurityAudit).Score
        $s | Should -BeGreaterOrEqual 0
        $s | Should -BeLessOrEqual 100
    }
    It "Has Findings array" { (Invoke-SecurityAudit).Findings | Should -Not -BeNullOrEmpty }
    It "Findings have Status" { (Invoke-SecurityAudit).Findings[0].Status | Should -BeIn @("PASS","FAIL") }
    It "Has Timestamp" { (Invoke-SecurityAudit).Timestamp | Should -Not -BeNullOrEmpty }
}
AfterAll { Remove-Module EnterpriseTools -Force -ErrorAction SilentlyContinue }
'@ | Set-Content (Join-Path $moduleBase "Tests\Invoke-SecurityAudit.Tests.ps1")

@'
BeforeAll { Import-Module "$PSScriptRoot\..\EnterpriseTools.psd1" -Force }
Describe "Deploy-AzureEnvironment" {
    It "Accepts Dev environment" {
        { Deploy-AzureEnvironment -Environment Dev -WhatIf } | Should -Not -Throw
    }
    It "Returns cost estimate" {
        $d = Deploy-AzureEnvironment -Environment "Dev"
        $d.EstimatedMonthlyCost | Should -BeGreaterThan 0
    }
    It "Returns environment name" {
        (Deploy-AzureEnvironment -Environment "Staging").Environment | Should -Be "Staging"
    }
    It "Has Timestamp" {
        (Deploy-AzureEnvironment -Environment "Dev").Timestamp | Should -Not -BeNullOrEmpty
    }
}
Describe "New-UserOnboarding" {
    It "Creates users from array" {
        $hires = @([PSCustomObject]@{FirstName="Test";LastName="User";Department="IT"})
        $r = New-UserOnboarding -NewHires $hires
        $r.Username | Should -Be "tuser"
    }
}
AfterAll { Remove-Module EnterpriseTools -Force -ErrorAction SilentlyContinue }
'@ | Set-Content (Join-Path $moduleBase "Tests\Deploy-AzureEnvironment.Tests.ps1")
#endregion

# --- Demo ---
Write-Host "===== Module Created =====" -ForegroundColor Cyan
Import-Module $moduleBase -Force

Write-Host "`n--- Get-InfrastructureHealth ---"
Get-InfrastructureHealth | Format-List

Write-Host "--- Invoke-SecurityAudit ---"
$audit = Invoke-SecurityAudit
Write-Host "Score: $($audit.Score)%"
$audit.Findings | Format-Table Check, Status -AutoSize

Write-Host "--- Deploy-AzureEnvironment ---"
Deploy-AzureEnvironment -Environment "Dev" -WhatIf

Write-Host "`n--- New-UserOnboarding ---"
$hires = @([PSCustomObject]@{FirstName="Tom";LastName="Chen";Department="IT"})
New-UserOnboarding -NewHires $hires | Format-Table

Remove-Module EnterpriseTools -Force

# Cleanup generated reports
Get-ChildItem $PSScriptRoot -Filter "dashboard-*" -ErrorAction SilentlyContinue | Remove-Item -Force
Remove-Item $moduleBase -Recurse -Force
Write-Host "`nCapstone module demo complete!" -ForegroundColor Green
