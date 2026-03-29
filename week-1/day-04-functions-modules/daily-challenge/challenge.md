# Day 4 — Daily Challenge: Server Health Check Toolkit

## The Task

Build a collection of reusable functions that form a mini server health check toolkit.

## Requirements

Create three advanced functions:

### 1. `Get-SystemHealth`
- Returns CPU usage, memory usage (% used), and disk usage (% used)
- Returns a `[PSCustomObject]` with ComputerName, CPUPercent, MemoryPercent, DiskPercent, Status
- Status: "Healthy" if all < 80%, "Warning" if any >= 80%, "Critical" if any >= 95%

### 2. `Test-PortConnection`
- Takes `-ComputerName` and `-Port` parameters
- `-Port` should use `[ValidateRange(1, 65535)]`
- Tests if the port is open using `Test-NetConnection` or `System.Net.Sockets.TcpClient`
- Returns a `[PSCustomObject]` with ComputerName, Port, IsOpen, ResponseTime

### 3. `Get-HealthReport`
- Calls `Get-SystemHealth` and outputs a formatted report
- Uses color coding: Green for Healthy, Yellow for Warning, Red for Critical
- Accepts pipeline input for multiple computer names

## Example Output

```
===== Server Health Report =====

Computer: WORKSTATION-01
  CPU:    23%  [OK]
  Memory: 67%  [OK]
  Disk:   45%  [OK]
  Status: Healthy

Port Check:
  localhost:80   - OPEN
  localhost:443  - CLOSED
  localhost:22   - CLOSED
```

## Hints

- Use `Get-CimInstance Win32_Processor` for CPU
- Use `Get-CimInstance Win32_OperatingSystem` for memory
- Use `Get-PSDrive` for disk info
- Wrap `Test-NetConnection` in a try/catch for robustness
