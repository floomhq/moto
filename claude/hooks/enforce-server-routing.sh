#!/bin/bash
# PreToolUse hook for Bash - block CPU-heavy commands locally, route to dev server
# Set CLAUDE_DEV_SERVER env var to your remote dev server (e.g., "myserver" or "user@host")
# Customize HEAVY_PATTERNS for your workflow

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

DEV_SERVER="${CLAUDE_DEV_SERVER:-}"
[ -z "$DEV_SERVER" ] && exit 0  # Skip if no dev server configured

# Allow SSH commands that delegate TO servers
if echo "$COMMAND" | grep -qiE "^ssh "; then
    exit 0
fi

HEAVY_PATTERNS=(
    "npx remotion render"
    "remotion render"
    "playwright.*chromium"
    "puppeteer"
    "chrome-headless-shell"
    "ffmpeg.*-i.*-vf"
    "ffmpeg.*scale="
    "whisper"
)

for pattern in "${HEAVY_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qiE "$pattern"; then
        echo "BLOCKED: CPU-heavy task detected. Run on $DEV_SERVER instead:"
        echo ""
        echo "  ssh $DEV_SERVER \"$pattern ...\""
        echo ""
        echo "Pattern matched: $pattern"
        exit 2
    fi
done

exit 0
