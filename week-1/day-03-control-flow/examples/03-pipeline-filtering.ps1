# =============================================================================
# Day 3 — Pipeline Filtering with Where-Object
# =============================================================================

# --- Where-Object: script block syntax ---
Write-Host "=== Running Services ===" -ForegroundColor Cyan
Get-Service | Where-Object { $_.Status -eq "Running" } | Select-Object -First 5 Name, Status

# --- Where-Object: simplified syntax ---
Write-Host "`n=== Stopped Services (simplified syntax) ===" -ForegroundColor Cyan
Get-Service | Where-Object Status -eq "Stopped" | Select-Object -First 5 Name, Status

# --- Combining conditions ---
Write-Host "`n=== Large Processes (CPU > 0) ===" -ForegroundColor Cyan
Get-Process | Where-Object { $_.CPU -gt 0 } |
    Sort-Object CPU -Descending |
    Select-Object -First 5 Name, CPU, @{Name="MemoryMB"; Expression={[math]::Round($_.WorkingSet64 / 1MB, 2)}}

# --- Filtering with comparison operators ---
Write-Host "`n=== Services starting with 'W' ===" -ForegroundColor Cyan
Get-Service | Where-Object { $_.Name -like "W*" } | Select-Object -First 5 Name, Status

# --- Filtering arrays ---
Write-Host "`n=== Filtering Numbers ===" -ForegroundColor Cyan
$numbers = 1..20
$evens = $numbers | Where-Object { $_ % 2 -eq 0 }
Write-Output "Even numbers: $($evens -join ', ')"

$greaterThan15 = $numbers | Where-Object { $_ -gt 15 }
Write-Output "Greater than 15: $($greaterThan15 -join ', ')"

# --- Filtering hashtable arrays ---
Write-Host "`n=== Employee Filter ===" -ForegroundColor Cyan
$employees = @(
    @{ Name = "Alice"; Department = "IT"; Salary = 85000 }
    @{ Name = "Bob"; Department = "HR"; Salary = 72000 }
    @{ Name = "Charlie"; Department = "IT"; Salary = 92000 }
    @{ Name = "Diana"; Department = "Finance"; Salary = 78000 }
    @{ Name = "Eve"; Department = "IT"; Salary = 88000 }
)

$itStaff = $employees | Where-Object { $_.Department -eq "IT" }
foreach ($emp in $itStaff) {
    Write-Output "$($emp.Name) - $($emp.Department) - $($emp.Salary)"
}

# --- Chaining pipeline operations ---
Write-Host "`n=== Pipeline Chain: Filter, Sort, Format ===" -ForegroundColor Cyan
Get-Process |
    Where-Object { $_.WorkingSet64 -gt 50MB } |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First 5 Name, @{Name="MemoryMB"; Expression={[math]::Round($_.WorkingSet64 / 1MB)}} |
    Format-Table -AutoSize
