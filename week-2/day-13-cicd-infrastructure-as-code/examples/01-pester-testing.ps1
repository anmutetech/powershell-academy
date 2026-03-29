# =============================================================================
# Day 13 — Pester Testing Examples
# =============================================================================
# To run: Install-Module Pester -Force; Invoke-Pester -Path $PSScriptRoot

Write-Host "=== Pester Testing Concepts ===" -ForegroundColor Cyan

# --- Functions to test ---
function Get-Average {
    param([double[]]$Numbers)
    if ($Numbers.Count -eq 0) { throw "Cannot average empty array" }
    ($Numbers | Measure-Object -Average).Average
}

function Test-IsEven {
    param([int]$Number)
    $Number % 2 -eq 0
}

function ConvertTo-Celsius {
    param([double]$Fahrenheit)
    [math]::Round(($Fahrenheit - 32) * 5 / 9, 2)
}

function Get-Greeting {
    param(
        [string]$Name,
        [ValidateSet("Morning","Afternoon","Evening")]
        [string]$TimeOfDay = "Morning"
    )

    switch ($TimeOfDay) {
        "Morning"   { "Good morning, $Name!" }
        "Afternoon" { "Good afternoon, $Name!" }
        "Evening"   { "Good evening, $Name!" }
    }
}

# --- Demo: Running tests manually ---
Write-Host "`n--- Manual Test Execution ---" -ForegroundColor Yellow

# Test Get-Average
$testCases = @(
    @{Input=@(10,20,30); Expected=20; Name="positive numbers"}
    @{Input=@(42); Expected=42; Name="single number"}
    @{Input=@(-5,5); Expected=0; Name="negative and positive"}
    @{Input=@(1.5,2.5); Expected=2.0; Name="decimals"}
)

foreach ($test in $testCases) {
    $result = Get-Average -Numbers $test.Input
    $passed = $result -eq $test.Expected
    $icon = if ($passed) { "PASS" } else { "FAIL" }
    $color = if ($passed) { "Green" } else { "Red" }
    Write-Host "  [$icon] Get-Average with $($test.Name): expected $($test.Expected), got $result" -ForegroundColor $color
}

# Test error case
try {
    Get-Average -Numbers @()
    Write-Host "  [FAIL] Should have thrown on empty array" -ForegroundColor Red
} catch {
    Write-Host "  [PASS] Correctly threw on empty array" -ForegroundColor Green
}

# Test ConvertTo-Celsius
$celsiusTests = @(
    @{F=32; C=0}, @{F=212; C=100}, @{F=72; C=22.22}
)
foreach ($t in $celsiusTests) {
    $result = ConvertTo-Celsius -Fahrenheit $t.F
    $passed = $result -eq $t.C
    $icon = if ($passed) { "PASS" } else { "FAIL" }
    $color = if ($passed) { "Green" } else { "Red" }
    Write-Host "  [$icon] ConvertTo-Celsius $($t.F)F -> expected $($t.C)C, got $result" -ForegroundColor $color
}

Write-Host @"

To write proper Pester tests, create a .Tests.ps1 file:

  Describe "Get-Average" {
      It "Returns 20 for (10,20,30)" {
          Get-Average -Numbers @(10,20,30) | Should -Be 20
      }
      It "Throws on empty array" {
          { Get-Average -Numbers @() } | Should -Throw
      }
  }

Run with: Invoke-Pester
"@ -ForegroundColor Gray
