# Day 5 — File System & Text Processing

Working with files is one of the most common tasks in IT automation. Today you learn to navigate the file system, read and write files, parse CSV/JSON data, and process text with regex.

---

## Video Resources

- [PowerShell File Management](https://www.youtube.com/watch?v=MBjFTwKOGBA)
- [PowerShell Regex](https://www.youtube.com/watch?v=sINfz2S8jas)
- [PowerShell for Beginners Playlist](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) — Episodes 12-14

---

## 1. File System Navigation

PowerShell uses the same cmdlets for files, registry, certificates, and more — they're all "providers."

```powershell
# Current location
Get-Location           # Like pwd
Set-Location C:\Users  # Like cd

# List items
Get-ChildItem                     # Like ls or dir
Get-ChildItem -Recurse -File      # All files recursively
Get-ChildItem -Filter "*.log"     # Wildcard filter
Get-ChildItem -Path C:\Logs -Include "*.log", "*.txt" -Recurse

# Test if path exists
Test-Path "C:\Temp\myfile.txt"           # True/False
Test-Path "C:\Temp" -PathType Container  # Is it a folder?
Test-Path "C:\Temp\myfile.txt" -PathType Leaf  # Is it a file?
```

## 2. Creating, Copying, Moving, Deleting

```powershell
# Create
New-Item -Path "C:\Temp\Scripts" -ItemType Directory
New-Item -Path "C:\Temp\test.txt" -ItemType File -Value "Hello World"

# Copy
Copy-Item -Path ".\report.txt" -Destination ".\backup\report.txt"
Copy-Item -Path ".\logs\*" -Destination ".\archive\" -Recurse

# Move
Move-Item -Path ".\old-report.txt" -Destination ".\archive\"

# Rename
Rename-Item -Path ".\report.txt" -NewName "report-2026.txt"

# Delete
Remove-Item -Path ".\temp-file.txt"
Remove-Item -Path ".\old-logs" -Recurse -Force  # Delete folder and contents
```

## 3. Reading Files

```powershell
# Read entire file as string
$content = Get-Content -Path ".\config.txt" -Raw

# Read as array of lines
$lines = Get-Content -Path ".\config.txt"
$lines.Count   # Number of lines
$lines[0]      # First line
$lines[-1]     # Last line

# Read first/last N lines
Get-Content -Path ".\log.txt" -Head 10   # First 10 lines
Get-Content -Path ".\log.txt" -Tail 20   # Last 20 lines

# Read with encoding
Get-Content -Path ".\data.txt" -Encoding UTF8

# Tail a log file (like tail -f)
Get-Content -Path ".\app.log" -Tail 10 -Wait
```

## 4. Writing Files

```powershell
# Write (overwrite)
"Hello World" | Set-Content -Path ".\output.txt"

# Write multiple lines
@("Line 1", "Line 2", "Line 3") | Set-Content -Path ".\output.txt"

# Append
"New line" | Add-Content -Path ".\log.txt"

# Write object data
Get-Process | Select-Object Name, CPU | Out-File -Path ".\processes.txt"

# Write with encoding
"Data" | Set-Content -Path ".\output.txt" -Encoding UTF8
```

## 5. CSV Files

CSV is the most common data exchange format in IT.

```powershell
# Import CSV
$users = Import-Csv -Path ".\users.csv"
$users | Format-Table

# Access properties
foreach ($user in $users) {
    Write-Output "$($user.Name) - $($user.Department)"
}

# Filter CSV data
$itUsers = Import-Csv ".\users.csv" | Where-Object Department -eq "IT"

# Export to CSV
Get-Process | Select-Object Name, CPU, WorkingSet64 |
    Export-Csv -Path ".\processes.csv" -NoTypeInformation

# Append to CSV
$newRow = [PSCustomObject]@{ Name = "NewUser"; Department = "IT" }
$newRow | Export-Csv -Path ".\users.csv" -Append -NoTypeInformation
```

## 6. JSON Files

JSON is common for APIs and configuration files.

```powershell
# Read JSON
$config = Get-Content -Path ".\config.json" -Raw | ConvertFrom-Json
$config.database.host    # Access nested properties

# Create JSON
$data = @{
    name    = "web-server-01"
    env     = "production"
    ports   = @(80, 443, 8080)
    enabled = $true
}
$data | ConvertTo-Json | Set-Content -Path ".\server.json"

# Pretty JSON with depth
$data | ConvertTo-Json -Depth 5 | Set-Content ".\server.json"
```

## 7. String Operations & Regex

### Basic String Methods

```powershell
$text = "Hello, World! Hello, PowerShell!"

$text.ToUpper()                    # HELLO, WORLD! HELLO, POWERSHELL!
$text.ToLower()                    # hello, world! hello, powershell!
$text.Contains("World")            # True
$text.Replace("Hello", "Hi")       # Hi, World! Hi, PowerShell!
$text.Split(",")                   # Array: "Hello", " World!..."
$text.Trim()                       # Remove leading/trailing whitespace
$text.Substring(0, 5)              # Hello
```

### Regex with -match and -replace

```powershell
# -match (returns True/False, populates $Matches)
"Server: web-prod-01" -match "web-(\w+)-(\d+)"
$Matches[0]   # web-prod-01 (full match)
$Matches[1]   # prod (first group)
$Matches[2]   # 01 (second group)

# -replace (regex replacement)
"2026-03-15" -replace "(\d{4})-(\d{2})-(\d{2})", '$2/$3/$1'
# Output: 03/15/2026

# Select-String (like grep)
Get-Content ".\log.txt" | Select-String -Pattern "ERROR"
Get-ChildItem -Recurse -Filter "*.ps1" | Select-String -Pattern "Write-Host"
```

### Practical Regex: Log Parsing

```powershell
$logLine = "2026-03-15 14:30:22 ERROR [WebApp] Connection timeout to database server"

if ($logLine -match "^(\d{4}-\d{2}-\d{2})\s(\d{2}:\d{2}:\d{2})\s(\w+)\s\[(\w+)\]\s(.+)$") {
    [PSCustomObject]@{
        Date      = $Matches[1]
        Time      = $Matches[2]
        Level     = $Matches[3]
        Component = $Matches[4]
        Message   = $Matches[5]
    }
}
```

## 8. Path Manipulation

```powershell
# Join paths (cross-platform safe)
$fullPath = Join-Path -Path "C:\Users" -ChildPath "Documents\file.txt"

# Split path components
Split-Path "C:\Users\Admin\file.txt" -Parent    # C:\Users\Admin
Split-Path "C:\Users\Admin\file.txt" -Leaf       # file.txt

# Get file extension
[System.IO.Path]::GetExtension("report.csv")     # .csv
[System.IO.Path]::GetFileNameWithoutExtension("report.csv")  # report

# Resolve relative paths
Resolve-Path ".\scripts\*.ps1"
```

---

## Key Takeaways

1. `Get-ChildItem` is your file explorer — learn its parameters well
2. `Get-Content` reads files; `Set-Content`/`Add-Content` writes them
3. `Import-Csv` and `Export-Csv` are essential for data processing
4. `ConvertFrom-Json` / `ConvertTo-Json` for API and config data
5. `-match` with `$Matches` is powerful for extracting data from text
6. `Select-String` is PowerShell's grep — use it for searching file contents
7. Always use `Join-Path` instead of string concatenation for paths

---

## Interview Prep

**Q: How do you read and process a CSV file in PowerShell?**
A: Use `Import-Csv` which automatically creates objects from the CSV headers. Each row becomes an object where column headers are properties. You can then filter with `Where-Object`, sort with `Sort-Object`, and export back with `Export-Csv -NoTypeInformation`.

**Q: How do you search for text patterns across multiple files?**
A: Use `Select-String` which works like grep. Example: `Get-ChildItem -Recurse -Filter "*.log" | Select-String -Pattern "ERROR"`. It returns objects with filename, line number, and matching line.

**Q: What is the difference between Get-Content -Raw and Get-Content without -Raw?**
A: Without `-Raw`, `Get-Content` returns an array of strings (one per line). With `-Raw`, it returns the entire file as a single string. Use `-Raw` when you need to preserve line breaks or process the file as a whole (e.g., for JSON parsing with `ConvertFrom-Json`).
