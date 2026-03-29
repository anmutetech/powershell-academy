# Day 14 — Final Capstone Project

Congratulations on making it to the final day! This capstone brings together everything from the entire course into one comprehensive project that demonstrates you're ready for a Cloud/DevOps or Security Analyst role.

---

## The Project: Enterprise Infrastructure Automation Platform

Build a PowerShell automation platform that a real IT team would use. This project combines:
- Functions and modules (Days 4, 13)
- File processing and reporting (Days 5, 7)
- Error handling and logging (Day 6)
- AD user management (Day 8)
- Server monitoring (Day 9)
- Azure resource management (Day 10)
- CI/CD and automation (Days 11, 13)
- Security compliance (Day 12)

---

## Requirements

### Module: `EnterpriseTools`

Create a PowerShell module with these public functions:

#### 1. `New-UserOnboarding` (AD — Day 8)
- Read new hire CSV
- Create AD accounts (simulated)
- Assign groups based on department
- Generate welcome email template
- Log all operations

#### 2. `Get-InfrastructureHealth` (Monitoring — Days 7, 9)
- Check CPU, memory, disk across servers
- Check critical services status
- Query event logs for recent errors
- Return overall health status with color-coded output

#### 3. `Invoke-SecurityAudit` (Security — Day 12)
- Check password policies
- Audit privileged accounts
- Scan for open ports
- Check PowerShell logging status
- Return compliance score

#### 4. `Deploy-AzureEnvironment` (Azure/IaC — Days 10, 11)
- Read environment config from `.psd1` file
- Create resources in dependency order (simulated)
- Apply tags
- Calculate cost estimate
- Support `-WhatIf`

#### 5. `Export-DashboardReport` (Reporting — Days 5, 7)
- Combine all above data
- Generate HTML dashboard
- Export CSV and JSON reports
- Save with timestamp

### Testing
- Pester tests for each function (minimum 3 tests each)
- At least 15 tests total

### CI/CD
- GitHub Actions workflow for automated testing

### Documentation
- Module README with usage examples
- Each function has comment-based help

---

## Grading Rubric

| Category | Points | Criteria |
|----------|--------|----------|
| Module Structure | 10 | .psd1, .psm1, Public/Private/Tests structure |
| Functions (5 total) | 30 | CmdletBinding, params, validation, PSCustomObject output |
| Error Handling | 15 | try/catch, -ErrorAction, logging, graceful failures |
| Pester Tests | 15 | 15+ tests, edge cases, error cases |
| Security | 10 | No hardcoded creds, secure practices, compliance checking |
| Reporting | 10 | CSV, JSON, and formatted console output |
| CI/CD | 5 | Working GitHub Actions workflow |
| Code Quality | 5 | Clean code, comments, PSScriptAnalyzer compliant |
| **Total** | **100** | |

---

## Starter Code

The `daily-challenge/starter.ps1` creates the module skeleton. Your job is to implement everything.

---

## Submission Checklist

- [ ] Module imports without errors
- [ ] All 5 public functions work
- [ ] Private helper functions used where appropriate
- [ ] Error handling on all external operations
- [ ] Pester tests pass (15+ tests)
- [ ] GitHub Actions workflow defined
- [ ] CSV and JSON export working
- [ ] Console output is formatted and color-coded
- [ ] No hardcoded credentials
- [ ] Code passes PSScriptAnalyzer (no errors)

---

## Tips for Success

1. **Start small** — get one function working and tested before moving to the next
2. **Test as you go** — write the test, then the function
3. **Reuse code** — your daily challenge solutions are building blocks
4. **Use splatting** — keeps complex cmdlets readable
5. **Error handling first** — wrap everything in try/catch from the start
6. **Have fun** — you've learned an incredible amount in 14 days!

---

## What's Next?

After completing this course, you're ready to:

### Cloud/DevOps Engineer Path
- Build Azure Automation runbooks for your organization
- Create CI/CD pipelines with PowerShell steps
- Manage infrastructure as code with ARM/Bicep templates
- Automate Kubernetes deployments

### Security Analyst Path
- Build compliance scanning tools
- Automate incident response playbooks
- Create AD security audit reports
- Monitor for security events in real-time

### Continued Learning
- [PowerShell Gallery](https://www.powershellgallery.com/) — explore community modules
- [PowerShell Documentation](https://learn.microsoft.com/en-us/powershell/) — official docs
- [Pester Documentation](https://pester.dev/) — testing framework
- [PowerShell Community](https://www.reddit.com/r/PowerShell/) — ask questions, share scripts
- Practice on [HackTheBox](https://www.hackthebox.com/) and [TryHackMe](https://tryhackme.com/) for security skills

**You did it! Welcome to the PowerShell community.**
