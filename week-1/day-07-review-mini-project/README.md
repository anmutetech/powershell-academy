# Day 7 — Review & Week 1 Capstone Project

Congratulations on completing Week 1! Today you review everything you've learned and build a real-world project that combines all the skills from Days 1-6.

---

## Video Resources

- [PowerShell Scripting Best Practices](https://www.youtube.com/watch?v=H0MkZd0RYDc)
- [Building Real PowerShell Tools](https://www.youtube.com/watch?v=jVeFO4YiIhI)

---

## Week 1 Review

### Day 1: Getting Started
- PowerShell is built on .NET — it works with **objects**, not text
- Core discovery: `Get-Help`, `Get-Command`, `Get-Member`
- Pipeline: `|` passes objects between commands

### Day 2: Variables, Types, Operators
- Variables start with `$`; PowerShell is dynamically typed
- Arrays `@()`, Hashtables `@{}`
- Comparison: `-eq`, `-ne`, `-gt`, `-lt`, `-like`, `-match`

### Day 3: Control Flow
- `if/elseif/else`, `switch` (with `-Wildcard` and script blocks)
- `for`, `foreach`, `while`, `do-while`
- `Where-Object` for pipeline filtering

### Day 4: Functions & Modules
- `param()` blocks, `[CmdletBinding()]`, validation attributes
- `ValueFromPipeline` with `begin/process/end`
- Modules (`.psm1` files)

### Day 5: File System & Text Processing
- `Get-ChildItem`, `Get-Content`, `Set-Content`
- `Import-Csv`, `Export-Csv`, `ConvertFrom-Json`, `ConvertTo-Json`
- `-match`, `-replace`, `Select-String` for regex

### Day 6: Error Handling & Debugging
- `try/catch/finally`, `-ErrorAction Stop`
- Typed catch blocks, `throw`, `$Error`
- Logging functions, `Write-Debug`, `Write-Verbose`

---

## Capstone Project: Server Inventory & Health Dashboard

### Overview

Build an **Automated Server Inventory Tool** that collects system information, checks health metrics, and generates both a console dashboard and exportable reports.

This project uses every skill from Week 1.

### Requirements

#### 1. Data Collection Functions
Create functions that gather:
- **System Info**: Computer name, OS, PowerShell version, uptime
- **Disk Info**: Drive letter, total/used/free space, percent used
- **Process Info**: Top N processes by CPU and memory
- **Service Info**: Status of specified services

Each function must:
- Use `[CmdletBinding()]` and `param()` blocks
- Return `[PSCustomObject]` data
- Support `-Verbose` output
- Handle errors with `try/catch`

#### 2. Health Checks
Implement threshold-based health checking:
- Disk usage: >90% Critical, >75% Warning
- Memory usage: >90% Critical, >80% Warning
- CPU usage: >90% Critical, >70% Warning

Use `switch` or `if/elseif/else` for status determination.

#### 3. Console Dashboard
Display a color-coded dashboard:
- Green = Healthy, Yellow = Warning, Red = Critical
- Formatted tables for processes and services
- Summary section with overall health status

#### 4. Report Export
Export data in multiple formats:
- CSV file with all collected data
- JSON file with structured results
- Text file with the dashboard output

#### 5. Logging
Log all operations to a timestamped log file:
- Start/end times
- Each data collection step
- Any errors encountered
- Summary statistics

### Starter Code

See `daily-challenge/starter.ps1` for the project skeleton.

### Example Output

```
================================================================
        SERVER INVENTORY & HEALTH DASHBOARD
        Generated: 2026-03-29 14:30:00
================================================================

SYSTEM INFORMATION
  Computer:     WORKSTATION-01
  OS:           Microsoft Windows 11 Pro
  PS Version:   7.4.1
  Uptime:       5 days, 3 hours

DISK HEALTH
  Drive  Total GB  Used GB  Free GB  Usage%  Status
  -----  --------  -------  -------  ------  ------
  C:     500.00    225.50   274.50   45.1%   [OK]
  D:     1000.00   875.00   125.00   87.5%   [WARNING]

MEMORY
  Total: 16.00 GB | Used: 12.80 GB | Free: 3.20 GB | Usage: 80.0% [WARNING]

TOP 5 PROCESSES (by CPU)
  Name              CPU      Memory MB
  ----              ---      ---------
  chrome            125.3    1,024
  code              89.7     512
  ...

SERVICE STATUS
  Name          Status    StartType
  ----          ------    ---------
  Spooler       Running   Automatic
  W32Time       Stopped   Manual
  ...

OVERALL STATUS: WARNING
  1 disk warning, memory at 80%

================================================================
Reports saved to:
  CSV:  ./reports/inventory-2026-03-29.csv
  JSON: ./reports/inventory-2026-03-29.json
  Log:  ./reports/inventory-2026-03-29.log
================================================================
```

---

## Grading Yourself

| Criteria | Points |
|----------|--------|
| Functions with CmdletBinding and validation | 20 |
| Proper error handling (try/catch) | 20 |
| Health check logic (if/switch) | 15 |
| Console output with color coding | 15 |
| Export to CSV and JSON | 15 |
| Logging | 10 |
| Code organization and comments | 5 |
| **Total** | **100** |

---

## Looking Ahead: Week 2

Next week takes everything you've learned and applies it to real enterprise scenarios:

- **Day 8**: Active Directory automation
- **Day 9**: Windows Server administration
- **Day 10**: Azure PowerShell
- **Day 11**: Azure Automation & DevOps
- **Day 12**: Security & Compliance
- **Day 13**: CI/CD & Infrastructure as Code
- **Day 14**: Final Capstone Project
