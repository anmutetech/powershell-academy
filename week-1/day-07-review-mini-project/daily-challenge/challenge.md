# Day 7 — Capstone Project: Server Inventory & Health Dashboard

## The Task

Build a complete server inventory and health monitoring tool using every skill from Week 1.

## Requirements

See the main README.md for full requirements. Summary:

1. **Data Collection** — Functions for system info, disk, processes, services
2. **Health Checks** — Threshold-based status (OK/Warning/Critical)
3. **Console Dashboard** — Color-coded, formatted output
4. **Report Export** — CSV, JSON, and text files
5. **Logging** — Timestamped log of all operations

## Acceptance Criteria

- [ ] At least 4 functions with `[CmdletBinding()]`
- [ ] All functions return `[PSCustomObject]`
- [ ] `try/catch` around every external operation
- [ ] Color-coded console output
- [ ] Working CSV export
- [ ] Working JSON export
- [ ] Log file with timestamps
- [ ] Clean, commented code

## Time Estimate

This should take 1-2 hours. Start with the data collection functions, then add the dashboard, then exports.

## Tips

- Build one function at a time and test it
- Use `Write-Verbose` liberally during development
- Don't try to make it perfect on the first pass
- The starter file has the full structure — fill in the TODOs
