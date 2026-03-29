# =============================================================================
# Day 2 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Variable Types ---
$myString = "Hello"
$myInt = 42
$myDouble = 3.14
$myBool = $true
$myDate = Get-Date
$myArray = @(1, 2, 3)
$myHash = @{ Key = "Value" }

@($myString, $myInt, $myDouble, $myBool, $myDate, $myArray, $myHash) | ForEach-Object {
    Write-Output "$_ is a $($_.GetType().Name)"
}

# --- Exercise 2: Server Array ---
$servers = @("web01", "web02", "db01", "app01", "cache01")
$servers += "monitor01"
$servers -contains "db01"        # True
$servers = $servers | Where-Object { $_ -ne $servers[2] }
Write-Output "Server count: $($servers.Count)"

# --- Exercise 3: User Hashtable ---
$user = @{
    Name       = "Jane Doe"
    Email      = "jane@company.com"
    Department = "Engineering"
    Role       = "DevOps Engineer"
    Active     = $true
    StartDate  = [datetime]"2024-01-15"
}
foreach ($key in $user.Keys) {
    Write-Output "${key}: $($user[$key])"
}

# --- Exercise 4: Comparison Expressions ---
$num = 42
($num -ge 1) -and ($num -le 100)                # True
"admin@company.com" -match "@"                    # True
"PowerShell" -like "Power*"                       # True
15 % 3 -eq 0                                     # True (divisible)

# --- Exercise 5: Name Splitter ---
$fullName = "John Michael Smith"
$parts = $fullName.Split(" ")
$firstName = $parts[0]
$middleName = $parts[1]
$lastName = $parts[2]
Write-Output "Last: $lastName, First: $firstName, Middle: $middleName"
