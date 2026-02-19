# Model Routing Policy

| Task Type | Model | NEVER Use |
|-----------|-------|-----------|
| Orchestration / routing | Qwen 3.5 Plus (API) | Local Qwen |
| Planning / architecture | Opus | Local Qwen, Codex |
| Coding / implementation | Codex | Opus, Local Qwen |
| Oversight / review | ChatGPT Pro | — |
| Keepalive / heartbeat / ping ONLY | Local Qwen 32B | — |

**Local models (qwen3:32b, qwen3-coder-next) can NEVER be used for real work.**
