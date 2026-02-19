# Operational Rules — Saving Private Otto

**Daily operations, cron schedules, and system maintenance.**

---

## ⏰ Cron Schedule (Consolidated)

**Only 3 active crons post-Phase 1:**

| Cron | Schedule | Purpose | Payload |
|------|----------|---------|---------|
| **Work Queue Check** | Every 10 min | Read WORKQUEUE.md, pick unblocked tasks | `systemEvent: "AUTONOMOUS WORK CHECK"` |
| **ChatGPT Monitor** | Every 15 min | Check tabs, retry stuck Deep Research | `agentTurn: "Check ChatGPT Pro tabs..."` |
| **JR Health Check** | Every 5 min | Query `/api/v1/jobs`, audit model compliance | `systemEvent: "JR MODEL COMPLIANCE AUDIT"` |

**Killed in Phase 1:** 12 redundant duplicate crons (JR monitoring, heartbeat polls, dashboard refreshes consolidated).

---

## 💓 Heartbeat Protocol

**When to check (rotate through these, 2-4 times per day):**

- **Emails** — Any urgent unread messages?
- **Calendar** — Upcoming events in next 24-48h?
- **Mentions** — Twitter/social notifications?
- **Weather** — Relevant if Mike might go out?
- **JR Callback Processing** — Check `.otto-jr-callback.json`
- **Model Switch Requests** — Check `.otto-model-switch-request.json`
- **Dashboard Refresh** — Check `.otto-dashboard-refresh-request`
- **Project Resume** — Check `.otto-project-resume-request`

**Track state in:** `memory/heartbeat-state.json`

```json
{
  "lastChecks": {
    "email": 1708329600,
    "calendar": 1708315200,
    "jr_callbacks": 1708333200,
    "model_switches": 1708333200
  }
}
```

**When to stay quiet (HEARTBEAT_OK):**

- Late night (23:00-08:00 Mike time) unless urgent
- Mike is clearly busy
- Nothing new since last check
- Checked <30 minutes ago

---

## 🖥️ Desktop Signal Safety

**HARD RULE:**

- **BEFORE** any screen automation (clicks, types, app activation):
  - Run `bash ~/.otto/desktop-otto-on.sh` → GOLD wallpaper = "Otto working"
- **IMMEDIATELY AFTER** (success OR failure):
  - Run `bash ~/.otto/desktop-otto-off.sh` → Restore Mike's wallpaper
- **NEVER** leave gold wallpaper on when not needed
- **NEVER** start screen work without turning signal on first

**Pattern:**
```bash
bash ~/.otto/desktop-otto-on.sh
# ... do screen work ...
bash ~/.otto/desktop-otto-off.sh   # ← ALWAYS, even if work failed
```

---

## 🌐 Browser Relay Pre-Flight

**HARD RULE:**

- **BEFORE** any multi-step browser session: Run `snapshot` on target tab FIRST
- `tabs` command does NOT prove relay is connected (raw CDP)
- Only `snapshot` / `act` prove relay extension is live
- If snapshot fails → **STOP IMMEDIATELY**, tell Mike relay needs re-attaching
- **NEVER** waste turns on dead relay — detect early, report fast

---

## 🪟 Terminal Window Hygiene

**HARD RULE:**

- **NEVER** spawn Terminal windows in a loop
- **Use SINGLE Terminal window** for all screencapture/cliclick commands
- **Pattern:** Create one helper window, store its id, reuse via `do script "..." in window id <ID>`
- **After screen automation:** Count windows, close extras
- **Max Terminal windows from Otto: 2** (one screenshots, one commands)

**Cleanup command:**
```bash
osascript -e 'tell application "Terminal" to repeat (count of windows) - 1 times' \
  -e 'close front window' -e 'delay 0.3' -e 'end repeat'
```

---

## 📊 Dashboard Accuracy

**Every heartbeat:**

- Update `.otto-projects.json` with real status after completing ANY task
- Scan for stale data: if lastActivity >1h old + you know real status → UPDATE IT
- If project is done → set status="complete", progress=100 IMMEDIATELY

**Dashboard reads:** `.otto-projects.json`, `.otto-model-state.json`  
**Dashboard writes:** `.otto-dashboard-refresh-request` (Otto processes on heartbeat)

---

## 🔍 Compliance Audits

**JR Model Compliance (every 5-min heartbeat):**

1. Query JR's recent jobs: `GET /api/v1/jobs` with auth headers
2. For EACH job completed since last check:
   - Read `model_used` field
   - If contains `qwen3:32b` or `qwen3-coder-next` AND job_type NOT keepalive/heartbeat/ping → **VIOLATION**
   - Alert Mike IMMEDIATELY via Telegram
   - Log violation in `memory/YYYY-MM-DD.md`

**Gate Script Validation (pre-submission):**

```bash
./scripts/compliance-gate.sh "<job_type>" "<model_used>" "<job_id>"
# Exit 1 = block job, alert Mike, reroute to API
# Exit 0 = proceed
```

---

## 📁 File Locations

| Purpose | Path |
|---------|------|
| Compliance gate script | `projects/saving-private-otto/scripts/compliance-gate.sh` |
| Canonical rules | `projects/saving-private-otto/rules/` (RULES-CORE.md, RULES-MODEL.md, RULES-OPERATIONS.md) |
| Compliance log | `~/.openclaw/workspace/.otto-compliance-log.jsonl` |
| Heartbeat state | `memory/heartbeat-state.json` |
| Project status | `~/.openclaw/workspace/.otto-projects.json` |
| Model state | `~/.openclaw/workspace/.otto-model-state.json` |

---

*Last updated: 2026-02-19 (Saving Private Otto Phase 1)*  
*Maintained by: 3 active crons, heartbeat checks, gate script*
