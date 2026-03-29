# Day 6 — Exercises

## Exercise 1: Safe File Reader
Write a function `Read-FileSafely` that:
- Takes a file path parameter
- Uses `try/catch` with `-ErrorAction Stop`
- Returns the file content if the file exists
- Returns a friendly error message if the file doesn't exist
- Returns a different message if the file exists but can't be read (permissions)
- Uses typed `catch` blocks for different exception types

## Exercise 2: Input Validator
Write a function `Test-UserInput` that validates:
- Email format (use regex in a `try/catch`)
- Port number (1-65535, catch `ArgumentOutOfRangeException`)
- Date string (try parsing with `[datetime]::Parse()`)
- Returns a `[PSCustomObject]` with IsValid, Value, and ErrorMessage for each input

## Exercise 3: Error Logger
Write a `Write-ErrorLog` function that:
- Accepts pipeline input (error records)
- Writes to a log file with timestamp, error message, script line number, and stack trace
- Supports `-Append` and `-Path` parameters
- Can be used like: `$Error | Write-ErrorLog -Path "errors.log"`

## Exercise 4: Graceful Service Restart
Write a function `Restart-ServiceSafely` that:
- Takes a service name
- Checks if the service exists (handle gracefully)
- Stops the service with a timeout
- Starts it back up
- Verifies it's running
- Uses `try/catch/finally` with proper error handling at each step
- Logs each step with `Write-Verbose`

## Exercise 5: Defensive Script
Take any script from a previous day's challenge and add:
- `try/catch` blocks around all external operations
- Input validation with `throw` for bad inputs
- A `Write-Log` function for all operations
- Proper `-ErrorAction` usage on all cmdlets
- A summary of errors at the end
