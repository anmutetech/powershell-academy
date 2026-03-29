# Day 12 — Daily Challenge: Security Compliance Scanner

## The Task

Build a comprehensive security compliance scanner that checks a system against CIS-style benchmarks and generates a compliance report.

## Requirements

1. Check at least 10 security controls:
   - Password policy (complexity, expiration)
   - Account policy (guest disabled, admin renamed)
   - PowerShell logging (script block, module, transcription)
   - Execution policy
   - Firewall status
   - Open ports (flag risky ones)
   - Windows Update (recent patches)
   - Antivirus status
   - File permissions on sensitive paths
   - Service account audit
2. Each check returns: pass/fail, severity, finding, remediation
3. Calculate an overall compliance score (weighted)
4. Generate a console report with color coding
5. Export detailed findings to CSV and JSON
6. Support `-Remediate` switch to auto-fix simple issues

## Hints

- Organize checks as an array of hashtables with scriptblock actions
- Use weighted scoring (Critical=25, High=15, Medium=10, Low=5)
- Use `try/catch` around each check (some may not work without admin)
- The `-Remediate` flag should only fix safe, reversible changes
