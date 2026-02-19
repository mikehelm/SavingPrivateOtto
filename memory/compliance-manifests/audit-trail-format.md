# Audit Trail Format

Each line in `.otto-compliance-log.jsonl`:
```json
{"timestamp":"ISO-8601","job_type":"string","model":"string","status":"PASS|VIOLATION","source":"gate|auditor|callback","details":"string"}
```
