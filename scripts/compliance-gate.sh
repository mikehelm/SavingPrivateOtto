#!/bin/bash
# Compliance Gate Script — Saving Private Otto Phase 1
# Blocks local model usage on real work, enforces API-only routing

set -e

JOB_TYPE="$1"
MODEL_USED="$2"
JOB_ID="${3:-unknown}"

# Log file for compliance trail
LOG_FILE="$HOME/.openclaw/workspace/.otto-compliance-log.jsonl"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Function to log violation
log_violation() {
    echo "{\"timestamp\":\"$TIMESTAMP\",\"job_id\":\"$JOB_ID\",\"job_type\":\"$JOB_TYPE\",\"model_used\":\"$MODEL_USED\",\"status\":\"VIOLATION\",\"message\":\"$1\"}" >> "$LOG_FILE"
    echo "❌ COMPLIANCE VIOLATION: $1" >&2
    exit 1
}

# Function to log pass
log_pass() {
    echo "{\"timestamp\":\"$TIMESTAMP\",\"job_id\":\"$JOB_ID\",\"job_type\":\"$JOB_TYPE\",\"model_used\":\"$MODEL_USED\",\"status\":\"PASS\"}" >> "$LOG_FILE"
    echo "✅ Compliance check passed"
}

# Keepalive/heartbeat/ping jobs can use local models
if [[ "$JOB_TYPE" =~ ^(keepalive|heartbeat|ping)$ ]]; then
    log_pass
    exit 0
fi

# Real work jobs MUST use API models
# Local models: qwen3:32b, qwen3-coder-next, qwen3-vl
if [[ "$MODEL_USED" =~ (qwen3:32b|qwen3-coder-next|qwen3-vl|ollama) ]]; then
    log_violation "Local model '$MODEL_USED' not allowed for job type '$JOB_TYPE'. Must use DashScope API (qwen-plus-latest)."
fi

# Allowed API models for real work
if [[ "$MODEL_USED" =~ ^(qwen-plus-latest|moonshot/kimi-k2.5|alibaba/qwen3.5-plus|openai/gpt-5.3-codex|anthropic/claude-opus-4-6)$ ]]; then
    log_pass
    exit 0
fi

# Unknown model — warn but allow (future-proofing)
echo "⚠️  Warning: Unknown model '$MODEL_USED' — ensure it's an API model, not local"
log_pass
exit 0
