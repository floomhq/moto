#!/bin/bash
# PostCompact/SessionStart hook: Restore state into context
set -euo pipefail

STATE_FILE=".claude/precompact-state/last-state.md"
[[ ! -f "$STATE_FILE" ]] && exit 0

echo "Context was compacted. Here is your saved state from before compaction:"
echo ""
cat "$STATE_FILE"
