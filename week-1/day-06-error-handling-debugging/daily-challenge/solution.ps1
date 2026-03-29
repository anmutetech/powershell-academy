# =============================================================================
# Day 6 Daily Challenge — Resilient File Processor (Solution)
# =============================================================================

Write-Host "===== File Processor =====" -ForegroundColor Cyan

$logFile = Join-Path $PSScriptRoot "processing.log"

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] $Message"
    Add-Content -Path $logFile -Value $entry

    $color = switch ($Level) {
        "INFO"    { "White" }
        "WARN"    { "Yellow" }
        "ERROR"   { "Red" }
        "SUCCESS" { "Green" }
    }
    Write-Host $entry -ForegroundColor $color
}

# Create sample data directory with test files
$inputDir = Join-Path $PSScriptRoot "sample-data"
New-Item -Path $inputDir -ItemType Directory -Force | Out-Null

# Create test files
@(
    [PSCustomObject]@{Name="Alice";Dept="IT";Salary=85000}
    [PSCustomObject]@{Name="Bob";Dept="HR";Salary=72000}
    [PSCustomObject]@{Name="Charlie";Dept="IT";Salary=92000}
) | Export-Csv -Path (Join-Path $inputDir "users.csv") -NoTypeInformation

@{app="MediTrack"; version="2.0"; settings=@{debug=$false; port=8080}} |
    ConvertTo-Json -Depth 3 | Set-Content (Join-Path $inputDir "config.json")

"Name,Dept`nAlice,IT`nBad Line Missing Column" | Set-Content (Join-Path $inputDir "partial.csv")
"" | Set-Content (Join-Path $inputDir "empty.json")
"{ invalid json }" | Set-Content (Join-Path $inputDir "broken.json")

# Start processing
Write-Log "Starting file processor"
Write-Log "Scanning: $inputDir"

if (-not (Test-Path $inputDir -PathType Container)) {
    Write-Log "Directory not found: $inputDir" -Level "ERROR"
    throw "Input directory does not exist: $inputDir"
}

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$files = Get-ChildItem -Path $inputDir -Include "*.csv", "*.json" -File -Recurse
$results = @()
$successCount = 0
$failCount = 0

Write-Host ""
foreach ($file in $files) {
    $status = "OK"
    $detail = ""

    try {
        # Check empty
        if ($file.Length -eq 0) {
            throw "File is empty"
        }

        $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop

        switch ($file.Extension.ToLower()) {
            ".csv" {
                $records = Import-Csv -Path $file.FullName -ErrorAction Stop
                $count = @($records).Count
                $detail = "$count records"
            }
            ".json" {
                $parsed = $content | ConvertFrom-Json -ErrorAction Stop
                $props = ($parsed | Get-Member -MemberType NoteProperty).Count
                $detail = "$props properties"
            }
        }

        $successCount++
        Write-Log "Processed: $($file.Name) - $detail" -Level "SUCCESS"
    }
    catch {
        $status = "FAIL"
        $detail = $_.Exception.Message
        $failCount++
        Write-Log "Failed: $($file.Name) - $detail" -Level "ERROR"
    }

    $results += [PSCustomObject]@{
        FileName = $file.Name
        Status   = $status
        Detail   = $detail
    }
}

$stopwatch.Stop()

# Summary
Write-Host "`n===== Summary =====" -ForegroundColor Cyan
Write-Host "Total Files:  $($files.Count)"
Write-Host "Successful:   $successCount" -ForegroundColor Green
Write-Host "Failed:       $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host ("Duration:     {0:N2} seconds" -f $stopwatch.Elapsed.TotalSeconds)

$failed = $results | Where-Object Status -eq "FAIL"
if ($failed) {
    Write-Host "`nFailed Files:" -ForegroundColor Red
    foreach ($f in $failed) {
        Write-Host "  - $($f.FileName): $($f.Detail)" -ForegroundColor Red
    }
}

Write-Log "Processing complete. $successCount/$($files.Count) successful in $($stopwatch.Elapsed.TotalSeconds)s"
Write-Host "`nLog saved to: $logFile" -ForegroundColor Gray

# Cleanup sample data
Remove-Item $inputDir -Recurse -Force -ErrorAction SilentlyContinue
