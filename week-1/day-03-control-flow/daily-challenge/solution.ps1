# =============================================================================
# Day 3 Daily Challenge — Employee Report Generator (Solution)
# =============================================================================

Write-Host "===== Employee Report Generator =====" -ForegroundColor Cyan

# Import CSV
$employees = Import-Csv -Path "$PSScriptRoot\employees.csv"
Write-Host "`nTotal employees: $($employees.Count)"

# Department filter
$filterDept = "IT"
Write-Host "`nDepartment filter: $filterDept"

# Filter and sort
$filtered = $employees |
    Where-Object { $_.Department -eq $filterDept } |
    Sort-Object { [int]$_.Salary } -Descending

# Categorize and display
Write-Host "`n$filterDept Department Employees (sorted by salary):" -ForegroundColor Yellow
$seniorCount = 0
$midCount = 0
$juniorCount = 0
$index = 1

foreach ($emp in $filtered) {
    $salary = [int]$emp.Salary
    $level = switch ($salary) {
        {$_ -ge 90000} { "Senior"; $script:seniorCount++; break }
        {$_ -ge 70000} { "Mid-Level"; $script:midCount++; break }
        default         { "Junior"; $script:juniorCount++; break }
    }

    Write-Host ("  {0}. {1,-12} - {2,-10} - `${3,6:N0}  [{4}]" -f $index, $emp.Name, $emp.Department, $salary, $level)
    $index++
}

# Average salary
$avg = ($filtered | ForEach-Object { [int]$_.Salary } | Measure-Object -Average).Average
Write-Host ("`nAverage {0} salary: `${1:N2}" -f $filterDept, $avg) -ForegroundColor Green

# Salary distribution
Write-Host "`nSalary Distribution ($filterDept):" -ForegroundColor Yellow
Write-Host "  Senior:    $seniorCount"
Write-Host "  Mid-Level: $midCount"
Write-Host "  Junior:    $juniorCount"

Write-Host "`nReport complete." -ForegroundColor Cyan
