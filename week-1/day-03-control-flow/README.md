# Day 3 — Control Flow

Control flow determines which code runs and how many times. Today you learn conditional logic, loops, and pipeline filtering — the tools that make scripts do real work.

---

## Video Resources

- [PowerShell If Else and Switch](https://www.youtube.com/watch?v=2UH3MUKsFn8)
- [PowerShell for Beginners Playlist](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) — Episodes 7-9

---

## 1. if / elseif / else

The most basic decision-making structure.

```powershell
$diskUsage = 87

if ($diskUsage -ge 90) {
    Write-Host "CRITICAL: Disk usage is $diskUsage%" -ForegroundColor Red
} elseif ($diskUsage -ge 75) {
    Write-Host "WARNING: Disk usage is $diskUsage%" -ForegroundColor Yellow
} else {
    Write-Host "OK: Disk usage is $diskUsage%" -ForegroundColor Green
}
```

Real-world example — checking if a service is running:

```powershell
$service = Get-Service -Name "wuauserv" -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Output "Service not found"
} elseif ($service.Status -eq "Running") {
    Write-Output "Windows Update service is running"
} else {
    Write-Output "Windows Update service is stopped — starting it..."
    Start-Service -Name "wuauserv"
}
```

**Tip:** When comparing to `$null`, always put `$null` on the left side: `$null -eq $var`. This avoids unexpected behavior when `$var` is a collection.

## 2. switch

Use `switch` when you have many possible values to check. It replaces long `if/elseif` chains.

```powershell
$dayOfWeek = (Get-Date).DayOfWeek

switch ($dayOfWeek) {
    "Monday"    { Write-Output "Start of the work week" }
    "Friday"    { Write-Output "Almost weekend" }
    "Saturday"  { Write-Output "Weekend" }
    "Sunday"    { Write-Output "Weekend" }
    default     { Write-Output "Midweek grind" }
}
```

### Wildcard and Regex Switch

```powershell
$serverName = "web-prod-03"

# Wildcard matching
switch -Wildcard ($serverName) {
    "web-*"  { Write-Output "This is a web server" }
    "db-*"   { Write-Output "This is a database server" }
    "*-prod-*" { Write-Output "This is a production server" }
    "*-dev-*"  { Write-Output "This is a development server" }
}
# Note: multiple matches can fire — both "web-*" and "*-prod-*" match
```

## 3. for Loop

The classic counter-based loop. Use when you need an index or a specific number of iterations.

```powershell
# Count from 1 to 10
for ($i = 1; $i -le 10; $i++) {
    Write-Output "Iteration $i"
}

# Countdown
for ($i = 5; $i -gt 0; $i--) {
    Write-Output "$i..."
}
Write-Output "Go!"
```

## 4. foreach Loop

The most common loop in PowerShell. Iterates over every item in a collection.

```powershell
# foreach statement
$servers = @("web01", "web02", "db01", "app01")
foreach ($server in $servers) {
    Write-Output "Pinging $server..."
}
```

### foreach vs ForEach-Object (Pipeline)

These look similar but work differently:

```powershell
# foreach STATEMENT — loads entire collection into memory first
foreach ($proc in Get-Process) {
    Write-Output $proc.Name
}

# ForEach-Object CMDLET — processes one item at a time through pipeline
# Uses $_ for the current item
Get-Process | ForEach-Object {
    Write-Output $_.Name
}
```

**When to use which:**
- `foreach` statement — faster for in-memory collections
- `ForEach-Object` pipeline — better for large datasets (streams, lower memory)

## 5. while and do-while

### while — checks condition FIRST

```powershell
# Retry logic: keep trying until success or max attempts
$attempt = 0
$maxAttempts = 3
$success = $false

while (-not $success -and $attempt -lt $maxAttempts) {
    $attempt++
    Write-Output "Attempt $attempt of $maxAttempts..."

    # Simulate a check (replace with real logic)
    if ($attempt -eq 3) {
        $success = $true
        Write-Output "Success on attempt $attempt"
    }
}
```

### do-while — runs at LEAST once, then checks condition

```powershell
# Menu system
do {
    Write-Host "`n===== Server Admin Menu =====" -ForegroundColor Cyan
    Write-Host "1. List processes"
    Write-Host "2. Check disk space"
    Write-Host "3. List services"
    Write-Host "Q. Quit"

    $choice = Read-Host "Select an option"

    switch ($choice) {
        "1" { Get-Process | Select-Object -First 5 Name, CPU }
        "2" { Get-PSDrive -PSProvider FileSystem }
        "3" { Get-Service | Where-Object Status -eq "Running" | Select-Object -First 5 }
        "Q" { Write-Host "Goodbye!" }
        default { Write-Host "Invalid option" -ForegroundColor Red }
    }
} while ($choice -ne "Q")
```

## 6. break and continue

```powershell
# break — exit the loop entirely
foreach ($num in 1..100) {
    if ($num -gt 5) { break }
    Write-Output $num
}
# Output: 1, 2, 3, 4, 5

# continue — skip to the next iteration
foreach ($num in 1..10) {
    if ($num % 2 -eq 0) { continue }  # Skip even numbers
    Write-Output $num
}
# Output: 1, 3, 5, 7, 9
```

## 7. Pipeline Filtering with Where-Object

`Where-Object` is the pipeline equivalent of an `if` statement. It filters objects based on a condition.

```powershell
# Long form (script block)
Get-Service | Where-Object { $_.Status -eq "Running" }

# Short form (comparison)
Get-Service | Where-Object Status -eq "Running"

# Combining conditions
Get-Process | Where-Object { $_.CPU -gt 10 -and $_.WorkingSet64 -gt 100MB }

# Compare: loop + if vs pipeline
# Loop approach:
foreach ($svc in Get-Service) {
    if ($svc.Status -eq "Running") {
        Write-Output $svc.DisplayName
    }
}

# Pipeline approach (same result, more PowerShell-idiomatic):
Get-Service | Where-Object Status -eq "Running" | Select-Object DisplayName
```

The pipeline approach is more concise and considered "the PowerShell way."

---

## Key Takeaways

1. Use `if/elseif/else` for simple conditions, `switch` for many possible values
2. `foreach` is the most common loop — use it for iterating collections
3. `do-while` guarantees at least one execution (great for menus)
4. `while` with retry logic is common in DevOps scripts
5. `Where-Object` is the pipeline version of `if` — use it for filtering
6. `break` exits a loop, `continue` skips to the next iteration

---

## Interview Prep

**Q: What is the difference between foreach and ForEach-Object?**
A: `foreach` is a language statement that loads the entire collection into memory before iterating — it is faster for small collections. `ForEach-Object` is a cmdlet that processes items one at a time through the pipeline using `$_` — it uses less memory for large datasets and integrates with the pipeline.

**Q: When would you use a do-while loop instead of a while loop?**
A: Use `do-while` when you need the code to execute at least once before checking the condition. Common examples: menu systems (show the menu before checking the choice) and user input validation (ask for input before checking if it is valid).

**Q: How do you filter objects in a PowerShell pipeline?**
A: Use `Where-Object` (alias: `where` or `?`). It takes a script block with a condition: `Get-Process | Where-Object { $_.CPU -gt 100 }`. For simple property comparisons, use the short form: `Get-Service | Where-Object Status -eq "Running"`.
