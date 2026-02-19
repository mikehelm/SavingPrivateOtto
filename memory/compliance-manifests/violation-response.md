# Violation Response Protocol

1. Detect violation (gate script, auditor, or JR callback)
2. Log to `.otto-compliance-log.jsonl`
3. Alert Mike via Telegram immediately
4. Block further local model submissions until reviewed
5. Document root cause in daily memory file
