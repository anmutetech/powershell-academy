# Day 8 — Exercises

## Exercise 1: User Lookup Function
Write a function `Find-ADUserInfo` that:
- Accepts a username or partial name
- Searches simulated AD data for matches (using `-like`)
- Returns Name, Username, Department, Title, Enabled, LastLogonDate
- Supports pipeline input

## Exercise 2: Bulk User Creator
Write a function `New-BulkADUsers` that:
- Reads a CSV file of new hires
- Creates a simulated AD user for each row
- Adds users to their department group
- Sets initial password with "must change at logon"
- Returns a report of created/failed users
- Uses `try/catch` and `-WhatIf` support

## Exercise 3: Group Membership Report
Write a script that:
- Takes a list of group names
- For each group, lists all members
- Identifies users who are in multiple groups
- Exports a matrix-style report (user vs. group membership)

## Exercise 4: Account Cleanup Tool
Write a function `Get-StaleAccounts` that:
- Finds accounts inactive for a configurable number of days
- Categorizes: "Disable" (90-180 days), "Delete" (180+ days)
- Generates a recommended action for each account
- Supports `-WhatIf` for the disable/delete actions
- Exports the recommendations to CSV

## Exercise 5: Password Compliance Report
Write a script that checks all accounts for:
- Password never expires (flag as non-compliant)
- Password older than 90 days (flag as expiring soon)
- Password older than 180 days (flag as critical)
- Generates a compliance percentage and detailed report
