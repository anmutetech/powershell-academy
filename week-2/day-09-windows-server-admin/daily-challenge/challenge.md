# Day 9 — Daily Challenge: Server Monitoring Dashboard

## The Task

Build an interactive server monitoring dashboard that refreshes periodically and alerts on issues.

## Requirements

1. Display real-time system metrics:
   - CPU usage percentage
   - Memory usage percentage and GB
   - Disk usage per drive
   - Top 5 processes by CPU
   - Top 5 processes by memory
2. Service health check for configurable list of services
3. Recent error events from System and Application logs
4. Color-coded thresholds (Green/Yellow/Red)
5. Alert section highlighting any critical issues
6. Auto-refresh option (loop with configurable interval)
7. Export snapshot to JSON on demand

## Example Output

```
============================================================
     SERVER MONITORING DASHBOARD — WORKSTATION-01
     2026-03-29 14:30:00 | Refresh: 30s
============================================================

  CPU:     [####------] 42%        OK
  Memory:  [######----] 65%  10.4/16 GB  OK
  Disk C:  [#####-----] 52%  240/500 GB  OK
  Disk D:  [########--] 87%  870/1000 GB WARNING

  TOP PROCESSES (CPU)          TOP PROCESSES (MEMORY)
  1. chrome       125.3s       1. chrome       1,024 MB
  2. code          89.7s       2. Teams          512 MB
  3. explorer      45.2s       3. code           489 MB

  SERVICES                     EVENT ALERTS (last 1h)
  Spooler    Running  OK       3 Errors in System log
  W32Time    Running  OK       1 Error in Application log
  WinRM      Stopped  ALERT

  ALERTS:
  [!] Disk D: usage at 87% (threshold: 80%)
  [!] WinRM service is stopped

============================================================
```

## Hints

- Use `Clear-Host` for refresh effect
- Use `Write-Host` with `-NoNewline` for progress bars
- Use a `do-while` loop with `Start-Sleep` for auto-refresh
- Use `[Console]::CursorVisible = $false` for cleaner display
