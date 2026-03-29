# Day 13 — Daily Challenge: Build a Tested PowerShell Module

## The Task

Build a complete, tested PowerShell module called `ServerTools` with CI/CD configuration.

## Requirements

### Module Structure
```
ServerTools/
├── ServerTools.psd1
├── ServerTools.psm1
├── Public/
│   ├── Get-ServerHealth.ps1
│   ├── Test-PortConnection.ps1
│   └── Get-DiskReport.ps1
├── Private/
│   └── Get-HealthStatus.ps1
├── Tests/
│   ├── Get-ServerHealth.Tests.ps1
│   ├── Test-PortConnection.Tests.ps1
│   └── Get-DiskReport.Tests.ps1
└── .github/workflows/
    └── ci.yml
```

### Functions
1. `Get-ServerHealth` — returns CPU, memory, disk, and overall status
2. `Test-PortConnection` — tests if a port is open on a target
3. `Get-DiskReport` — returns disk usage with health status per drive

### Tests (at least 3 per function)
- Happy path tests
- Edge case tests
- Error handling tests

### CI/CD
- GitHub Actions workflow that runs tests on push
- PSScriptAnalyzer check
- Test result artifact upload

## Hints

- Use `New-ModuleManifest` to create the .psd1
- Dot-source functions in the .psm1
- Use `BeforeAll` in Pester to import the module
- Mock external commands with Pester's `Mock` keyword
