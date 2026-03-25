#!/bin/bash
set -euo pipefail
# PreToolUse hook for Edit|Write|Bash - suggest /compact at tool call threshold
# Uses per-session counter files in /tmp. Threshold configurable via COMPACT_THRESHOLD env var.

INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
COUNTER_DIR="/tmp/claude-compact-counters"
COUNTER_FILE="${COUNTER_DIR}/${SESSION_ID}"

mkdir -p "$COUNTER_DIR"

# Clean counter files older than 24h (prevents /tmp accumulation)
find "$COUNTER_DIR" -type f -mtime +0 -delete 2>/dev/null || true

# Read current count, increment
COUNT=0
[[ -f "$COUNTER_FILE" ]] && COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

THRESHOLD=${COMPACT_THRESHOLD:-50}
if [[ $COUNT -eq $THRESHOLD ]]; then
  echo "Tool call #${COUNT}: consider /compact if transitioning phases." >&2
elif [[ $COUNT -gt $THRESHOLD ]] && (( (COUNT - THRESHOLD) % 25 == 0 )); then
  echo "Tool call #${COUNT}: consider /compact." >&2
fi
exit 0
