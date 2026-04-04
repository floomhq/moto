#!/bin/bash
# Rate Limit Auto-Resume Hook for Claude Code
#
# This hook detects rate limit messages and schedules automatic continuation.
#
# SETUP:
# 1. Make executable: chmod +x ~/.claude/hooks/rate-limit-auto-resume.sh
# 2. Add to ~/.claude/settings.json under hooks (see below)
#
# NOTE: This is a workaround until native support exists.
# Works on macOS. Linux would need modification (use `at` instead of launchd).

# Read input from stdin (hook receives context as JSON)
INPUT=$(cat)

# Check if this is a rate limit message
if echo "$INPUT" | grep -q "out of extra usage\|resets"; then
    # Try to extract reset time (format like "11:30am" or "2:30pm")
    RESET_TIME=$(echo "$INPUT" | grep -oE '[0-9]{1,2}:[0-9]{2}(am|pm)' | head -1)

    if [ -n "$RESET_TIME" ]; then
        # Log for debugging
        echo "[$(date)] Rate limit detected. Reset at: $RESET_TIME" >> ~/.claude/hooks/rate-limit.log

        # Convert to 24h format for scheduling
        HOUR=$(echo "$RESET_TIME" | cut -d: -f1)
        MIN=$(echo "$RESET_TIME" | cut -d: -f2 | sed 's/[ap]m//')
        AMPM=$(echo "$RESET_TIME" | grep -oE '(am|pm)')

        if [ "$AMPM" = "pm" ] && [ "$HOUR" -ne 12 ]; then
            HOUR=$((HOUR + 12))
        elif [ "$AMPM" = "am" ] && [ "$HOUR" -eq 12 ]; then
            HOUR=0
        fi

        # Calculate seconds until reset (add 60s buffer)
        NOW=$(date +%s)
        TARGET=$(date -j -f "%H:%M" "$HOUR:$MIN" +%s 2>/dev/null)

        # If target is in the past, assume next day
        if [ "$TARGET" -lt "$NOW" ]; then
            TARGET=$((TARGET + 86400))
        fi

        WAIT_SECONDS=$((TARGET - NOW + 60))

        # Schedule the resume using a background process
        # This sends a newline to the active terminal to trigger continuation
        (
            sleep $WAIT_SECONDS
            # Get the frontmost Terminal window and send Enter
            osascript -e 'tell application "Terminal" to do script "# Auto-resume triggered" in front window' 2>/dev/null
            echo "[$(date)] Auto-resume triggered after rate limit" >> ~/.claude/hooks/rate-limit.log
        ) &

        echo "[$(date)] Scheduled auto-resume in $WAIT_SECONDS seconds" >> ~/.claude/hooks/rate-limit.log
    fi
fi
