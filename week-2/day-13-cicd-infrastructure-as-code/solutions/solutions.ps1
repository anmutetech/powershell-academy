# =============================================================================
# Day 13 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Pester Tests (shown as manual tests) ---
Write-Host "=== Exercise 1: Pester Tests ===" -ForegroundColor Cyan

function ConvertTo-Celsius {
    param([double]$Fahrenheit)
    [math]::Round(($Fahrenheit - 32) * 5 / 9, 2)
}

# Manual test execution (would be Pester in real use)
$tests = @(
    @{F=32; Expected=0; Desc="Freezing point"}
    @{F=212; Expected=100; Desc="Boiling point"}
    @{F=72; Expected=22.22; Desc="Room temperature"}
    @{F=-40; Expected=-40; Desc="Same in both scales"}
    @{F=-459.67; Expected=-273.15; Desc="Absolute zero"}
)

foreach ($t in $tests) {
    $result = ConvertTo-Celsius $t.F
    $pass = $result -eq $t.Expected
    $color = if ($pass) { "Green" } else { "Red" }
    Write-Host ("  [{0}] {1}: {2}F -> {3}C (expected {4}C)" -f $(if($pass){"PASS"}else{"FAIL"}), $t.Desc, $t.F, $result, $t.Expected) -ForegroundColor $color
}

Write-Host @"

Pester version:
Describe "ConvertTo-Celsius" {
    It "Converts 32F to 0C" { ConvertTo-Celsius 32 | Should -Be 0 }
    It "Converts 212F to 100C" { ConvertTo-Celsius 212 | Should -Be 100 }
    It "Returns double type" { ConvertTo-Celsius 72 | Should -BeOfType [double] }
}
"@ -ForegroundColor Gray

# --- Exercise 2: Math Module ---
Write-Host "`n=== Exercise 2: MathTools Module ===" -ForegroundColor Cyan

function Assert-NumberArray {
    param([double[]]$Numbers)
    if ($null -eq $Numbers -or $Numbers.Count -eq 0) {
        throw "Input must be a non-empty array of numbers"
    }
}

function Get-Average {
    param([Parameter(Mandatory)][double[]]$Numbers)
    Assert-NumberArray $Numbers
    ($Numbers | Measure-Object -Average).Average
}

function Get-Median {
    param([Parameter(Mandatory)][double[]]$Numbers)
    Assert-NumberArray $Numbers
    $sorted = $Numbers | Sort-Object
    $mid = [math]::Floor($sorted.Count / 2)
    if ($sorted.Count % 2 -eq 0) {
        ($sorted[$mid - 1] + $sorted[$mid]) / 2
    } else {
        $sorted[$mid]
    }
}

function Get-StandardDeviation {
    param([Parameter(Mandatory)][double[]]$Numbers)
    Assert-NumberArray $Numbers
    $avg = Get-Average $Numbers
    $sumSq = ($Numbers | ForEach-Object { [math]::Pow($_ - $avg, 2) } | Measure-Object -Sum).Sum
    [math]::Round([math]::Sqrt($sumSq / $Numbers.Count), 4)
}

$data = @(85, 92, 78, 95, 88, 72, 91)
Write-Output "Data: $($data -join ', ')"
Write-Output "Average: $(Get-Average $data)"
Write-Output "Median: $(Get-Median $data)"
Write-Output "StdDev: $(Get-StandardDeviation $data)"

# --- Exercise 3: Script Analyzer ---
Write-Host "`n=== Exercise 3: Script Analyzer ===" -ForegroundColor Cyan
Write-Output "Common PSScriptAnalyzer rules:"
Write-Output "  PSAvoidUsingWriteHost       - Use Write-Output for data"
Write-Output "  PSUseDeclaredVarsMoreThanAssignments - Remove unused variables"
Write-Output "  PSAvoidUsingPlainTextForPassword - Use SecureString"
Write-Output "  PSUseShouldProcessForStateChangingFunctions - Add SupportsShouldProcess"
Write-Output "  PSUsePSCredentialType       - Use [PSCredential] not [string]"

# --- Exercise 4: GitHub Actions ---
Write-Host "`n=== Exercise 4: GitHub Actions ===" -ForegroundColor Cyan

$workflow = @"
name: PowerShell CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    strategy:
      matrix:
        os: [windows-latest, ubuntu-latest]
    runs-on: `${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Install Pester
        shell: pwsh
        run: Install-Module Pester -Force -Scope CurrentUser
      - name: Run Tests
        shell: pwsh
        run: Invoke-Pester -Output Detailed -CI
"@
Write-Output $workflow

# --- Exercise 5: IaC Deploy ---
Write-Host "`n=== Exercise 5: IaC Deployment ===" -ForegroundColor Cyan

function Deploy-Environment {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateSet("Dev","Staging","Production")]
        [string]$Environment
    )

    $configs = @{
        Dev = @{RG="rg-dev";Location="eastus";VMSize="B1s";Count=1}
        Staging = @{RG="rg-staging";Location="eastus";VMSize="B2s";Count=2}
        Production = @{RG="rg-prod";Location="eastus";VMSize="D4s";Count=3}
    }

    $cfg = $configs[$Environment]
    Write-Verbose "Deploying $Environment to $($cfg.Location)"

    $resources = @("ResourceGroup","Network","Storage","Compute")
    foreach ($res in $resources) {
        if ($PSCmdlet.ShouldProcess("$res ($($cfg.RG))", "Deploy")) {
            Write-Output "  Deployed: $res"
        }
    }

    Write-Output "Environment $Environment: $($cfg.Count)x $($cfg.VMSize) deployed"
}

Deploy-Environment -Environment "Staging" -WhatIf -Verbose
