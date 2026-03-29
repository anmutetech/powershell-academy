# =============================================================================
# Day 5 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Directory Inventory ---
Write-Host "=== Exercise 1: Directory Inventory ===" -ForegroundColor Cyan

function Get-DirectoryInventory {
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Path
    )

    $items = Get-ChildItem -Path $Path -Recurse -ErrorAction SilentlyContinue
    $files = $items | Where-Object { -not $_.PSIsContainer }
    $folders = $items | Where-Object { $_.PSIsContainer }

    $largest = $files | Sort-Object Length -Descending | Select-Object -First 1
    $extensions = $files | Group-Object Extension | Sort-Object Count -Descending | Select-Object -First 1
    $recent = $files | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) }

    [PSCustomObject]@{
        Path             = $Path
        FileCount        = $files.Count
        FolderCount      = $folders.Count
        TotalSizeMB      = [math]::Round(($files | Measure-Object Length -Sum).Sum / 1MB, 2)
        LargestFile      = "$($largest.Name) ($([math]::Round($largest.Length / 1KB, 1)) KB)"
        CommonExtension  = "$($extensions.Name) ($($extensions.Count) files)"
        RecentlyModified = $recent.Count
    }
}

Get-DirectoryInventory -Path $env:TEMP | Format-List

# --- Exercise 2: CSV Data Processor ---
Write-Host "=== Exercise 2: CSV Data Processor ===" -ForegroundColor Cyan

# Create sample CSV
$csvPath = Join-Path $env:TEMP "employees-ex5.csv"
@(
    [PSCustomObject]@{ Name="Alice"; Email="alice@co.com"; Department="IT"; Salary=85000 }
    [PSCustomObject]@{ Name="Bob"; Email="bob@co.com"; Department="HR"; Salary=72000 }
    [PSCustomObject]@{ Name="Charlie"; Email="charlie@co.com"; Department="IT"; Salary=92000 }
    [PSCustomObject]@{ Name="Diana"; Email="diana@co.com"; Department="Finance"; Salary=78000 }
    [PSCustomObject]@{ Name="Eve"; Email="eve@co.com"; Department="IT"; Salary=88000 }
    [PSCustomObject]@{ Name="Frank"; Email="frank@co.com"; Department="HR"; Salary=65000 }
) | Export-Csv -Path $csvPath -NoTypeInformation

$employees = Import-Csv $csvPath
$highest = $employees | Sort-Object { [int]$_.Salary } -Descending | Select-Object -First 1
Write-Output "Highest paid: $($highest.Name) - `$$($highest.Salary)"

Write-Host "`nAverage salary by department:" -ForegroundColor Yellow
$employees | Group-Object Department | ForEach-Object {
    $avg = ($_.Group | ForEach-Object { [int]$_.Salary } | Measure-Object -Average).Average
    Write-Output "  $($_.Name): `$$('{0:N0}' -f $avg)"
}

$outputCsv = Join-Path $env:TEMP "high-earners.csv"
$employees | Where-Object { [int]$_.Salary -gt 80000 } | Export-Csv -Path $outputCsv -NoTypeInformation
Write-Output "`nExported high earners to: $outputCsv"

# --- Exercise 3: Log Analyzer ---
Write-Host "`n=== Exercise 3: Log Analyzer ===" -ForegroundColor Cyan

$logPath = Join-Path $env:TEMP "sample-app.log"
@(
    "2026-03-15 08:00:00 INFO  Server started on port 443",
    "2026-03-15 08:05:12 INFO  User login from 192.168.1.10",
    "2026-03-15 09:15:30 WARN  High CPU usage at 89%",
    "2026-03-15 10:10:45 ERROR Connection to 10.0.2.5 refused",
    "2026-03-15 10:20:00 INFO  Backup started from 172.16.0.1",
    "2026-03-15 11:30:00 ERROR Disk write failure on /var/data",
    "2026-03-15 12:00:00 INFO  Health check OK"
) | Set-Content -Path $logPath

$logLines = Get-Content $logPath

# Count by level
$levels = $logLines | ForEach-Object {
    if ($_ -match "\d{2}:\d{2}:\d{2}\s(\w+)") { $Matches[1] }
} | Group-Object | Select-Object Name, Count
Write-Output "Log Levels:"
$levels | ForEach-Object { Write-Output "  $($_.Name): $($_.Count)" }

# Extract IPs
$ips = ($logLines | Select-String -Pattern "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}" -AllMatches).Matches.Value | Sort-Object -Unique
Write-Output "`nUnique IPs: $($ips -join ', ')"

# Time range
$timestamps = $logLines | ForEach-Object {
    if ($_ -match "^(\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2})") { $Matches[1] }
}
Write-Output "Time range: $($timestamps[0]) to $($timestamps[-1])"

# --- Exercise 4: Config File Editor ---
Write-Host "`n=== Exercise 4: Config File Editor ===" -ForegroundColor Cyan

function Update-Config {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Key,

        $Value
    )

    # Backup
    $backupPath = "$Path.bak"
    Copy-Item -Path $Path -Destination $backupPath -Force
    Write-Verbose "Backup created: $backupPath"

    $config = Get-Content -Path $Path -Raw | ConvertFrom-Json

    # Navigate nested keys
    $keys = $Key.Split(".")
    $obj = $config
    for ($i = 0; $i -lt $keys.Count - 1; $i++) {
        $obj = $obj.($keys[$i])
    }

    $finalKey = $keys[-1]
    $oldValue = $obj.$finalKey

    if ($PSCmdlet.ShouldProcess("$Key: $oldValue -> $Value", "Update config")) {
        $obj.$finalKey = $Value
        $config | ConvertTo-Json -Depth 5 | Set-Content -Path $Path
        Write-Output "Updated $Key from '$oldValue' to '$Value'"
    }
}

$configPath = Join-Path $env:TEMP "test-config.json"
@{ database = @{ host = "localhost"; port = 5432 }; app = @{ debug = $false } } |
    ConvertTo-Json -Depth 3 | Set-Content $configPath

Update-Config -Path $configPath -Key "database.port" -Value 3306 -Verbose

# --- Exercise 5: Bulk File Renamer ---
Write-Host "`n=== Exercise 5: Bulk File Renamer ===" -ForegroundColor Cyan

function Rename-BulkFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Pattern,

        [Parameter(Mandatory)]
        [string]$Replacement
    )

    $files = Get-ChildItem -Path $Path -File | Where-Object { $_.Name -match $Pattern }

    foreach ($file in $files) {
        $newName = $file.Name -replace $Pattern, $Replacement
        if ($newName -ne $file.Name) {
            if ($PSCmdlet.ShouldProcess("$($file.Name) -> $newName", "Rename")) {
                Rename-Item -Path $file.FullName -NewName $newName
            }
        }
    }
}

# Demo with WhatIf
$renameDir = Join-Path $env:TEMP "rename-demo"
New-Item -Path $renameDir -ItemType Directory -Force | Out-Null
"" | Set-Content (Join-Path $renameDir "IMG_20260315_001.jpg")
"" | Set-Content (Join-Path $renameDir "IMG_20260315_002.jpg")
"" | Set-Content (Join-Path $renameDir "IMG_20260316_001.jpg")

Rename-BulkFiles -Path $renameDir -Pattern "IMG_(\d{4})(\d{2})(\d{2})_(\d+)" -Replacement '$1-$2-$3_$4' -WhatIf

# Cleanup
Remove-Item $csvPath, $logPath, $configPath, "$configPath.bak", $outputCsv, $renameDir -Recurse -Force -ErrorAction SilentlyContinue
