# Day 13 — CI/CD & Infrastructure as Code

Today brings together everything: writing testable PowerShell modules, using Pester for testing, building CI/CD pipelines, and managing infrastructure as code. These are the skills that separate scripters from engineers.

---

## Video Resources

- [Pester Testing Framework](https://www.youtube.com/watch?v=o4ihc7aQgng)
- [PowerShell Modules Deep Dive](https://www.youtube.com/watch?v=KprrLkjPp_4)
- [GitHub Actions with PowerShell](https://www.youtube.com/watch?v=R8_veQiYBjI)

---

## 1. Pester — PowerShell Testing Framework

Pester is the standard testing framework for PowerShell. Every professional module includes Pester tests.

```powershell
# Install Pester
Install-Module Pester -Force -Scope CurrentUser

# Basic test structure
Describe "Math Operations" {
    It "Should add numbers correctly" {
        (2 + 2) | Should -Be 4
    }

    It "Should multiply correctly" {
        (3 * 7) | Should -Be 21
    }

    It "Should not return null" {
        $result = 5 + 3
        $result | Should -Not -BeNullOrEmpty
    }
}
```

### Testing Functions

```powershell
# Function to test (MathHelpers.ps1)
function Get-Average {
    param([double[]]$Numbers)
    if ($Numbers.Count -eq 0) { throw "Cannot average empty array" }
    ($Numbers | Measure-Object -Average).Average
}

# Test file (MathHelpers.Tests.ps1)
BeforeAll {
    . $PSScriptRoot\MathHelpers.ps1  # Dot-source the function file
}

Describe "Get-Average" {
    It "Returns correct average for positive numbers" {
        Get-Average -Numbers @(10, 20, 30) | Should -Be 20
    }

    It "Handles single number" {
        Get-Average -Numbers @(42) | Should -Be 42
    }

    It "Handles decimal numbers" {
        Get-Average -Numbers @(1.5, 2.5) | Should -Be 2.0
    }

    It "Throws on empty array" {
        { Get-Average -Numbers @() } | Should -Throw "Cannot average empty array"
    }
}
```

### Common Assertions

```powershell
$value | Should -Be 42              # Exact equality
$value | Should -BeGreaterThan 10   # Comparison
$value | Should -BeLessThan 100
$value | Should -BeOfType [int]     # Type check
$value | Should -Match "pattern"    # Regex match
$value | Should -BeLike "*.txt"     # Wildcard match
$value | Should -Contain "item"     # Collection contains
$value | Should -Not -BeNullOrEmpty # Not null/empty
{ throw "error" } | Should -Throw   # Exception expected
```

### Running Pester

```powershell
# Run all tests in current directory
Invoke-Pester

# Run specific test file
Invoke-Pester -Path ".\tests\MathHelpers.Tests.ps1"

# Detailed output
Invoke-Pester -Output Detailed

# Generate test report (NUnit XML for CI/CD)
Invoke-Pester -OutputFormat NUnitXml -OutputFile "TestResults.xml"
```

## 2. PowerShell Module Structure

A professional module has a standard structure:

```
MyModule/
├── MyModule.psd1           # Module manifest
├── MyModule.psm1           # Module code
├── Public/                 # Exported functions
│   ├── Get-Something.ps1
│   └── Set-Something.ps1
├── Private/                # Internal helper functions
│   └── Convert-Data.ps1
└── Tests/
    ├── Get-Something.Tests.ps1
    └── Set-Something.Tests.ps1
```

### Module Manifest (.psd1)

```powershell
# Create a module manifest
New-ModuleManifest -Path ".\MyModule\MyModule.psd1" `
    -RootModule "MyModule.psm1" `
    -ModuleVersion "1.0.0" `
    -Author "Your Name" `
    -Description "My automation module" `
    -FunctionsToExport @("Get-Something", "Set-Something")
```

### Module Script (.psm1)

```powershell
# MyModule.psm1

# Import private functions
$privateFunctions = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -ErrorAction SilentlyContinue
foreach ($file in $privateFunctions) {
    . $file.FullName
}

# Import and export public functions
$publicFunctions = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue
foreach ($file in $publicFunctions) {
    . $file.FullName
    Export-ModuleMember -Function $file.BaseName
}
```

## 3. GitHub Actions for PowerShell

```yaml
# .github/workflows/test.yml
name: PowerShell Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Pester
        shell: pwsh
        run: Install-Module Pester -Force -Scope CurrentUser

      - name: Run Tests
        shell: pwsh
        run: |
          $results = Invoke-Pester -Path ./tests -PassThru -Output Detailed
          if ($results.FailedCount -gt 0) {
              throw "$($results.FailedCount) test(s) failed"
          }

      - name: Publish Test Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: TestResults.xml
```

## 4. Script Analyzer (Linting)

PSScriptAnalyzer enforces coding standards.

```powershell
# Install
Install-Module PSScriptAnalyzer -Scope CurrentUser

# Analyze a script
Invoke-ScriptAnalyzer -Path ".\MyScript.ps1"

# Analyze entire module
Invoke-ScriptAnalyzer -Path ".\MyModule\" -Recurse

# Fix issues automatically
Invoke-ScriptAnalyzer -Path ".\MyScript.ps1" -Fix

# Custom rules
Invoke-ScriptAnalyzer -Path ".\MyScript.ps1" -ExcludeRule PSAvoidUsingWriteHost
```

## 5. Infrastructure as Code Patterns

### Configuration Data

```powershell
# environments.psd1
@{
    Dev = @{
        ResourceGroup = "rg-dev"
        Location      = "eastus"
        VMSize        = "Standard_B1s"
        Replicas      = 1
    }
    Staging = @{
        ResourceGroup = "rg-staging"
        Location      = "eastus"
        VMSize        = "Standard_B2s"
        Replicas      = 2
    }
    Production = @{
        ResourceGroup = "rg-production"
        Location      = "eastus"
        VMSize        = "Standard_D4s_v3"
        Replicas      = 3
    }
}
```

### Idempotent Deployment Script

```powershell
function Deploy-Infrastructure {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateSet("Dev", "Staging", "Production")]
        [string]$Environment
    )

    $config = Import-PowerShellDataFile ".\environments.psd1"
    $envConfig = $config[$Environment]

    # Idempotent: check if exists before creating
    $rg = Get-AzResourceGroup -Name $envConfig.ResourceGroup -ErrorAction SilentlyContinue
    if (-not $rg) {
        if ($PSCmdlet.ShouldProcess($envConfig.ResourceGroup, "Create Resource Group")) {
            New-AzResourceGroup -Name $envConfig.ResourceGroup -Location $envConfig.Location
        }
    } else {
        Write-Verbose "Resource group already exists"
    }
}
```

---

## Key Takeaways

1. Write Pester tests for every function — aim for 80%+ coverage
2. Use the standard module structure (Public/Private/Tests)
3. PSScriptAnalyzer catches issues before they reach production
4. GitHub Actions/Azure DevOps automate testing on every push
5. Infrastructure as Code = version-controlled, repeatable deployments
6. Configuration data files (`.psd1`) separate config from code

---

## Interview Prep

**Q: How do you test PowerShell code?**
A: Use Pester, the standard PowerShell testing framework. Write `Describe` blocks for each function, `It` blocks for each test case, and use `Should` assertions. Run tests with `Invoke-Pester` and generate NUnit XML reports for CI/CD integration. Aim for tests that cover happy paths, edge cases, and error conditions.

**Q: What is PSScriptAnalyzer and why is it important?**
A: PSScriptAnalyzer is a static analysis tool (linter) for PowerShell. It checks scripts against best-practice rules — unused variables, missing `CmdletBinding`, `Write-Host` in functions, security issues, and more. It integrates with VS Code for real-time feedback and CI/CD pipelines for enforcement.

**Q: How do you structure a production PowerShell module?**
A: Use the standard structure: a `.psd1` manifest with version and exported functions, a `.psm1` loader that dot-sources from Public/ and Private/ directories, Pester tests in a Tests/ directory, and a `.github/workflows/` for CI. Public functions are exported; private functions are internal helpers.
