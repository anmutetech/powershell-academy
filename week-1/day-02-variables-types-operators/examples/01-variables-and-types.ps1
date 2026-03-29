# =============================================================================
# Day 2 — Variables and Types
# =============================================================================

# --- Creating Variables ---
$name = "Sarah Connor"
$age = 28
$salary = 85000.50
$isAdmin = $true
$nothing = $null

# Display them
Write-Output "Name: $name"
Write-Output "Age: $age"
Write-Output "Salary: $salary"
Write-Output "Is Admin: $isAdmin"
Write-Output "Nothing: $nothing"

# --- Checking Types ---
$name.GetType().Name          # String
$age.GetType().Name           # Int32
$salary.GetType().Name        # Double
$isAdmin.GetType().Name       # Boolean

# --- Type Casting ---
[int]"42"                     # String to Int: 42
[string]42                    # Int to String: "42"
[double]"3.14"                # String to Double: 3.14
[bool]1                       # Int to Boolean: True
[bool]0                       # Int to Boolean: False
[bool]""                      # Empty string: False
[bool]"hello"                 # Non-empty string: True
[datetime]"2026-03-29"        # String to DateTime

# --- Automatic Variables ---
$PSVersionTable.PSVersion     # PowerShell version
$HOME                         # Home directory
$PWD                          # Current directory
$true                         # Boolean true
$false                        # Boolean false
$null                         # Null/nothing

# --- Environment Variables ---
$env:PATH                     # System PATH
$env:USERNAME                 # Current user (Windows)
$env:HOME                     # Home directory

# --- String Interpolation ---
$city = "Austin"

# Double quotes: variables ARE expanded
"I live in $city"             # Output: I live in Austin

# Single quotes: variables are NOT expanded
'I live in $city'             # Output: I live in $city

# Subexpressions for complex expressions
"PowerShell version: $($PSVersionTable.PSVersion)"
"2 + 2 = $(2 + 2)"
"There are $(( Get-Process ).Count) processes running"
