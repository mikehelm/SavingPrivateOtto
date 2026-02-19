#!/bin/bash
# Policy Auditor — runs every 30min via OpenClaw cron
set -euo pipefail

WORKSPACE="$HOME/.openclaw/workspace"
LOG="$WORKSPACE/.otto-compliance-log.jsonl"
RULES_DIR="$WORKSPACE/projects/saving-private-otto/rules"
ALERT_FILE="$WORKSPACE/memory/auditor-alerts.jsonl"
HASHES_FILE="$WORKSPACE/projects/saving-private-otto/scripts/.rules-hashes"

mkdir -p "$(dirname "$ALERT_FILE")"

alert() {
    local severity="$1" check="$2" message="$3"
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"severity\":\"$severity\",\"check\":\"$check\",\"message\":\"$message\"}" >> "$ALERT_FILE"
    if [ "$severity" = "CRITICAL" ]; then
        echo "🚨 CRITICAL: $check — $message"
    fi
}

# Check 1: Recent violations
if [ -f "$LOG" ]; then
    RECENT_VIOLATIONS=$(grep '"status":"VIOLATION"' "$LOG" | tail -20 | wc -l | tr -d ' ')
    if [ "$RECENT_VIOLATIONS" -gt 0 ]; then
        alert "CRITICAL" "local-model-violation" "$RECENT_VIOLATIONS total violations in log"
    fi
fi

# Check 2: Rules file integrity
if [ -f "$HASHES_FILE" ]; then
    while IFS='  ' read -r expected_hash file; do
        actual_hash=$(shasum -a 256 "$file" 2>/dev/null | cut -d' ' -f1)
        if [ "$expected_hash" != "$actual_hash" ]; then
            alert "CRITICAL" "rules-tampered" "Hash mismatch for $file"
        fi
    done < "$HASHES_FILE"
else
    alert "WARNING" "no-hashes" "Rules hash baseline not found — run update-rules-hashes.sh"
fi

# Check 3: Rules files exist
for f in RULES-CORE.md RULES-MODEL.md RULES-OPERATIONS.md; do
    if [ ! -f "$RULES_DIR/$f" ]; then
        alert "CRITICAL" "rules-missing" "$f not found"
    fi
done

echo "✅ Audit complete at $(date)"
