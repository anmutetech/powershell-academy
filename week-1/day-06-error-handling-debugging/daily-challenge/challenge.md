# Day 6 — Daily Challenge: Resilient File Processor

## The Task

Build a file processing script that demonstrates production-grade error handling — reading files from a directory, processing them, and generating a success/failure report.

## Requirements

1. Accept a directory path as input
2. Scan for all `.csv` and `.json` files in the directory
3. For each file:
   - Try to read it
   - Try to parse it (CSV with `Import-Csv`, JSON with `ConvertFrom-Json`)
   - Count the records/properties
   - Log success or failure
4. Handle these error scenarios:
   - Directory doesn't exist
   - File is empty
   - File has invalid format (bad CSV/JSON)
   - File is locked/inaccessible
5. Generate a summary report showing:
   - Total files found
   - Successfully processed
   - Failed (with error messages)
   - Processing time
6. Write all operations to a log file

## Example Output

```
===== File Processor =====

Scanning: C:\data\input

Processing: users.csv ........ OK (150 records)
Processing: config.json ...... OK (12 properties)
Processing: broken.csv ....... FAIL (Invalid CSV format)
Processing: empty.json ....... FAIL (File is empty)
Processing: report.csv ....... OK (500 records)

===== Summary =====
Total Files:  5
Successful:   3
Failed:       2
Duration:     1.23 seconds

Failed Files:
  - broken.csv: Invalid CSV format on line 15
  - empty.json: File is empty

Log saved to: processing.log
```

## Hints

- Use `[System.Diagnostics.Stopwatch]` for timing
- Use `try/catch` around each file operation
- Use `$_.Exception.GetType()` for specific error handling
- Create test files (including intentionally broken ones) to test your error handling
