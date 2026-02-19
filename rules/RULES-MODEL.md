# Model Routing Rules — Saving Private Otto

**HARD RULE (Mike, Feb 19, 2026): Local models can NEVER be primary.**

---

## 🚫 Forbidden Patterns

- ❌ "Try local first → escalate if bad"
- ❌ "Use local for draft, API for final"
- ❌ Quality gates that attempt local before API
- ❌ Any real job routed to local Qwen 32B or qwen3-coder-next

---

## ✅ Allowed Model Pipeline

| Task Type | Model | Backend | NEVER Use |
|-----------|-------|---------|-----------|
| **Keepalive / Heartbeat / Ping ONLY** | qwen3:32b, qwen3-coder-next | Ollama (local) | — |
| **Orchestration / Routing** | qwen-plus-latest | DashScope API | Local Qwen |
| **Planning / Architecture** | claude-opus-4-6 | Anthropic API | Local Qwen, Codex |
| **Coding / Implementation** | gpt-5.3-codex | OpenAI API | Opus, Local Qwen |
| **Oversight / Review** | ChatGPT Pro | Browser (PC) | — |
| **Research / Analysis** | kimi-k2.5 | Moonshot API | Local Qwen |

---

## 🔧 Enforcement Mechanisms

### 1. Gate Script (`scripts/compliance-gate.sh`)

```bash
# Before submitting ANY job:
./scripts/compliance-gate.sh "<job_type>" "<model_used>" "<job_id>"

# Exit code 1 = VIOLATION (stops pipeline)
# Exit code 0 = PASS (proceed)
```

### 2. Code-Level Enforcement (`ollama_client.py`)

```python
def requires_api(job_type: str) -> bool:
    """Returns True if job MUST use API, False if local allowed."""
    KEEPALIVE_TYPES = {'keepalive', 'heartbeat', 'ping'}
    return job_type.lower() not in KEEPALIVE_TYPES

# In job submission:
if requires_api(job_type):
    model = "qwen-plus-latest"  # HARDCODED
    endpoint = DASHSCOPE_API_URL
else:
    model = "qwen3:32b"  # Local only for keepalive
```

### 3. Compliance Logging

All job submissions logged to `.otto-compliance-log.jsonl`:

```json
{"timestamp":"2026-02-19T08:00:00Z","job_id":"jr-123","job_type":"code_change","model_used":"qwen-plus-latest","status":"PASS"}
{"timestamp":"2026-02-19T08:05:00Z","job_id":"jr-124","job_type":"code_review","model_used":"qwen3:32b","status":"VIOLATION","message":"Local model not allowed for code_review"}
```

---

## 🚨 Violation Response

**If gate script detects violation:**

1. **IMMEDIATE ALERT** to Mike via Telegram:
   ```
   ⚠️ COMPLIANCE VIOLATION: Local model 'qwen3:32b' attempted on 'code_change' job jr-124
   Action: Job blocked, rerouting to DashScope API
   ```

2. **AUTO-REROUTE** job to correct API model

3. **LOG** violation in:
   - `.otto-compliance-log.jsonl`
   - `memory/YYYY-MM-DD.md`
   - Project's compliance audit trail

4. **AUDIT** recent jobs for similar violations (last 24h)

---

## 📋 Pre-Submission Checklist

Before ANY job submission to JR or sub-agent:

- [ ] Job type identified (code_change, research, planning, etc.)
- [ ] Correct model selected per table above
- [ ] Gate script passes validation
- [ ] Auth headers present (`Authorization: Bearer <token>`, `X-Request-Timestamp`, `X-Request-Nonce`)
- [ ] Endpoint is API (DashScope, Anthropic, OpenAI) NOT local Ollama

---

*Last updated: 2026-02-19 (Saving Private Otto Phase 1)*  
*Enforced by: compliance-gate.sh, ollama_client.py, cron audits*
