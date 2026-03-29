# =============================================================================
# Day 8 Daily Challenge — AD User Onboarding (Starter)
# =============================================================================

Write-Host "===== User Onboarding Automation =====" -ForegroundColor Cyan

# TODO: Define department-to-group mapping
$deptGroups = @{
    "IT"      = @("IT-Staff")
    "HR"      = @("HR-Staff")
    "Finance" = @("Finance-Staff")
}

# TODO: Track existing usernames (simulate existing accounts)
$existingUsers = @("jdoe", "jsmith", "bwilson")

# TODO: Read CSV
# $newHires = Import-Csv -Path "$PSScriptRoot\new-hires.csv"

# TODO: Create a function to generate unique usernames
# function New-Username { param($FirstName, $LastName) ... }
# Handle conflicts: if "tchen" exists, try "tchen2", "tchen3", etc.

# TODO: Create a function to generate temporary passwords
# function New-TempPassword { ... }

# TODO: Loop through each new hire
#   - Generate username
#   - Generate password
#   - Create user (simulated)
#   - Assign groups
#   - Log the operation
#   - Track results

# TODO: Display summary

# TODO: Export report to CSV
