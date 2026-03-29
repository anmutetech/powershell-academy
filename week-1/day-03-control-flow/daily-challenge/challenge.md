# Day 3 — Daily Challenge: Employee Report Generator

## The Task

Read a CSV file of employees and generate a filtered, formatted report using control flow and pipeline filtering.

## Requirements

1. Import `employees.csv` using `Import-Csv`
2. Display total employee count
3. Use a `switch` statement to categorize each employee's salary:
   - $90,000+: "Senior"
   - $70,000-$89,999: "Mid-Level"
   - Below $70,000: "Junior"
4. Filter employees by department (prompt user or use a variable)
5. Display employees sorted by salary (highest first)
6. Calculate and display the average salary for the filtered department
7. Show how many employees are in each salary category

## Example Output

```
===== Employee Report Generator =====

Total employees: 10

Department filter: IT

IT Department Employees (sorted by salary):
  1. Charlie    - IT       - $92,000  [Senior]
  2. Eve        - IT       - $88,000  [Mid-Level]
  3. Alice      - IT       - $85,000  [Mid-Level]

Average IT salary: $88,333.33

Salary Distribution (IT):
  Senior:    1
  Mid-Level: 2
  Junior:    0
```

## Hints

- Use `Import-Csv` to read the CSV file
- Cast salary to integer with `[int]` when comparing
- Use `Where-Object` for filtering by department
- Use `Sort-Object` for sorting
- Use `Measure-Object -Average` for calculating averages
- Use `foreach` or `ForEach-Object` with a `switch` inside for categorization
