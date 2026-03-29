# Day 12 — Exercises

## Exercise 1: Password Policy Checker
Write a function that checks if a password meets complexity requirements:
- Minimum 12 characters
- At least one uppercase, lowercase, number, and special character
- Not in a list of common passwords
- Returns a compliance report with pass/fail for each rule

## Exercise 2: File Integrity Monitor
Write a script that:
- Takes a directory path and creates a baseline hash of all files (SHA256)
- Saves the baseline to a JSON file
- Can compare current state against the baseline
- Reports: new files, deleted files, modified files
- Uses `Get-FileHash` for hashing

## Exercise 3: Security Event Monitor
Write a function that:
- Monitors for specific security events (failed logins, lockouts, privilege changes)
- Groups events by source IP and account
- Identifies potential brute-force attempts (>5 failures in 10 minutes)
- Generates an alert report

## Exercise 4: Compliance Scanner
Write a compliance scanning tool that checks:
- Password policy settings
- Account lockout policy
- PowerShell logging enabled
- Firewall status
- Antivirus status
- Windows Update status
- Returns a compliance score (0-100%) with detailed findings

## Exercise 5: Secure Script Template
Create a secure script template that includes:
- Strict mode (`Set-StrictMode -Version Latest`)
- Error action preference set to Stop
- Secure credential handling
- Logging with no sensitive data
- Input validation
- Output sanitization
