#!/bin/bash
set -euo pipefail
# PreToolUse hook for Bash - enforce correct package manager based on lock file
# Detects pnpm-lock.yaml, package-lock.json, or yarn.lock and blocks the wrong tool

CMD=$(jq -r '.tool_input.command // empty')
[[ -z "$CMD" ]] && exit 0
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

if [[ -f "$PROJECT_DIR/pnpm-lock.yaml" ]] && echo "$CMD" | grep -qE '^\s*npm\s'; then
  echo "BLOCKED: This project uses pnpm, not npm. Use pnpm instead." >&2
  exit 2
fi
if [[ -f "$PROJECT_DIR/package-lock.json" ]] && echo "$CMD" | grep -qE '^\s*(pnpm|yarn)\s'; then
  echo "BLOCKED: This project uses npm. Use npm instead." >&2
  exit 2
fi
if [[ -f "$PROJECT_DIR/yarn.lock" ]] && echo "$CMD" | grep -qE '^\s*(npm|pnpm)\s'; then
  echo "BLOCKED: This project uses yarn. Use yarn instead." >&2
  exit 2
fi
exit 0
