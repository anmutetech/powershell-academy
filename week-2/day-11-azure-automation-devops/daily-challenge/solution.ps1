# =============================================================================
# Day 11 Daily Challenge — CI/CD Pipeline Simulator (Solution)
# =============================================================================

Write-Host "===== CI/CD Pipeline Simulator =====" -ForegroundColor Cyan

# Pipeline config
$pipeline = @{
    Name    = "MediTrack-Deploy"
    Trigger = "main"
    Stages  = @(
        @{Name="checkout"; Type="build"; DependsOn=@(); Duration=500}
        @{Name="restore"; Type="build"; DependsOn=@("checkout"); Duration=800}
        @{Name="build"; Type="build"; DependsOn=@("restore"); Duration=1200}
        @{Name="unit-tests"; Type="test"; DependsOn=@("build"); Duration=2000}
        @{Name="security-scan"; Type="test"; DependsOn=@("build"); Duration=1500}
        @{Name="deploy-staging"; Type="deploy"; DependsOn=@("unit-tests","security-scan"); Duration=3000}
        @{Name="smoke-tests"; Type="test"; DependsOn=@("deploy-staging"); Duration=1000}
        @{Name="deploy-production"; Type="deploy"; DependsOn=@("smoke-tests"); Duration=3000}
    )
}

function Invoke-Stage {
    param(
        [hashtable]$Stage,
        [int]$MaxRetries = 2
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $attempt = 0
    $success = $false
    $output = ""

    while ($attempt -lt $MaxRetries -and -not $success) {
        $attempt++
        try {
            # Simulate work
            Start-Sleep -Milliseconds ([math]::Min($Stage.Duration, 500))
            $success = $true
            $output = "Completed successfully"
        } catch {
            $output = $_.Exception.Message
        }
    }

    $sw.Stop()

    [PSCustomObject]@{
        Name     = $Stage.Name
        Type     = $Stage.Type
        Status   = if ($success) { "Passed" } else { "Failed" }
        Duration = $sw.ElapsedMilliseconds
        Attempts = $attempt
        Output   = $output
    }
}

function Send-Notification {
    param([string]$Pipeline, [string]$Status, [string]$Duration)

    Write-Host "`n  Webhook notification:" -ForegroundColor Gray
    $payload = @{
        pipeline = $Pipeline
        status   = $Status
        duration = $Duration
        time     = (Get-Date -Format "o")
    } | ConvertTo-Json -Compress
    Write-Host "  POST https://hooks.example.com/pipeline -> $payload" -ForegroundColor Gray
}

# --- Pipeline Engine ---
$pipelineSw = [System.Diagnostics.Stopwatch]::StartNew()
$completed = @{}
$results = @()
$remaining = [System.Collections.ArrayList]@($pipeline.Stages)

Write-Host "`nPipeline: $($pipeline.Name)" -ForegroundColor Cyan
Write-Host "Trigger:  $($pipeline.Trigger)`n"

$failed = $false

while ($remaining.Count -gt 0 -and -not $failed) {
    $ready = $remaining | Where-Object {
        $deps = $_.DependsOn
        ($deps | Where-Object { -not $completed.ContainsKey($_) }).Count -eq 0
    }

    if (-not $ready) {
        Write-Host "DEADLOCK: No stages ready but $($remaining.Count) remaining" -ForegroundColor Red
        break
    }

    foreach ($stage in $ready) {
        $icon = switch ($stage.Type) { "build" {"B"}; "test" {"T"}; "deploy" {"D"} }
        Write-Host "  [$icon] $($stage.Name)" -NoNewline

        $result = Invoke-Stage -Stage $stage
        $results += $result

        if ($result.Status -eq "Passed") {
            Write-Host " PASSED ($($result.Duration)ms)" -ForegroundColor Green
            $completed[$stage.Name] = $true
        } else {
            Write-Host " FAILED" -ForegroundColor Red
            if ($stage.Type -eq "deploy") {
                Write-Host "      Critical deploy stage failed — stopping pipeline" -ForegroundColor Red
                $failed = $true
                break
            }
            $completed[$stage.Name] = $false
        }

        $remaining.Remove($stage) | Out-Null
    }
}

$pipelineSw.Stop()

# --- Report ---
$passCount = ($results | Where-Object Status -eq "Passed").Count
$failCount = ($results | Where-Object Status -eq "Failed").Count
$totalStatus = if ($failCount -eq 0 -and $remaining.Count -eq 0) { "SUCCESS" } else { "FAILED" }
$statusColor = if ($totalStatus -eq "SUCCESS") { "Green" } else { "Red" }

Write-Host "`n===== Pipeline Report =====" -ForegroundColor Cyan
Write-Host "Pipeline:  $($pipeline.Name)"
Write-Host "Status:    $totalStatus" -ForegroundColor $statusColor
Write-Host "Duration:  $([math]::Round($pipelineSw.Elapsed.TotalSeconds, 2))s"
Write-Host "Stages:    $passCount passed, $failCount failed, $($remaining.Count) skipped"

Write-Host "`nStage Details:" -ForegroundColor Yellow
$results | ForEach-Object {
    $c = if ($_.Status -eq "Passed") { "Green" } else { "Red" }
    Write-Host ("  {0,-25} {1,-8} {2,6}ms  [{3}]" -f $_.Name, $_.Status, $_.Duration, $_.Type) -ForegroundColor $c
}

if ($remaining.Count -gt 0) {
    Write-Host "`nSkipped stages:" -ForegroundColor Yellow
    $remaining | ForEach-Object { Write-Host "  $($_.Name) (deps: $($_.DependsOn -join ', '))" -ForegroundColor Gray }
}

# Notification
Send-Notification -Pipeline $pipeline.Name -Status $totalStatus -Duration "$([math]::Round($pipelineSw.Elapsed.TotalSeconds, 1))s"

# Export report
$reportPath = Join-Path $PSScriptRoot "pipeline-report-$(Get-Date -Format 'yyyy-MM-dd').json"
@{
    Pipeline = $pipeline.Name
    Status = $totalStatus
    Duration = $pipelineSw.Elapsed.TotalSeconds
    Stages = $results
    Skipped = $remaining | ForEach-Object { $_.Name }
} | ConvertTo-Json -Depth 5 | Set-Content -Path $reportPath
Write-Host "`nReport saved: $reportPath" -ForegroundColor Gray
