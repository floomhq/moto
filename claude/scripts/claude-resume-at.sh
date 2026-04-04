#!/bin/bash
# claude-resume-at.sh - Schedule Claude Code to resume at a specific time
#
# Usage:
#   claude-resume-at 11:30am              - Resume at 11:30am today
#   claude-resume-at 11:30am "my prompt"  - Resume with a specific prompt
#   claude-resume-at cancel               - Cancel scheduled resume
#
# This uses macOS 'at' command to schedule the job.
# Make sure 'at' is enabled: sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.atrun.plist

if [ "$1" = "cancel" ]; then
    atq | while read job rest; do
        atrm "$job" 2>/dev/null
    done
    echo "Cancelled all scheduled jobs"
    exit 0
fi

if [ -z "$1" ]; then
    echo "Usage: claude-resume-at <time> [prompt]"
    echo "       claude-resume-at cancel"
    echo ""
    echo "Examples:"
    echo "  claude-resume-at 11:30am"
    echo "  claude-resume-at 14:00"
    echo "  claude-resume-at 11:30am 'continue the previous task'"
    exit 1
fi

TIME="$1"
PROMPT="${2:-}"

# Create the resume script
RESUME_SCRIPT=$(mktemp)
cat > "$RESUME_SCRIPT" << 'INNEREOF'
#!/bin/bash
# Open new Terminal and run claude --continue
osascript <<EOF
tell application "Terminal"
    activate
    do script "claude --continue"
end tell
EOF

# Notification
osascript -e 'display notification "Claude Code resuming..." with title "Rate Limit Reset"'
INNEREOF

chmod +x "$RESUME_SCRIPT"

# Schedule with at
echo "$RESUME_SCRIPT" | at "$TIME" 2>&1

if [ $? -eq 0 ]; then
    echo "Scheduled Claude resume at $TIME"
    echo "A new Terminal will open with 'claude --continue'"
    echo ""
    echo "To cancel: claude-resume-at cancel"
else
    echo "Failed to schedule. Make sure 'at' is enabled:"
    echo "  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.atrun.plist"
fi
