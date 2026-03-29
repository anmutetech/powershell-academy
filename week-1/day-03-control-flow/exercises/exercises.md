# Day 3 — Exercises

## Exercise 1: Traffic Light
Write a script that takes a `$color` variable ("Red", "Yellow", "Green") and uses `if/elseif/else` to print the appropriate action ("Stop", "Caution", "Go"). Handle invalid colors with a message.

## Exercise 2: Grade Calculator
Write a `switch` statement that takes a numeric score (0-100) and prints the letter grade:
- 90-100: A
- 80-89: B
- 70-79: C
- 60-69: D
- Below 60: F

**Hint:** Use script block conditions in your switch: `{$_ -ge 90}`

## Exercise 3: Multiplication Table
Use a `for` loop to print the multiplication table for a given number (1 through 10).
Example for `$num = 7`:
```
7 x 1 = 7
7 x 2 = 14
...
7 x 10 = 70
```

## Exercise 4: Service Health Check
Use `foreach` to loop through a list of service names and check if each one is running. Print the name and status of each service. Use `Get-Service` with `-ErrorAction SilentlyContinue` to handle services that don't exist.

## Exercise 5: FizzBuzz
Loop through numbers 1 to 30. For each number:
- If divisible by both 3 and 5, print "FizzBuzz"
- If divisible by 3, print "Fizz"
- If divisible by 5, print "Buzz"
- Otherwise, print the number

**Hint:** Use the modulo operator `%` and `continue` to skip to the next iteration.
