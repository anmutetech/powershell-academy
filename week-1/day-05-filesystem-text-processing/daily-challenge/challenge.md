# Day 5 — Daily Challenge: Log File Analyzer

## The Task

Build a log file analyzer that parses a web server log, extracts meaningful data, and generates a summary report.

## Requirements

1. Read the provided `access.log` file
2. Parse each line to extract: timestamp, HTTP method, URL path, status code, response size
3. Generate a report showing:
   - Total number of requests
   - Breakdown by HTTP status code (200, 301, 404, 500, etc.)
   - Top 5 most visited URLs
   - Top 5 largest responses
   - Error rate (4xx + 5xx as % of total)
4. Export the parsed data to a CSV file
5. Save the summary report to a text file

## Log Format

Each line: `[timestamp] METHOD /path HTTP/1.1 status_code response_size`

Example: `[2026-03-15 10:00:01] GET /index.html HTTP/1.1 200 5432`

## Example Output

```
===== Web Server Log Analysis =====

Total Requests: 20

Status Code Breakdown:
  200: 12 (60.0%)
  301:  3 (15.0%)
  404:  3 (15.0%)
  500:  2 (10.0%)

Top 5 URLs:
  1. /index.html      - 5 hits
  2. /api/users        - 4 hits
  3. /about            - 3 hits
  4. /login            - 2 hits
  5. /api/products     - 2 hits

Error Rate: 25.0% (5 errors out of 20 requests)

Report saved to: analysis-report.txt
Data exported to: parsed-log.csv
```

## Hints

- Use `-match` with a regex pattern to parse each line
- Use `Group-Object` for counting occurrences
- Use `Measure-Object` for aggregations
- The regex pattern: `\[(.+?)\]\s(\w+)\s(.+?)\sHTTP/\S+\s(\d+)\s(\d+)`
