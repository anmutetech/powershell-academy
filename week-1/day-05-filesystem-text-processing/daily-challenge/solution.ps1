# =============================================================================
# Day 5 Daily Challenge — Log File Analyzer (Solution)
# =============================================================================

Write-Host "===== Web Server Log Analysis =====" -ForegroundColor Cyan

$logFile = Join-Path $PSScriptRoot "access.log"
$logLines = Get-Content -Path $logFile

# Parse log entries
$entries = $logLines | ForEach-Object {
    if ($_ -match "\[(.+?)\]\s(\w+)\s(.+?)\sHTTP/\S+\s(\d+)\s(\d+)") {
        [PSCustomObject]@{
            Timestamp    = $Matches[1]
            Method       = $Matches[2]
            Path         = $Matches[3]
            StatusCode   = [int]$Matches[4]
            ResponseSize = [int]$Matches[5]
        }
    }
}

$total = $entries.Count
Write-Host "`nTotal Requests: $total"

# Status code breakdown
Write-Host "`nStatus Code Breakdown:" -ForegroundColor Yellow
$statusGroups = $entries | Group-Object StatusCode | Sort-Object Name
foreach ($group in $statusGroups) {
    $pct = [math]::Round(($group.Count / $total) * 100, 1)
    $color = if ([int]$group.Name -ge 500) { "Red" }
             elseif ([int]$group.Name -ge 400) { "Yellow" }
             else { "Green" }
    Write-Host ("  {0}: {1,3} ({2}%)" -f $group.Name, $group.Count, $pct) -ForegroundColor $color
}

# Top 5 URLs
Write-Host "`nTop 5 URLs:" -ForegroundColor Yellow
$urlGroups = $entries | Group-Object Path | Sort-Object Count -Descending | Select-Object -First 5
$rank = 1
foreach ($url in $urlGroups) {
    Write-Output ("  {0}. {1,-25} - {2} hits" -f $rank, $url.Name, $url.Count)
    $rank++
}

# Top 5 largest responses
Write-Host "`nTop 5 Largest Responses:" -ForegroundColor Yellow
$largest = $entries | Sort-Object ResponseSize -Descending | Select-Object -First 5
$rank = 1
foreach ($entry in $largest) {
    Write-Output ("  {0}. {1} {2,-25} - {3:N0} bytes (HTTP {4})" -f $rank, $entry.Method, $entry.Path, $entry.ResponseSize, $entry.StatusCode)
    $rank++
}

# Error rate
$errors = $entries | Where-Object { $_.StatusCode -ge 400 }
$errorRate = [math]::Round(($errors.Count / $total) * 100, 1)
$errorColor = if ($errorRate -gt 10) { "Red" } elseif ($errorRate -gt 5) { "Yellow" } else { "Green" }
Write-Host ("`nError Rate: {0}% ({1} errors out of {2} requests)" -f $errorRate, $errors.Count, $total) -ForegroundColor $errorColor

# Export to CSV
$csvOutput = Join-Path $PSScriptRoot "parsed-log.csv"
$entries | Export-Csv -Path $csvOutput -NoTypeInformation
Write-Output "`nData exported to: $csvOutput"

# Save report
$reportPath = Join-Path $PSScriptRoot "analysis-report.txt"
$report = @"
===== Web Server Log Analysis Report =====
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Total Requests: $total

Status Code Breakdown:
$($statusGroups | ForEach-Object { "  {0}: {1} ({2}%)" -f $_.Name, $_.Count, [math]::Round(($_.Count / $total) * 100, 1) } | Out-String)
Top 5 URLs:
$($urlGroups | ForEach-Object { "  {0} - {1} hits" -f $_.Name, $_.Count } | Out-String)
Error Rate: $errorRate% ($($errors.Count) errors out of $total requests)
"@

$report | Set-Content -Path $reportPath
Write-Output "Report saved to: $reportPath"

Write-Host "`nAnalysis complete." -ForegroundColor Cyan
