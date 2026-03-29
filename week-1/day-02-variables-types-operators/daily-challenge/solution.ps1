# =============================================================================
# Day 2 Daily Challenge — Simple Calculator (Solution)
# =============================================================================

Write-Host "===== PowerShell Calculator =====" -ForegroundColor Cyan

$continue = $true
$history = [System.Collections.ArrayList]@()

do {
    Write-Host ""

    # Get first number
    $input1 = Read-Host "Enter the first number"
    $num1 = 0.0
    if (-not [double]::TryParse($input1, [ref]$num1)) {
        Write-Host "Error: '$input1' is not a valid number." -ForegroundColor Red
        continue
    }

    # Get operator
    $operator = Read-Host "Enter the operator (+, -, *, /)"
    if ($operator -notin @("+", "-", "*", "/")) {
        Write-Host "Error: '$operator' is not valid. Use +, -, *, /" -ForegroundColor Red
        continue
    }

    # Get second number
    $input2 = Read-Host "Enter the second number"
    $num2 = 0.0
    if (-not [double]::TryParse($input2, [ref]$num2)) {
        Write-Host "Error: '$input2' is not a valid number." -ForegroundColor Red
        continue
    }

    # Check division by zero
    if ($operator -eq "/" -and $num2 -eq 0) {
        Write-Host "Error: Division by zero is not allowed." -ForegroundColor Red
        continue
    }

    # Calculate
    $result = switch ($operator) {
        "+" { $num1 + $num2 }
        "-" { $num1 - $num2 }
        "*" { $num1 * $num2 }
        "/" { $num1 / $num2 }
    }

    # Display result
    $equation = "{0} {1} {2} = {3:N2}" -f $num1, $operator, $num2, $result
    Write-Host "`nResult: $equation" -ForegroundColor Green
    $history.Add($equation) | Out-Null

    # Continue?
    $response = Read-Host "`nWould you like to calculate again? (y/n)"
    if ($response -ne "y") { $continue = $false }

} while ($continue)

if ($history.Count -gt 0) {
    Write-Host "`n===== Calculation History =====" -ForegroundColor Cyan
    for ($i = 0; $i -lt $history.Count; $i++) {
        Write-Host "  $($i + 1). $($history[$i])"
    }
}

Write-Host "`nThank you for using PowerShell Calculator!" -ForegroundColor Cyan
