#!/bin/bash
RULES_DIR="$HOME/.openclaw/workspace/projects/saving-private-otto/rules"
HASHES_FILE="$HOME/.openclaw/workspace/projects/saving-private-otto/scripts/.rules-hashes"
shasum -a 256 "$RULES_DIR"/*.md > "$HASHES_FILE"
echo "✅ Rules hashes updated"
