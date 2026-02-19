#!/bin/bash
set -euo pipefail
REPO="$HOME/.openclaw/workspace"
COMPONENT="${1:-all}"
COMMITS_BACK="${2:-1}"
cd "$REPO"
case "$COMPONENT" in
  rules) git checkout HEAD~"$COMMITS_BACK" -- projects/saving-private-otto/rules/ && echo "✅ Rules rolled back" ;;
  scripts) git checkout HEAD~"$COMMITS_BACK" -- projects/saving-private-otto/scripts/ && echo "✅ Scripts rolled back" ;;
  gate) git checkout HEAD~"$COMMITS_BACK" -- projects/saving-private-otto/scripts/compliance-gate.sh && echo "✅ Gate rolled back" ;;
  all) git checkout HEAD~"$COMMITS_BACK" -- projects/saving-private-otto/ && echo "✅ All SPO rolled back" ;;
  *) echo "Usage: rollback-git.sh [rules|scripts|gate|all] [commits_back]"; exit 1 ;;
esac
bash projects/saving-private-otto/scripts/compliance-gate.sh "coding" "qwen-plus-latest" "rollback-verify" && echo "✅ Post-rollback verify passed" || echo "❌ Verify FAILED"
