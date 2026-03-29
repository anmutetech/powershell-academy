# =============================================================================
# Day 2 — Operators and String Operations
# =============================================================================

# --- Comparison Operators ---
5 -eq 5          # True (equal)
5 -ne 3          # True (not equal)
10 -gt 5         # True (greater than)
3 -lt 5          # True (less than)
5 -ge 5          # True (greater or equal)
3 -le 5          # True (less or equal)

# String comparison (case-insensitive by default)
"Hello" -eq "hello"       # True
"Hello" -ceq "hello"      # False (case-sensitive)

# Wildcards and regex
"PowerShell" -like "Power*"        # True
"PowerShell" -like "*Shell"        # True
"abc123" -match "\d+"              # True (contains digits)
"user@email.com" -match "@"        # True

# Collection operators
@(1, 2, 3, 4, 5) -contains 3      # True
3 -in @(1, 2, 3, 4, 5)            # True
6 -notin @(1, 2, 3, 4, 5)         # True

# --- Logical Operators ---
$age = 25
$hasLicense = $true

($age -ge 18) -and $hasLicense     # True (both true)
($age -ge 65) -or $hasLicense      # True (one true)
-not $false                         # True
!$false                             # True (shorthand)

# --- Arithmetic ---
10 + 3     # 13
10 - 3     # 7
10 * 3     # 30
10 / 3     # 3.33...
10 % 3     # 1 (remainder)
[math]::Pow(2, 8)    # 256
[math]::Sqrt(144)    # 12
[math]::Round(3.14159, 2)  # 3.14

# PowerShell size multipliers
1KB        # 1024
1MB        # 1048576
1GB        # 1073741824
500MB      # 524288000

# --- String Operations ---
$text = "  Hello, World!  "
$text.Trim()                         # "Hello, World!"
$text.ToUpper()                      # "  HELLO, WORLD!  "
$text.ToLower()                      # "  hello, world!  "
$text.Replace("World", "PowerShell") # "  Hello, PowerShell!  "
$text.Contains("World")              # True
$text.StartsWith("  H")             # True

# Split and Join
"one,two,three".Split(",")          # Array: one, two, three
@("a", "b", "c") -join "-"         # "a-b-c"

# Substring
"PowerShell".Substring(0, 5)        # "Power"
"PowerShell".Substring(5)           # "Shell"

# String length
"Hello".Length                       # 5

# Format operator
"{0} scored {1} points" -f "Team A", 42
"Disk: {0:P1}" -f 0.85              # "Disk: 85.0%"
"Price: {0:N2}" -f 1234.5           # "Price: 1,234.50"
