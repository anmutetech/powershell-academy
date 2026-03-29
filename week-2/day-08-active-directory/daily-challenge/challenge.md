# Day 8 — Daily Challenge: AD User Onboarding Automation

## The Task

Build a complete user onboarding automation tool that reads new hire data from a CSV, creates accounts, assigns groups, and generates an onboarding report.

## Requirements

1. Read `new-hires.csv` with columns: FirstName, LastName, Department, Title, Manager, StartDate
2. For each new hire:
   - Generate a username (first initial + last name, lowercase)
   - Generate a temporary password
   - Create the user account (simulated)
   - Add to department-based groups
   - Add to "All-Employees" group
3. Handle conflicts (username already exists — append a number)
4. Generate an onboarding report with:
   - Created accounts and their usernames
   - Group assignments
   - Any errors or conflicts
5. Export the report to CSV and display a summary
6. Log all operations

## Example Output

```
===== User Onboarding Automation =====

Processing new-hires.csv (5 new hires)...

  [1/5] Tom Chen -> tchen (IT - Cloud Engineer)
        Groups: IT-Staff, All-Employees
        Status: CREATED

  [2/5] Lisa Park -> lpark (HR - Recruiter)
        Groups: HR-Staff, All-Employees
        Status: CREATED

  [3/5] Tom Clark -> tclark (IT - Developer)
        Username 'tclark' available
        Groups: IT-Staff, DevOps-Team, All-Employees
        Status: CREATED

===== Onboarding Summary =====
  Total:   5
  Created: 5
  Failed:  0

  Report saved to: onboarding-report-2026-03-29.csv
```

## Hints

- Use a hashtable to track existing usernames
- Use splatting (`@params`) for cleaner code
- Map departments to groups with a hashtable
- Use `ConvertTo-SecureString` for passwords
