# =============================================================================
# Day 3 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Traffic Light ---
Write-Host "=== Exercise 1: Traffic Light ===" -ForegroundColor Cyan
$color = "Green"

if ($color -eq "Red") {
    Write-Output "Stop!"
} elseif ($color -eq "Yellow") {
    Write-Output "Caution — prepare to stop"
} elseif ($color -eq "Green") {
    Write-Output "Go!"
} else {
    Write-Output "Invalid color: $color"
}

# --- Exercise 2: Grade Calculator ---
Write-Host "`n=== Exercise 2: Grade Calculator ===" -ForegroundColor Cyan
$score = 85

$grade = switch ($score) {
    {$_ -ge 90} { "A" }
    {$_ -ge 80} { "B" }
    {$_ -ge 70} { "C" }
    {$_ -ge 60} { "D" }
    default      { "F" }
}
Write-Output "Score: $score -> Grade: $grade"

# --- Exercise 3: Multiplication Table ---
Write-Host "`n=== Exercise 3: Multiplication Table ===" -ForegroundColor Cyan
$num = 7
for ($i = 1; $i -le 10; $i++) {
    $result = $num * $i
    Write-Output "$num x $i = $result"
}

# --- Exercise 4: Service Health Check ---
Write-Host "`n=== Exercise 4: Service Health Check ===" -ForegroundColor Cyan
$serviceNames = @("wuauserv", "Spooler", "FakeService123", "W32Time")

foreach ($svcName in $serviceNames) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($null -eq $svc) {
        Write-Output "$svcName - NOT FOUND"
    } else {
        Write-Output "$svcName - $($svc.Status)"
    }
}

# --- Exercise 5: FizzBuzz ---
Write-Host "`n=== Exercise 5: FizzBuzz ===" -ForegroundColor Cyan
for ($i = 1; $i -le 30; $i++) {
    if ($i % 15 -eq 0) {
        Write-Output "FizzBuzz"
    } elseif ($i % 3 -eq 0) {
        Write-Output "Fizz"
    } elseif ($i % 5 -eq 0) {
        Write-Output "Buzz"
    } else {
        Write-Output $i
    }
}
