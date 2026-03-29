# =============================================================================
# Day 6 Daily Challenge — Resilient File Processor (Starter)
# =============================================================================

Write-Host "===== File Processor =====" -ForegroundColor Cyan

# TODO: Define a Write-Log function for logging operations
# Hint: Write to both console and a log file with timestamps

# TODO: Accept a directory path (or use a default)
$inputDir = Join-Path $PSScriptRoot "sample-data"

# TODO: Validate the directory exists (throw if not)

# TODO: Create a stopwatch for timing
# Hint: $sw = [System.Diagnostics.Stopwatch]::StartNew()

# TODO: Scan for .csv and .json files
# Hint: Get-ChildItem -Path $inputDir -Include "*.csv", "*.json" -File

# TODO: Initialize counters and results array

# TODO: Loop through each file
#   - Wrap each file in try/catch
#   - Check if file is empty (Length -eq 0)
#   - Parse based on extension (.csv -> Import-Csv, .json -> ConvertFrom-Json)
#   - Count records/properties
#   - Log success or failure
#   - Add result to results array

# TODO: Stop the stopwatch

# TODO: Display summary
#   - Total, successful, failed counts
#   - Duration
#   - List of failed files with error messages

# TODO: Save log file

Write-Host "`nProcessing complete." -ForegroundColor Cyan
