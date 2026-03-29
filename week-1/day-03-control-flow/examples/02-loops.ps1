# =============================================================================
# Day 3 — Loops (for, foreach, while, do-while)
# =============================================================================

# --- for loop: classic counter ---
Write-Host "=== Counting 1 to 5 ===" -ForegroundColor Cyan
for ($i = 1; $i -le 5; $i++) {
    Write-Output "Count: $i"
}

# --- for loop: countdown ---
Write-Host "`n=== Countdown ===" -ForegroundColor Cyan
for ($i = 3; $i -gt 0; $i--) {
    Write-Output "$i..."
}
Write-Output "Go!"

# --- foreach: iterate a collection ---
Write-Host "`n=== Server Ping Check ===" -ForegroundColor Cyan
$servers = @("web01", "web02", "db01", "app01")

foreach ($server in $servers) {
    Write-Output "Checking $server..."
}

# --- foreach vs ForEach-Object ---
Write-Host "`n=== ForEach-Object (Pipeline) ===" -ForegroundColor Cyan
$servers | ForEach-Object {
    Write-Output "Pipeline checking: $_"
}

# --- while loop: retry logic ---
Write-Host "`n=== Retry Logic ===" -ForegroundColor Cyan
$attempt = 0
$maxAttempts = 3
$success = $false

while (-not $success -and $attempt -lt $maxAttempts) {
    $attempt++
    Write-Output "Attempt $attempt of $maxAttempts..."

    if ($attempt -eq 3) {
        $success = $true
        Write-Output "Success on attempt $attempt!"
    }
}

if (-not $success) {
    Write-Output "Failed after $maxAttempts attempts."
}

# --- do-while: always runs at least once ---
Write-Host "`n=== Do-While Example ===" -ForegroundColor Cyan
$counter = 1
do {
    Write-Output "Do-while iteration: $counter"
    $counter++
} while ($counter -le 3)

# --- do-until: runs until condition is TRUE ---
Write-Host "`n=== Do-Until Example ===" -ForegroundColor Cyan
$num = 1
do {
    Write-Output "Number: $num"
    $num++
} until ($num -gt 3)

# --- break and continue ---
Write-Host "`n=== Break Example ===" -ForegroundColor Cyan
foreach ($n in 1..10) {
    if ($n -gt 5) { break }
    Write-Output $n
}

Write-Host "`n=== Continue (skip even numbers) ===" -ForegroundColor Cyan
foreach ($n in 1..10) {
    if ($n % 2 -eq 0) { continue }
    Write-Output $n
}
