# Day 7 — Review Exercises

These exercises test your understanding of Week 1 concepts. Try to solve them without looking back at previous days.

## Exercise 1: Quick Fire (Variables & Types)
Without running the code, predict the output:
```powershell
$a = "5"
$b = 3
$c = $a + $b       # What is $c?
$d = [int]$a + $b  # What is $d?
$e = $a * $b       # What is $e?
```

## Exercise 2: Pipeline Challenge
Write a single pipeline command that:
1. Gets all processes
2. Filters to only those using more than 50MB of memory
3. Sorts by memory usage (descending)
4. Selects the top 3
5. Displays Name and MemoryMB (WorkingSet64 converted to MB)

## Exercise 3: Function Debugging
This function has 3 bugs. Find and fix them:
```powershell
function Get-FileReport {
    [CmdletBinding()]
    param(
        [string]$Path = "."
        [int]$MinSizeKB
    )

    $files = Get-ChildItem -Path $Path -File -Recurse

    foreach ($file in $files) {
        if ($file.Length / 1KB -gt $MinSize) {
            [PSCustomObject]@{
                Name = $file.Name
                SizeKB = [math]:Round($file.Length / 1KB, 2)
                Modified = $file.LastWriteTime
            }
        }
    }
}
```

## Exercise 4: Error Handling Scenario
Write a function that reads a JSON config file and returns a specific setting. Handle:
- File not found
- Invalid JSON
- Missing key
- Return a default value if anything fails

## Exercise 5: Complete Script
Combine everything into a script that:
1. Reads a CSV of server names
2. For each server, collects basic info (use local machine as stand-in)
3. Filters servers with any health warnings
4. Exports results to both CSV and JSON
5. Logs all operations
