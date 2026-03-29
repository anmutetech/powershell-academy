# Day 13 — Exercises

## Exercise 1: Write Pester Tests
Write Pester tests for a `ConvertTo-Celsius` function:
- Test normal conversions (32F=0C, 212F=100C, 72F=22.22C)
- Test negative temperatures
- Test edge case: absolute zero (-459.67F = -273.15C)
- Test that output is a [double]

## Exercise 2: Build a Module
Create a complete PowerShell module `MathTools` with:
- Public functions: `Get-Average`, `Get-Median`, `Get-StandardDeviation`
- Private helper: `Assert-NumberArray` (validates input)
- Module manifest with proper metadata
- Pester tests for each public function

## Exercise 3: Script Analyzer Compliance
Take any script from a previous day and:
- Run PSScriptAnalyzer on it
- Fix all errors and warnings
- Document which rules were triggered and why
- Create a PSScriptAnalyzer settings file to customize rules

## Exercise 4: GitHub Actions Workflow
Write a complete GitHub Actions workflow that:
- Triggers on push to main and PRs
- Runs PSScriptAnalyzer
- Runs Pester tests on Windows and Linux
- Generates a test report artifact
- Publishes results as PR comments (simulated)

## Exercise 5: IaC Deployment Script
Create an infrastructure deployment script that:
- Reads environment config from a `.psd1` file
- Validates the config before deploying
- Deploys resources idempotently (check before create)
- Supports `-WhatIf` for dry runs
- Logs all operations
- Runs Pester tests after deployment to verify
