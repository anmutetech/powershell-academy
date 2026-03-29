# Day 2 — Daily Challenge: Simple Calculator

## The Task

Build an interactive calculator that runs in a loop until the user quits.

## Requirements

1. Prompt the user for the first number
2. Prompt for an operator (+, -, *, /)
3. Prompt for the second number
4. Validate all inputs (are the numbers valid? is the operator valid?)
5. Handle division by zero with a friendly error message
6. Display the result formatted to 2 decimal places
7. Ask if the user wants to do another calculation
8. Keep looping until they say "n"

## Example Session

```
===== PowerShell Calculator =====

Enter the first number: 10
Enter the operator (+, -, *, /): /
Enter the second number: 3

Result: 10 / 3 = 3.33

Would you like to calculate again? (y/n): y

Enter the first number: hello
Error: 'hello' is not a valid number.

Enter the first number: 5
Enter the operator (+, -, *, /): /
Enter the second number: 0
Error: Division by zero is not allowed.

Would you like to calculate again? (y/n): n

Thank you for using PowerShell Calculator!
```

## Hints

- Use `Read-Host` to get input
- Use `[double]::TryParse()` to validate numbers
- Use a `switch` statement for the operator
- Use a `do { } while ($condition)` loop
- Use the `-f` format operator for decimal formatting: `"{0:N2}" -f $result`
