# =============================================================================
# Day 5 Daily Challenge — Log File Analyzer (Starter)
# =============================================================================

Write-Host "===== Web Server Log Analysis =====" -ForegroundColor Cyan

$logFile = Join-Path $PSScriptRoot "access.log"

# TODO: Read the log file
# $logLines = Get-Content -Path $logFile

# TODO: Parse each line using regex
# Pattern: \[(.+?)\]\s(\w+)\s(.+?)\sHTTP/\S+\s(\d+)\s(\d+)
# Groups: 1=timestamp, 2=method, 3=path, 4=status, 5=size

# TODO: Store parsed entries in an array of [PSCustomObject]

# TODO: Display total request count

# TODO: Group by status code and show breakdown with percentages

# TODO: Group by URL path, sort by count, show top 5

# TODO: Sort by response size, show top 5 largest

# TODO: Calculate error rate (4xx + 5xx)

# TODO: Export parsed data to CSV

# TODO: Save summary report to text file

Write-Host "`nAnalysis complete." -ForegroundColor Cyan
