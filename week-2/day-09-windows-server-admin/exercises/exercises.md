# Day 9 — Exercises

## Exercise 1: Service Monitor Dashboard
Write a script that:
- Takes a list of critical service names
- Checks each service's status, start type, and memory usage
- Displays a color-coded dashboard
- Alerts if any critical service is stopped
- Optionally starts stopped services (with `-AutoRestart` switch)

## Exercise 2: Event Log Analyzer
Write a function `Get-EventSummary` that:
- Accepts a log name and time range
- Counts events by level (Critical, Error, Warning, Information)
- Finds the top 5 most frequent Event IDs
- Identifies peak hours for errors
- Returns structured output

## Exercise 3: System Health Reporter
Create a comprehensive system report function that collects:
- CPU, Memory, Disk usage
- Top 10 processes by memory
- Network adapter status
- Recent errors from event logs
- Installed updates in the last 30 days
- Outputs as both console display and JSON file

## Exercise 4: Scheduled Task Manager
Write functions to:
- List all enabled scheduled tasks with next run time
- Create a new scheduled task from parameters
- Export scheduled task configuration to JSON (for backup)
- Import and recreate from JSON backup

## Exercise 5: Remote Server Inventory
Write a script that (simulated):
- Reads a list of server names
- Collects system info from each server (simulate with local data)
- Compares configurations across servers
- Identifies outliers (different OS version, low disk space, etc.)
- Exports a comparison matrix to CSV
