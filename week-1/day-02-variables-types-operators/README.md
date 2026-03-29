# Day 2 — Variables, Types & Operators

Today you learn how PowerShell stores and manipulates data. Variables, data types, and operators are the building blocks of every script you will ever write.

---

## Video Resources

- [PowerShell Variables and Data Types](https://www.youtube.com/watch?v=K2NHMkdMzmk)
- [PowerShell for Beginners Playlist](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) — Episodes 4-6

---

## 1. Variables

Variables store data for later use. In PowerShell, all variable names start with `$`.

```powershell
$name = "Sarah"
$age = 28
$isAdmin = $true

Write-Output "Name: $name, Age: $age"
```

### Naming Conventions

- Use camelCase or PascalCase: `$serverName`, `$ServerName`
- Be descriptive: `$maxRetryCount` not `$x`
- No spaces or special characters (except underscores)

### Automatic Variables

PowerShell has built-in variables you should know:

| Variable | What it contains |
|----------|-----------------|
| `$true` / `$false` | Boolean true and false |
| `$null` | Represents "nothing" or "no value" |
| `$_` | The current object in a pipeline (also `$PSItem`) |
| `$PSVersionTable` | PowerShell version information |
| `$HOME` | Your home directory path |
| `$PWD` | Current working directory |
| `$env:PATH` | The system PATH environment variable |
| `$env:USERNAME` | Current username (Windows) |
| `$Error` | Array of recent errors |

```powershell
# Access environment variables with $env:
$env:COMPUTERNAME
$env:USERNAME
$env:PATH
```

## 2. Data Types

PowerShell is dynamically typed — you do not have to declare types, but every value has one.

### Strings

```powershell
# Double quotes: variable interpolation WORKS
$name = "World"
"Hello $name"          # Output: Hello World

# Single quotes: everything is literal, no interpolation
'Hello $name'          # Output: Hello $name

# Subexpressions in double quotes
"There are $(Get-Process | Measure-Object | Select-Object -ExpandProperty Count) processes running"

# Here-strings (multi-line)
$message = @"
Dear $name,
This is a multi-line string.
Variables are expanded here.
"@

# Escape characters use backtick (`)
"Column1`tColumn2"     # `t = tab
"Line1`nLine2"         # `n = newline
```

### Numbers

```powershell
$count = 42            # Integer ([int])
$price = 19.99         # Double ([double])
$big = 1GB             # PowerShell understands KB, MB, GB, TB
$big                   # Output: 1073741824
```

### Booleans

```powershell
$isEnabled = $true
$hasAccess = $false
```

### Checking and Casting Types

```powershell
# Check a variable's type
$name = "Sarah"
$name.GetType()        # System.String

$count = 42
$count.GetType()       # System.Int32

# Cast to a specific type
[int]"42"              # String to integer
[string]42             # Integer to string
[double]"3.14"         # String to double
[bool]1                # Integer to boolean (1 = True, 0 = False)
[datetime]"2026-03-29" # String to DateTime
```

## 3. Arrays

Arrays hold ordered collections of values.

```powershell
# Create an array
$servers = @("web01", "web02", "db01", "app01")

# Access by index (zero-based)
$servers[0]            # web01
$servers[-1]           # app01 (last element)
$servers[1..2]         # web02, db01 (range)

# Array properties
$servers.Count         # 4
$servers.Length         # 4 (same thing)

# Check if an item exists
$servers -contains "web01"    # True
"db01" -in $servers           # True

# Add an element (creates a NEW array)
$servers += "cache01"

# Loop through
foreach ($server in $servers) {
    Write-Output "Checking $server..."
}
```

**Important:** PowerShell arrays are fixed-size. When you use `+=`, it creates an entirely new array. For large collections, use `ArrayList`:

```powershell
$list = [System.Collections.ArrayList]@()
$list.Add("item1") | Out-Null    # Add returns index, pipe to Out-Null to suppress
$list.Add("item2") | Out-Null
$list.Remove("item1")            # Remove by value
```

## 4. Hashtables

Hashtables store key-value pairs (like dictionaries in Python or objects in JavaScript).

```powershell
# Create a hashtable
$user = @{
    Name       = "Sarah Connor"
    Email      = "sarah@company.com"
    Department = "Engineering"
    IsAdmin    = $true
}

# Access values
$user["Name"]          # Sarah Connor
$user.Name             # Sarah Connor (dot notation)

# Add a key
$user["Phone"] = "555-1234"
$user.Title = "Senior Engineer"

# Remove a key
$user.Remove("Phone")

# Check if a key exists
$user.ContainsKey("Email")     # True

# Iterate
foreach ($key in $user.Keys) {
    Write-Output "$key = $($user[$key])"
}
```

### Ordered Hashtables

Normal hashtables do not preserve insertion order. Use `[ordered]` if order matters:

```powershell
$config = [ordered]@{
    Environment = "Production"
    Region      = "us-east-1"
    Debug       = $false
}
```

## 5. Operators

### Comparison Operators

PowerShell does NOT use `==`, `!=`, `>`, `<`. Instead:

| Operator | Meaning | Example |
|----------|---------|---------|
| `-eq` | Equal to | `5 -eq 5` returns `True` |
| `-ne` | Not equal | `5 -ne 3` returns `True` |
| `-gt` | Greater than | `10 -gt 5` returns `True` |
| `-lt` | Less than | `3 -lt 5` returns `True` |
| `-ge` | Greater or equal | `5 -ge 5` returns `True` |
| `-le` | Less or equal | `3 -le 5` returns `True` |
| `-like` | Wildcard match | `"PowerShell" -like "Power*"` |
| `-match` | Regex match | `"abc123" -match "\d+"` |
| `-contains` | Collection contains | `@(1,2,3) -contains 2` |
| `-in` | Value in collection | `2 -in @(1,2,3)` |

```powershell
# String comparison is case-INSENSITIVE by default
"Hello" -eq "hello"       # True

# Use the 'c' prefix for case-sensitive
"Hello" -ceq "hello"      # False
"Hello" -cmatch "H"       # True
```

### Logical Operators

```powershell
$age = 25
$hasLicense = $true

# AND: both must be true
($age -ge 18) -and $hasLicense         # True

# OR: at least one must be true
($age -ge 65) -or $hasLicense          # True

# NOT: reverses the boolean
-not $hasLicense                        # False
!$hasLicense                            # False (shorthand)
```

### Arithmetic Operators

```powershell
10 + 3     # 13
10 - 3     # 7
10 * 3     # 30
10 / 3     # 3.33333...
10 % 3     # 1 (modulus / remainder)

# String repetition
"ha" * 3   # "hahaha"

# String concatenation
"Hello" + " " + "World"   # "Hello World"
```

## 6. String Operations

Strings are objects with useful methods:

```powershell
$text = "  Hello, World!  "

$text.Trim()                    # "Hello, World!"
$text.ToUpper()                 # "  HELLO, WORLD!  "
$text.ToLower()                 # "  hello, world!  "
$text.Replace("World", "PowerShell")  # "  Hello, PowerShell!  "
$text.Contains("World")         # True
$text.StartsWith("  H")        # True
$text.EndsWith("!  ")          # True

# Split
$csv = "server1,server2,server3"
$csv.Split(",")                 # Array: server1, server2, server3

# Join
$servers = @("web01", "web02", "db01")
$servers -join ", "             # "web01, web02, db01"

# Substring
$text = "PowerShell"
$text.Substring(0, 5)          # "Power"

# Format operator
"{0} is {1} years old" -f "Sarah", 28     # "Sarah is 28 years old"
"Disk usage: {0:P1}" -f 0.85              # "Disk usage: 85.0%"
"Price: {0:C2}" -f 19.99                  # "Price: $19.99"
"Hex: {0:X}" -f 255                       # "Hex: FF"
```

---

## Key Takeaways

1. Variables start with `$` — no declaration keyword needed
2. **Double quotes** expand variables, **single quotes** do not
3. PowerShell uses `-eq`, `-ne`, `-gt`, `-lt` — NOT `==`, `!=`, `>`, `<`
4. Arrays use `@()`, hashtables use `@{}`
5. Use `[ordered]@{}` when hashtable order matters
6. Use `.GetType()` to check any variable's type
7. The `-f` format operator is your best friend for output formatting

---

## Interview Prep

**Q: What is the difference between single and double quotes in PowerShell?**
A: Double quotes (`"..."`) perform variable interpolation and process escape characters. Single quotes (`'...'`) treat everything as a literal string. For example, `"Hello $name"` outputs "Hello Sarah" while `'Hello $name'` outputs "Hello $name".

**Q: How do PowerShell comparison operators differ from other languages?**
A: PowerShell uses dash-prefixed operators (`-eq`, `-ne`, `-gt`, `-lt`) instead of symbols (`==`, `!=`, `>`, `<`). This is because `>` is used for output redirection. String comparisons are case-insensitive by default; use `c` prefix for case-sensitive variants (`-ceq`, `-cne`).

**Q: What is the difference between an array and a hashtable?**
A: An array is an ordered collection accessed by numeric index (`$arr[0]`). A hashtable is a collection of key-value pairs accessed by key name (`$hash["Name"]` or `$hash.Name`). Use arrays for lists of similar items, hashtables for structured data with named properties.

**Q: Why would you use ArrayList instead of a regular array?**
A: Regular PowerShell arrays are fixed-size. When you use `+=`, PowerShell creates an entirely new array and copies all elements — this is slow for large collections. `ArrayList` supports efficient `.Add()` and `.Remove()` operations without recreating the entire collection.
