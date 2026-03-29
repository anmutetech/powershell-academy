# =============================================================================
# Day 2 — Arrays and Hashtables
# =============================================================================

# --- Arrays ---
$servers = @("web01", "web02", "db01", "app01")

# Access elements
$servers[0]            # web01
$servers[1]            # web02
$servers[-1]           # app01 (last)
$servers[0..2]         # web01, web02, db01 (range)

# Properties
$servers.Count         # 4

# Check membership
$servers -contains "db01"      # True
"web01" -in $servers           # True

# Add element (creates new array)
$servers += "cache01"
$servers.Count                 # 5

# Iterate
foreach ($server in $servers) {
    Write-Output "Server: $server"
}

# --- ArrayList (efficient for large collections) ---
$list = [System.Collections.ArrayList]@()
$list.Add("item1") | Out-Null
$list.Add("item2") | Out-Null
$list.Add("item3") | Out-Null
$list.Remove("item2")
Write-Output "List count: $($list.Count)"

# --- Hashtables ---
$user = @{
    Name       = "Sarah Connor"
    Email      = "sarah@company.com"
    Department = "Engineering"
    IsAdmin    = $true
}

# Access values
$user["Name"]          # Sarah Connor
$user.Email            # sarah@company.com

# Add/modify
$user["Phone"] = "555-1234"
$user.Title = "Senior Engineer"

# Remove
$user.Remove("Phone")

# Check key exists
$user.ContainsKey("Email")    # True

# Iterate
foreach ($key in $user.Keys) {
    Write-Output "$key : $($user[$key])"
}

# --- Ordered Hashtable ---
$config = [ordered]@{
    Environment = "Production"
    Region      = "us-east-1"
    Debug       = $false
    MaxRetries  = 3
}
# Keys maintain insertion order
$config.Keys

# --- Real-World: Server Inventory ---
$inventory = @(
    @{ Name = "web01"; IP = "10.0.1.10"; Role = "Web"; OS = "Windows" }
    @{ Name = "db01";  IP = "10.0.2.10"; Role = "Database"; OS = "Linux" }
    @{ Name = "app01"; IP = "10.0.3.10"; Role = "Application"; OS = "Windows" }
)

foreach ($server in $inventory) {
    Write-Output "$($server.Name) ($($server.IP)) - $($server.Role) [$($server.OS)]"
}
