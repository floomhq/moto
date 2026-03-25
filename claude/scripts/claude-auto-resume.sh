#!/bin/bash
# claude-auto-resume.sh - Wrapper for Claude Code that monitors for rate limits
# Sends a desktop notification when rate-limited, then resumes automatically.
#
# Usage: claude-auto-resume.sh [claude args...]
#
# Requires: claude CLI in PATH
# Optional: notify-send (Linux) or terminal-notifier (macOS) for notifications

set -euo pipefail

RATE_LIMIT_PATTERN="rate.limit\|too many requests\|429\|quota exceeded\|overloaded"
WAIT_SECONDS=60
MAX_RETRIES=10

notify() {
  local title="$1"
  local message="$2"

  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    if command -v terminal-notifier >/dev/null 2>&1; then
      terminal-notifier -title "$title" -message "$message" -sound default
    elif command -v osascript >/dev/null 2>&1; then
      osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
    fi
  else
    # Linux
    if command -v notify-send >/dev/null 2>&1; then
      notify-send "$title" "$message"
    fi
  fi

  echo "[$(date '+%H:%M:%S')] $title: $message" >&2
}

retry_count=0

while true; do
  # Run claude, capture output and exit code
  set +e
  OUTPUT=$(claude "$@" 2>&1)
  EXIT_CODE=$?
  set -e

  echo "$OUTPUT"

  # Check if output contains rate limit indicators
  if echo "$OUTPUT" | grep -qi "$RATE_LIMIT_PATTERN"; then
    retry_count=$((retry_count + 1))

    if [ $retry_count -ge $MAX_RETRIES ]; then
      notify "Claude Code" "Rate limited $MAX_RETRIES times. Giving up."
      exit 1
    fi

    notify "Claude Code - Rate Limited" "Attempt $retry_count/$MAX_RETRIES. Waiting ${WAIT_SECONDS}s before retry..."
    sleep "$WAIT_SECONDS"

    # Exponential backoff: double wait time each retry, cap at 5 minutes
    WAIT_SECONDS=$((WAIT_SECONDS * 2))
    [ $WAIT_SECONDS -gt 300 ] && WAIT_SECONDS=300

    continue
  fi

  # No rate limit, exit with claude's exit code
  exit $EXIT_CODE
done
