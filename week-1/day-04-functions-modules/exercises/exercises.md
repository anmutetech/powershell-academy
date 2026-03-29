# Day 4 — Exercises

## Exercise 1: Temperature Converter
Write a function `Convert-Temperature` that:
- Takes a `[double]$Degrees` parameter and a `[string]$From` parameter (`"Celsius"` or `"Fahrenheit"`)
- Returns a `[PSCustomObject]` with the original and converted values
- Uses `[ValidateSet()]` for the `$From` parameter

Formula: `F = (C * 9/5) + 32` and `C = (F - 32) * 5/9`

## Exercise 2: Password Generator
Write a function `New-RandomPassword` that:
- Takes a `[int]$Length` parameter (default 16) with `[ValidateRange(8, 128)]`
- Takes a `[switch]$IncludeSpecialChars` parameter
- Returns a random password string
- Uses `Get-Random` to pick characters

## Exercise 3: Service Monitor
Write an advanced function `Get-ServiceHealth` that:
- Uses `[CmdletBinding()]`
- Takes `[string[]]$ServiceName` with `ValueFromPipeline`
- Has a `process` block that checks each service
- Returns a `[PSCustomObject]` with Name, Status, and StartType
- Handles non-existent services gracefully

Test it with: `"Spooler", "W32Time", "FakeService" | Get-ServiceHealth`

## Exercise 4: File Age Report
Write a function `Get-OldFiles` that:
- Takes `[string]$Path` (mandatory, validated with `ValidateScript` to check path exists)
- Takes `[int]$OlderThanDays` (default 30)
- Returns files older than the specified days with Name, SizeMB, and LastModified
- Supports `-Verbose` to show progress

## Exercise 5: Math Library
Create three functions that form a mini "module":
- `Get-Average` — takes an array of numbers, returns the average
- `Get-Median` — takes an array of numbers, returns the median
- `Get-StandardDeviation` — takes an array of numbers, returns the standard deviation

Test all three with the same dataset: `@(85, 92, 78, 95, 88, 72, 91)`
