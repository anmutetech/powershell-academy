# =============================================================================
# Day 4 — Advanced Functions (CmdletBinding, Validation, Pipeline)
# =============================================================================

# --- CmdletBinding with Verbose and WhatIf ---
function Clear-TempFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path = $env:TEMP,
        [int]$OlderThanDays = 7
    )

    $cutoff = (Get-Date).AddDays(-$OlderThanDays)
    $files = Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff }

    Write-Verbose "Found $($files.Count) files older than $OlderThanDays days"

    foreach ($file in $files) {
        if ($PSCmdlet.ShouldProcess($file.Name, "Delete file")) {
            Remove-Item $file.FullName -Force
            Write-Verbose "Deleted: $($file.Name)"
        }
    }
}

# Preview what would happen
Clear-TempFiles -WhatIf

# See verbose details without deleting
Clear-TempFiles -WhatIf -Verbose

# --- Parameter Validation ---
function New-UserAccount {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(3, 20)]
        [string]$Username,

        [Parameter(Mandatory)]
        [ValidateSet("Admin", "User", "ReadOnly")]
        [string]$Role,

        [ValidatePattern('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')]
        [string]$Email,

        [ValidateRange(1, 365)]
        [int]$PasswordExpiryDays = 90
    )

    Write-Output "Creating user: $Username | Role: $Role | Expiry: $PasswordExpiryDays days"
    if ($Email) { Write-Output "Email: $Email" }
}

New-UserAccount -Username "jdoe" -Role "Admin" -Email "jdoe@company.com"
New-UserAccount -Username "asmith" -Role "User"

# --- ValidateScript ---
function Import-DataFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$FilePath
    )

    Write-Output "Importing data from: $FilePath"
    Import-Csv -Path $FilePath
}

# --- Pipeline Input ---
function Get-FileSize {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path
    )

    process {
        $item = Get-Item $Path -ErrorAction SilentlyContinue
        if ($item) {
            [PSCustomObject]@{
                Name   = $item.Name
                SizeKB = [math]::Round($item.Length / 1KB, 2)
                SizeMB = [math]::Round($item.Length / 1MB, 2)
            }
        }
    }
}

# Pipeline usage
Get-ChildItem $env:TEMP -File | Select-Object -First 3 -ExpandProperty FullName | Get-FileSize

# --- Begin/Process/End ---
function Measure-FileCollection {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [System.IO.FileInfo]$File
    )

    begin {
        $totalSize = 0
        $count = 0
        Write-Verbose "Starting file measurement..."
    }

    process {
        $totalSize += $File.Length
        $count++
    }

    end {
        [PSCustomObject]@{
            FileCount = $count
            TotalMB   = [math]::Round($totalSize / 1MB, 2)
            AvgKB     = if ($count -gt 0) { [math]::Round(($totalSize / $count) / 1KB, 2) } else { 0 }
        }
    }
}

Get-ChildItem $env:TEMP -File -ErrorAction SilentlyContinue |
    Select-Object -First 10 |
    Measure-FileCollection -Verbose
