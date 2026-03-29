# =============================================================================
# Day 3 Daily Challenge — Employee Report Generator (Starter)
# =============================================================================

Write-Host "===== Employee Report Generator =====" -ForegroundColor Cyan

# TODO: Import the CSV file
# Hint: $employees = Import-Csv -Path ".\employees.csv"

# TODO: Display total employee count

# TODO: Set the department to filter by
$filterDept = "IT"

# TODO: Filter employees by department using Where-Object

# TODO: Sort filtered employees by salary (descending)
# Hint: You'll need to cast Salary to [int] for proper sorting

# TODO: Loop through filtered employees and categorize each by salary level
# Use a switch statement:
#   $90,000+      -> "Senior"
#   $70,000-89,999 -> "Mid-Level"
#   Below $70,000  -> "Junior"

# TODO: Display each employee with their category

# TODO: Calculate average salary using Measure-Object

# TODO: Count how many employees are in each salary category

Write-Host "`nReport complete." -ForegroundColor Cyan
