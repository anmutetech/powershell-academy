# =============================================================================
# Day 2 Daily Challenge — Simple Calculator (Starter)
# =============================================================================

Write-Host "===== PowerShell Calculator =====" -ForegroundColor Cyan

# TODO: Create a loop variable
$continue = $true

do {
    Write-Host ""

    # TODO: Get first number from user with Read-Host
    # TODO: Validate it is a number using [double]::TryParse()
    # Hint: $num1 = 0.0; if (-not [double]::TryParse($input, [ref]$num1)) { ... }

    # TODO: Get the operator (+, -, *, /)
    # TODO: Validate it is one of the four allowed operators

    # TODO: Get second number and validate

    # TODO: Check for division by zero

    # TODO: Use a switch statement to perform the calculation

    # TODO: Display the result formatted to 2 decimal places

    # TODO: Ask if they want to continue, update $continue variable

} while ($continue)

Write-Host "`nThank you for using PowerShell Calculator!" -ForegroundColor Cyan
