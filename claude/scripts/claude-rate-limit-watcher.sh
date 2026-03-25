#!/bin/bash
# claude-rate-limit-watcher.sh - Background daemon that monitors for Claude rate limits
# Watches a log file or terminal output and sends notifications when rate limits hit.
#
# Usage:
#   claude-rate-limit-watcher.sh start   - Start the watcher daemon
#   claude-rate-limit-watcher.sh stop    - Stop the watcher daemon
#   claude-rate-limit-watcher.sh status  - Check if watcher is running
#
# The watcher monitors ~/.claude/bash-commands.log and system logs for rate limit patterns.
# Configure WATCH_FILE to point to your Claude output log.

set -euo pipefail

PID_FILE="/tmp/claude-rate-limit-watcher.pid"
WATCH_FILE="${CLAUDE_LOG_FILE:-$HOME/.claude/rate-limit-watch.log}"
CHECK_INTERVAL=5

RATE_LIMIT_PATTERNS=(
  "rate.limit"
  "too many requests"
  "429"
  "quota exceeded"
  "overloaded"
  "capacity"
)

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    *)      echo "unknown" ;;
  esac
}

notify() {
  local title="$1"
  local message="$2"
  local os
  os=$(detect_os)

  case "$os" in
    macos)
      if command -v terminal-notifier >/dev/null 2>&1; then
        terminal-notifier -title "$title" -message "$message" -sound default
      elif command -v osascript >/dev/null 2>&1; then
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
      fi
      ;;
    linux)
      if command -v notify-send >/dev/null 2>&1; then
        notify-send -u critical "$title" "$message"
      fi
      # Also try writing to all user terminals as fallback
      if command -v wall >/dev/null 2>&1; then
        echo "$title: $message" | wall 2>/dev/null || true
      fi
      ;;
  esac

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] RATE LIMIT: $message" >> "${WATCH_FILE}.alerts"
}

build_pattern() {
  local pattern=""
  for p in "${RATE_LIMIT_PATTERNS[@]}"; do
    [ -n "$pattern" ] && pattern="$pattern\|"
    pattern="$pattern$p"
  done
  echo "$pattern"
}

run_watcher() {
  local pattern
  pattern=$(build_pattern)
  local last_size=0

  while true; do
    if [ -f "$WATCH_FILE" ]; then
      current_size=$(wc -c < "$WATCH_FILE" 2>/dev/null || echo 0)

      if [ "$current_size" -gt "$last_size" ]; then
        # Read only new content
        new_content=$(tail -c +"$((last_size + 1))" "$WATCH_FILE" 2>/dev/null || true)

        if echo "$new_content" | grep -qi "$pattern"; then
          matched_line=$(echo "$new_content" | grep -i "$pattern" | head -1)
          notify "Claude Rate Limit Detected" "$(echo "$matched_line" | head -c 200)"
        fi

        last_size=$current_size
      fi
    fi

    sleep "$CHECK_INTERVAL"
  done
}

case "${1:-}" in
  start)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Watcher already running (PID $(cat "$PID_FILE"))"
      exit 0
    fi

    mkdir -p "$(dirname "$WATCH_FILE")"
    touch "$WATCH_FILE"

    # Start in background
    run_watcher &
    WATCHER_PID=$!
    echo "$WATCHER_PID" > "$PID_FILE"
    echo "Rate limit watcher started (PID $WATCHER_PID)"
    echo "Monitoring: $WATCH_FILE"
    echo "Alerts log: ${WATCH_FILE}.alerts"
    ;;

  stop)
    if [ -f "$PID_FILE" ]; then
      PID=$(cat "$PID_FILE")
      if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm -f "$PID_FILE"
        echo "Watcher stopped (PID $PID)"
      else
        rm -f "$PID_FILE"
        echo "Watcher was not running (stale PID file removed)"
      fi
    else
      echo "No watcher running"
    fi
    ;;

  status)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
      echo "Watcher running (PID $(cat "$PID_FILE"))"
      echo "Monitoring: $WATCH_FILE"
      if [ -f "${WATCH_FILE}.alerts" ]; then
        alert_count=$(wc -l < "${WATCH_FILE}.alerts")
        echo "Total alerts: $alert_count"
        echo "Last alert:"
        tail -1 "${WATCH_FILE}.alerts"
      fi
    else
      echo "Watcher not running"
    fi
    ;;

  *)
    echo "Usage: claude-rate-limit-watcher.sh <start|stop|status>"
    echo ""
    echo "Environment variables:"
    echo "  CLAUDE_LOG_FILE  - File to monitor (default: ~/.claude/rate-limit-watch.log)"
    exit 1
    ;;
esac
