#!/usr/bin/env bash
# PreToolUse hook for Bash|Read|Edit|Write|Glob|Grep
# Post-compaction auto-recovery hook for session-recall.
# Fires on first tool call per Claude session. If the session was compacted,
# emits a stderr reminder that MCP recovery tools are available.
#
# CRITICAL: Must ALWAYS output {"decision": "approve"} on stdout, even on error.
# A missing/malformed JSON response blocks the tool call.

# Safety: always approve, no matter what happens
trap 'echo "{\"decision\": \"approve\"}"' EXIT

# --- Find a session-stable identifier (Claude's PID) ---
# Walk the process tree via `ps`. Works on Linux and macOS.
CLAUDE_PID=""
PID=$$
for _ in 1 2 3 4 5 6 7 8 9 10; do
    PARENT=$(ps -o ppid= -p "$PID" 2>/dev/null | tr -d ' ') || break
    [ -z "$PARENT" ] || [ "$PARENT" = "1" ] || [ "$PARENT" = "0" ] && break
    PID="$PARENT"
    # Check process name via ps (portable, no /proc dependency)
    PNAME=$(ps -o comm= -p "$PID" 2>/dev/null | tr -d ' ') || continue
    case "$PNAME" in
        claude|claude-code|node) CLAUDE_PID="$PID"; break ;;
    esac
done

FLAG="/tmp/session-recall-post-compact-${CLAUDE_PID:-$$}"

# Already checked this session? Exit (trap handles approve).
[ -f "$FLAG" ] && exit 0

# Mark as checked (regardless of compaction status)
touch "$FLAG" 2>/dev/null || true

# Check compaction. Try PATH, then common install paths, then npx.
RECALL=""
if command -v session-recall >/dev/null 2>&1; then
    RECALL="session-recall"
elif [ -x /usr/local/bin/session-recall ]; then
    RECALL="/usr/local/bin/session-recall"
elif command -v npx >/dev/null 2>&1; then
    RECALL="npx -y session-recall"
fi

if [ -n "$RECALL" ]; then
    if $RECALL --check-compaction 2>/dev/null; then
        echo "Context was compacted. session-recall MCP tools available: recall_search, recall_report, recall_recent" >&2
    fi
fi

# trap EXIT handles the approve JSON
exit 0
