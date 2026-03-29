# PowerShell Academy — From Zero to Job-Ready in 14 Days

A structured, self-paced PowerShell course designed for aspiring **Cloud/DevOps Engineers** and **Security Analysts**. No prior command-line experience required.

This course takes you from your first PowerShell command to building enterprise-grade automation tools, with real-world scenarios pulled from actual job responsibilities. Every lesson ends with a daily challenge that mirrors work you would do on the job.

## Who Is This For?

- Students with **no prior CLI experience** who want to break into Cloud, DevOps, or Security roles
- IT professionals transitioning from GUI-based administration to automation
- Anyone preparing for **PowerShell-heavy technical interviews**

## Course Structure

The course is split into two weeks:

- **Week 1 (Days 1-7):** PowerShell fundamentals — variables, control flow, functions, file handling, error handling
- **Week 2 (Days 8-14):** Real-world PowerShell — Active Directory, Windows Server, Azure, security, CI/CD, and a capstone project

Each day includes:

```
day-XX-topic/
├── README.md            # Full lesson with embedded video links
├── examples/            # Runnable code examples
├── exercises/           # Practice problems (easy to hard)
├── solutions/           # Complete solutions
└── daily-challenge/     # End-of-day project with starter template and solution
```

## Prerequisites

- A computer (Windows, macOS, or Linux)
- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) installed
- [VS Code](https://code.visualstudio.com/) with the [PowerShell extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- (Week 2) Azure free account for Days 10-11
- (Week 2) Windows machine or VM for Days 8-9, 12 (AD and Windows Server labs)

## Curriculum

### Week 1 — PowerShell Fundamentals

| Day | Topic | What You Will Build |
|-----|-------|-------------------|
| [Day 1](week-1/day-01-getting-started/) | Getting Started | System Information Reporter |
| [Day 2](week-1/day-02-variables-types-operators/) | Variables, Types & Operators | Interactive Calculator |
| [Day 3](week-1/day-03-control-flow/) | Control Flow | Employee Directory Processor |
| [Day 4](week-1/day-04-functions-modules/) | Functions & Modules | DevOps Toolbox Module |
| [Day 5](week-1/day-05-filesystem-text-processing/) | File System & Text Processing | Log File Analyzer |
| [Day 6](week-1/day-06-error-handling-debugging/) | Error Handling & Debugging | Robust File Backup Script |
| [Day 7](week-1/day-07-review-mini-project/) | Review & Mini Project | Server Health Check Report |

### Week 2 — Real-World PowerShell

| Day | Topic | What You Will Build |
|-----|-------|-------------------|
| [Day 8](week-2/day-08-active-directory/) | Active Directory Automation | Employee Onboarding Script |
| [Day 9](week-2/day-09-windows-server-admin/) | Windows Server Administration | Incident Response Toolkit |
| [Day 10](week-2/day-10-azure-powershell/) | Azure PowerShell | Azure Environment Provisioner |
| [Day 11](week-2/day-11-azure-automation-devops/) | Azure Automation & DevOps | Cloud Auto-Remediation Suite |
| [Day 12](week-2/day-12-security-compliance/) | Security & Compliance | Security Compliance Audit Tool |
| [Day 13](week-2/day-13-cicd-infrastructure-as-code/) | CI/CD & Infrastructure as Code | PowerShell Module with CI Pipeline |
| [Day 14](week-2/day-14-capstone-project/) | Capstone Project | Enterprise Automation Suite |

## How to Use This Course

1. **Start at Day 1** — even if you have some experience, the fundamentals lesson establishes conventions used throughout the course.
2. **Read the README first** — each day's README is the primary lesson. Watch the linked videos for visual reinforcement.
3. **Run the examples** — open each `.ps1` file in VS Code and run the commands yourself. Modify them. Break them. Fix them.
4. **Do the exercises** — try each one before looking at the solution. Struggling is part of learning.
5. **Complete the daily challenge** — these are the most important part. They simulate real job tasks and build your portfolio.
6. **Review the interview prep** — each day includes interview questions relevant to that topic.

## Video Resources

These playlists complement the written material:

| Resource | Link |
|----------|------|
| PowerShell for Beginners (Full Playlist) | [YouTube](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8) |
| PowerShell in 2 Hours (Crash Course) | [YouTube](https://www.youtube.com/watch?v=UVUd9_k9C6A) |
| Microsoft PowerShell Documentation | [learn.microsoft.com](https://learn.microsoft.com/en-us/powershell/) |

## Setting Up Your Environment

### Install PowerShell 7

**Windows:**
```powershell
winget install --id Microsoft.PowerShell --source winget
```

**macOS:**
```bash
brew install powershell/tap/powershell
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo apt-get install -y powershell
```

### Install VS Code + Extension

1. Download [VS Code](https://code.visualstudio.com/)
2. Open VS Code, go to Extensions (Ctrl+Shift+X)
3. Search for "PowerShell" and install the official Microsoft extension
4. Open a terminal in VS Code and type `pwsh` to start PowerShell 7

### Verify Installation

```powershell
$PSVersionTable.PSVersion
```

You should see version 7.x.

## Career Paths This Course Supports

| Role | Key PowerShell Skills | Relevant Days |
|------|----------------------|---------------|
| **Cloud Engineer** | Azure automation, IaC, CI/CD pipelines | Days 10, 11, 13 |
| **DevOps Engineer** | Automation, testing, pipelines, infrastructure | Days 4, 6, 11, 13 |
| **Security Analyst** | Incident response, compliance auditing, forensics | Days 9, 12 |
| **Systems Administrator** | AD management, server admin, monitoring | Days 8, 9, 7 |
| **Site Reliability Engineer** | Monitoring, automation, infrastructure validation | Days 7, 13 |

## Contributing

Found a typo, bug, or have an improvement? Open an issue or submit a pull request.

## License

This project is open source and available for educational use.
