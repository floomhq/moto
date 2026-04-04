#!/bin/bash
# Claude PreToolUse hook: auto-route heavy commands through sandbox
# Install: add to ~/.claude/settings.json under PreToolUse hooks
#
# This hook intercepts Bash commands that match known memory-hungry patterns
# and rewrites them to run inside the sandbox wrapper.

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only intercept Bash tool calls
if [[ "$TOOL" != "Bash" ]]; then
    exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
if [[ -z "$COMMAND" ]]; then
    exit 0
fi

# Skip if already sandboxed
if echo "$COMMAND" | grep -q "^sandbox "; then
    exit 0
fi
if echo "$COMMAND" | grep -q "systemd-run"; then
    exit 0
fi

# Skip SSH commands (they run on remote, not local)
if echo "$COMMAND" | grep -qE "^ssh "; then
    exit 0
fi

# Define patterns and their recommended limits
# Format: pattern|memory|cpu|timeout
SANDBOX_RULES=(
    "whisper|16G|400|30m"
    "faster-whisper|16G|400|30m"
    "whisperx|16G|400|30m"
    "ffmpeg|8G|400|15m"
    "remotion render|12G|400|20m"
    "npx remotion|12G|400|20m"
    "playwright|4G|200|10m"
    "puppeteer|4G|200|10m"
    "chrome-headless-shell|4G|200|10m"
    "chromium.*--headless|4G|200|10m"
    "torch\\.cuda|8G|400|20m"
    "transformers\\.|8G|400|20m"
    "python.*train|12G|400|30m"
    "pip install.*torch|8G|200|10m"
)

for rule in "${SANDBOX_RULES[@]}"; do
    IFS='|' read -r pattern mem cpu timeout <<< "$rule"
    if echo "$COMMAND" | grep -qiE "$pattern"; then
        # Output the rewritten command as a suggestion
        # Exit code 2 = block with message
        cat <<EOF
BLOCKED: Heavy task detected. Routing through sandbox for memory protection.

Pattern matched: $pattern
Recommended limits: memory=${mem}, cpu=${cpu}%, timeout=${timeout}

Run instead:
  sandbox -m $mem -c $cpu -t $timeout -- $COMMAND

Or if you need different limits:
  sandbox -m 32G -t 60m -- $COMMAND
EOF
        exit 2
    fi
done

# No match, allow through
exit 0
