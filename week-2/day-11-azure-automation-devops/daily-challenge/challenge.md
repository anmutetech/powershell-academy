# Day 11 — Daily Challenge: CI/CD Pipeline Simulator

## The Task

Build a comprehensive CI/CD pipeline simulator that reads a pipeline config, executes stages, and generates a deployment report — mimicking real Azure DevOps behavior.

## Requirements

1. Read pipeline configuration from a JSON file
2. Execute stages in defined order with dependency resolution
3. Each stage has: name, type (build/test/deploy), script, timeout, retry count
4. Support stage dependencies (don't run until dependencies pass)
5. Track timing, status, and output for each stage
6. Generate a pipeline report with:
   - Stage-by-stage results
   - Total duration
   - Pass/fail status
   - Artifacts generated
7. Support rollback if a deploy stage fails
8. Send notifications (simulated webhook)

## Example Config (pipeline-config.json)

```json
{
    "name": "MediTrack-Deploy",
    "trigger": "main",
    "stages": [
        {"name": "checkout", "type": "build", "dependsOn": []},
        {"name": "restore", "type": "build", "dependsOn": ["checkout"]},
        {"name": "build", "type": "build", "dependsOn": ["restore"]},
        {"name": "unit-tests", "type": "test", "dependsOn": ["build"]},
        {"name": "security-scan", "type": "test", "dependsOn": ["build"]},
        {"name": "deploy-staging", "type": "deploy", "dependsOn": ["unit-tests", "security-scan"]},
        {"name": "integration-tests", "type": "test", "dependsOn": ["deploy-staging"]},
        {"name": "deploy-production", "type": "deploy", "dependsOn": ["integration-tests"]}
    ]
}
```

## Hints

- Use a queue-based approach for dependency resolution
- Track completed stages in a hashtable for O(1) lookup
- Use `[System.Diagnostics.Stopwatch]` for accurate timing
- Simulate failures randomly to test error handling
