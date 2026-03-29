# Day 1 — Getting Started with PowerShell

Welcome to Day 1. By the end of today, you will know what PowerShell is, how to run commands, and how to discover new commands on your own. That last part is the most important skill — if you can teach yourself, you can learn anything.

---

## Video Resources

Before or after reading this lesson, watch these for visual reinforcement:

- [PowerShell for Beginners (Full Playlist)](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) — Start with episodes 1-3
- [PowerShell in 2 Hours (Crash Course)](https://www.youtube.com/watch?v=UVUd9_k9C6A) — Watch the first 30 minutes alongside this lesson

---

## 1. What is PowerShell?

PowerShell is a command-line shell and scripting language built by Microsoft. It runs on Windows, macOS, and Linux.

Here is why it matters for your career:

- **Every enterprise uses it.** If a company runs Windows servers, Active Directory, Azure, or Microsoft 365, they use PowerShell.
- **It is object-oriented.** Unlike Bash (which passes text between commands), PowerShell passes structured objects. This means you can access properties and methods on command output, not just parse strings.
- **It is the language of cloud automation.** Azure, AWS, and Google Cloud all have PowerShell modules. Most cloud engineering roles list PowerShell as a required or preferred skill.
- **Security teams rely on it.** Incident response, compliance auditing, and forensic data collection are commonly done in PowerShell.

### PowerShell vs CMD vs Bash

| Feature | CMD | Bash | PowerShell |
|---------|-----|------|------------|
| Platform | Windows only | Linux/macOS | Windows, Linux, macOS |
| Output type | Text | Text | Objects |
| Scripting | Limited (.bat) | Full language | Full language |
| Cloud integration | None | Some | Extensive (Azure, AWS) |
| Used in enterprise | Legacy | Servers | Everywhere |

CMD is the old Windows command prompt. It still works but has very limited scripting capability. Bash is the standard shell on Linux and macOS. PowerShell combines the best of both worlds with a modern, object-oriented approach.

## 2. Installing PowerShell

PowerShell comes in two versions:

- **Windows PowerShell 5.1** — Built into Windows 10/11. Older, Windows-only.
- **PowerShell 7+** — The modern, cross-platform version. This is what you should use.

### Windows

PowerShell 5.1 is already installed. To add PowerShell 7:

```powershell
winget install --id Microsoft.PowerShell --source winget
```

### macOS

```bash
brew install powershell/tap/powershell
```

Then run `pwsh` to start PowerShell.

### Linux (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y wget
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
```

Then run `pwsh` to start PowerShell.

### Set Up VS Code

1. Install [VS Code](https://code.visualstudio.com/)
2. Open Extensions (Ctrl+Shift+X), search for **PowerShell**, install the official Microsoft extension
3. Open a terminal in VS Code (Ctrl+`) and type `pwsh`

You now have syntax highlighting, IntelliSense, and an integrated debugger for PowerShell.

## 3. Your First Commands

Open PowerShell (type `pwsh` in your terminal) and try these:

```powershell
# What is today's date?
Get-Date

# Where am I in the file system?
Get-Location

# Move to a different directory
Set-Location ~/Desktop

# Go back
Set-Location ~

# Clear the screen
Clear-Host
```

### The Verb-Noun Convention

Notice the pattern: `Get-Date`, `Get-Location`, `Set-Location`, `Clear-Host`. Every PowerShell command (called a **cmdlet**, pronounced "command-let") follows the **Verb-Noun** format:

- The **verb** says what action to perform: `Get`, `Set`, `New`, `Remove`, `Start`, `Stop`, `Test`
- The **noun** says what you are acting on: `Date`, `Location`, `Process`, `Service`

This makes PowerShell self-documenting. If you want to get something about processes, guess: `Get-Process`. You will probably be right.

To see all approved verbs:

```powershell
Get-Verb
```

## 4. The Big Three Discovery Commands

These three commands are how you teach yourself PowerShell. Memorize them.

### Get-Help — "PowerShell's built-in documentation"

```powershell
# Get help for any command
Get-Help Get-Process

# Show examples (the most useful flag)
Get-Help Get-Process -Examples

# Show the full documentation
Get-Help Get-Process -Full

# Show just the parameter list
Get-Help Get-Process -Parameter *

# Search for commands by keyword
Get-Help *service*
```

The first time you run `Get-Help`, PowerShell may ask you to update help files. Run this:

```powershell
Update-Help -ErrorAction SilentlyContinue
```

### Get-Command — "What commands are available?"

```powershell
# List ALL available commands (there are thousands)
Get-Command

# Find commands with "Service" in the name
Get-Command *Service*

# Find commands with a specific verb
Get-Command -Verb Stop

# Find commands from a specific module
Get-Command -Module Microsoft.PowerShell.Management
```

### Get-Member — "What can I do with this object?"

This is the most important of the three. PowerShell outputs objects, and `Get-Member` shows you what properties and methods those objects have.

```powershell
# What properties does a Process object have?
Get-Process | Get-Member

# Just show properties
Get-Process | Get-Member -MemberType Property

# What properties does a date object have?
Get-Date | Get-Member
```

When you run `Get-Process | Get-Member`, you see properties like `CPU`, `Id`, `ProcessName`, `WorkingSet64` (memory usage). Now you know exactly what data you can work with.

## 5. The Pipeline

The pipeline (`|`) passes the output of one command as input to the next. This is how you chain commands together to build powerful one-liners.

```powershell
# Get all processes, sort by CPU usage (descending), take the top 5
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5

# Get all processes, filter to those using more than 100MB memory
Get-Process | Where-Object { $_.WorkingSet64 -gt 100MB }

# Get all services, filter to running ones, sort by name
Get-Service | Where-Object Status -eq 'Running' | Sort-Object DisplayName
```

Breaking down `Get-Process | Sort-Object CPU -Descending | Select-Object -First 5`:

1. `Get-Process` — Gets all running processes (as objects, not text)
2. `|` — Passes those objects to the next command
3. `Sort-Object CPU -Descending` — Sorts them by the CPU property, highest first
4. `|` — Passes the sorted objects to the next command
5. `Select-Object -First 5` — Takes only the first 5

The pipeline is one of the most powerful features in PowerShell. You will use it constantly.

## 6. Aliases

If you have used Linux or CMD, you might instinctively type `ls`, `cd`, `cat`, or `cls`. These work in PowerShell because they are **aliases** — shortcuts that map to real cmdlet names.

```powershell
# These are all the same command:
ls              # alias
dir             # alias
Get-ChildItem   # real cmdlet name

# See what an alias maps to
Get-Alias ls
Get-Alias cd

# See ALL aliases
Get-Alias

# See aliases for a specific cmdlet
Get-Alias -Definition Get-ChildItem
```

Common aliases:

| Alias | Cmdlet |
|-------|--------|
| `ls`, `dir` | `Get-ChildItem` |
| `cd` | `Set-Location` |
| `cat`, `type` | `Get-Content` |
| `cls`, `clear` | `Clear-Host` |
| `cp`, `copy` | `Copy-Item` |
| `mv`, `move` | `Move-Item` |
| `rm`, `del` | `Remove-Item` |
| `echo`, `write` | `Write-Output` |

**Best practice:** Use full cmdlet names in scripts (for readability), aliases in the terminal (for speed).

## 7. Execution Policy

When you try to run a `.ps1` script file for the first time, PowerShell might block it. This is the **execution policy** — a safety feature that controls which scripts are allowed to run.

```powershell
# Check your current policy
Get-ExecutionPolicy

# Set it to allow local scripts (recommended for learning)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

The common policies:

| Policy | What it allows |
|--------|---------------|
| `Restricted` | No scripts at all (Windows default) |
| `RemoteSigned` | Local scripts run freely; downloaded scripts must be signed |
| `Unrestricted` | All scripts run (with a warning for downloaded ones) |
| `Bypass` | Everything runs, no warnings |

**Use `RemoteSigned` for learning.** It lets you run your own scripts while protecting against untrusted downloaded scripts.

Important: Execution policy is NOT a security boundary. It is a safety net to prevent accidental script execution. A determined user can always bypass it.

---

## Key Takeaways

1. PowerShell uses **Verb-Noun** naming: `Get-Process`, `Set-Location`, `New-Item`
2. The **Big Three** discovery commands: `Get-Help`, `Get-Command`, `Get-Member`
3. The **pipeline** (`|`) chains commands together by passing objects
4. PowerShell outputs **objects**, not text — this is its superpower
5. Use `Get-Member` to explore what properties and methods an object has
6. Set your execution policy to `RemoteSigned` to run scripts

---

## Interview Prep

These questions come up in entry-level Cloud/DevOps and SysAdmin interviews:

**Q: What is PowerShell and how is it different from CMD?**
A: PowerShell is a cross-platform command-line shell and scripting language. Unlike CMD, which only passes text, PowerShell passes objects between commands. This means you can access properties and methods on output without parsing strings. PowerShell also has a full scripting language, module system, and deep integration with cloud platforms like Azure and AWS.

**Q: What are the three commands you would use to learn PowerShell on your own?**
A: `Get-Help` to read documentation, `Get-Command` to find available commands, and `Get-Member` to see what properties and methods an object has. Together, these let you explore any part of PowerShell without external resources.

**Q: What is the PowerShell pipeline?**
A: The pipeline (`|`) passes the output of one command as input to the next. Because PowerShell passes objects (not text), you can filter, sort, and transform data by accessing object properties. For example: `Get-Process | Sort-Object CPU -Descending | Select-Object -First 5`.

**Q: What is an execution policy?**
A: An execution policy controls which PowerShell scripts are allowed to run. `Restricted` blocks all scripts, `RemoteSigned` allows local scripts but requires downloaded scripts to be signed, and `Unrestricted` allows everything. It is a safety feature, not a security boundary.
