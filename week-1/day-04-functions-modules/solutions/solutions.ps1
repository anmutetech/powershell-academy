# =============================================================================
# Day 4 — Exercise Solutions
# =============================================================================

# --- Exercise 1: Temperature Converter ---
Write-Host "=== Exercise 1: Temperature Converter ===" -ForegroundColor Cyan

function Convert-Temperature {
    param(
        [Parameter(Mandatory)]
        [double]$Degrees,

        [Parameter(Mandatory)]
        [ValidateSet("Celsius", "Fahrenheit")]
        [string]$From
    )

    if ($From -eq "Celsius") {
        $converted = ($Degrees * 9/5) + 32
        $toUnit = "Fahrenheit"
    } else {
        $converted = ($Degrees - 32) * 5/9
        $toUnit = "Celsius"
    }

    [PSCustomObject]@{
        Original  = "$Degrees $From"
        Converted = "{0:N2} {1}" -f $converted, $toUnit
    }
}

Convert-Temperature -Degrees 100 -From Celsius
Convert-Temperature -Degrees 72 -From Fahrenheit

# --- Exercise 2: Password Generator ---
Write-Host "`n=== Exercise 2: Password Generator ===" -ForegroundColor Cyan

function New-RandomPassword {
    param(
        [ValidateRange(8, 128)]
        [int]$Length = 16,

        [switch]$IncludeSpecialChars
    )

    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    if ($IncludeSpecialChars) {
        $chars += "!@#$%^&*()-_=+[]{}|;:,.<>?"
    }

    $password = -join (1..$Length | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
    Write-Output $password
}

New-RandomPassword
New-RandomPassword -Length 24 -IncludeSpecialChars

# --- Exercise 3: Service Monitor ---
Write-Host "`n=== Exercise 3: Service Monitor ===" -ForegroundColor Cyan

function Get-ServiceHealth {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ServiceName
    )

    process {
        $svc = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($null -eq $svc) {
            [PSCustomObject]@{
                Name      = $ServiceName
                Status    = "NOT FOUND"
                StartType = "N/A"
            }
        } else {
            [PSCustomObject]@{
                Name      = $svc.Name
                Status    = $svc.Status.ToString()
                StartType = $svc.StartType.ToString()
            }
        }
    }
}

"Spooler", "W32Time", "FakeService123" | Get-ServiceHealth | Format-Table

# --- Exercise 4: File Age Report ---
Write-Host "=== Exercise 4: File Age Report ===" -ForegroundColor Cyan

function Get-OldFiles {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Path,

        [int]$OlderThanDays = 30
    )

    $cutoff = (Get-Date).AddDays(-$OlderThanDays)
    Write-Verbose "Looking for files older than $cutoff in $Path"

    $files = Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff }

    Write-Verbose "Found $($files.Count) files"

    foreach ($file in $files) {
        [PSCustomObject]@{
            Name         = $file.Name
            SizeMB       = [math]::Round($file.Length / 1MB, 2)
            LastModified = $file.LastWriteTime
        }
    }
}

Get-OldFiles -Path $env:TEMP -OlderThanDays 7 -Verbose | Select-Object -First 5 | Format-Table

# --- Exercise 5: Math Library ---
Write-Host "=== Exercise 5: Math Library ===" -ForegroundColor Cyan

function Get-Average {
    param([Parameter(Mandatory)][double[]]$Numbers)
    ($Numbers | Measure-Object -Average).Average
}

function Get-Median {
    param([Parameter(Mandatory)][double[]]$Numbers)
    $sorted = $Numbers | Sort-Object
    $count = $sorted.Count
    if ($count % 2 -eq 0) {
        ($sorted[$count/2 - 1] + $sorted[$count/2]) / 2
    } else {
        $sorted[([math]::Floor($count/2))]
    }
}

function Get-StandardDeviation {
    param([Parameter(Mandatory)][double[]]$Numbers)
    $avg = Get-Average -Numbers $Numbers
    $sumSquares = ($Numbers | ForEach-Object { [math]::Pow($_ - $avg, 2) } | Measure-Object -Sum).Sum
    [math]::Round([math]::Sqrt($sumSquares / $Numbers.Count), 4)
}

$data = @(85, 92, 78, 95, 88, 72, 91)
Write-Output "Data: $($data -join ', ')"
Write-Output "Average: $(Get-Average -Numbers $data)"
Write-Output "Median: $(Get-Median -Numbers $data)"
Write-Output "Std Dev: $(Get-StandardDeviation -Numbers $data)"
