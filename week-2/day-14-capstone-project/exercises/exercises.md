# Day 14 — Capstone Exercises

These exercises are stretch goals for the capstone project.

## Exercise 1: Add HTML Report
Extend `Export-DashboardReport` to generate an HTML file with:
- Styled tables using inline CSS
- Color-coded health indicators
- Charts using simple HTML/CSS (progress bars)
- Summary section at the top

## Exercise 2: Add Email Notification
Create a function `Send-AlertNotification` that:
- Takes health and security data
- Generates an email body (HTML)
- Simulates sending via SMTP
- Only alerts when status is Warning or Critical

## Exercise 3: Add Configuration Management
Create a function `Set-EnvironmentConfig` that:
- Reads/writes environment config from a `.psd1` file
- Validates config schema
- Supports multiple environments
- Tracks config changes with a changelog

## Exercise 4: Add Parallel Processing
Modify `Get-InfrastructureHealth` to:
- Accept multiple server names
- Process servers in parallel using `ForEach-Object -Parallel`
- Aggregate results
- Show progress

## Exercise 5: Publish to PowerShell Gallery
Prepare your module for publication:
- Ensure manifest has all required fields
- Add license file
- Add changelog
- Test with `Test-ModuleManifest`
- Document the publication process
