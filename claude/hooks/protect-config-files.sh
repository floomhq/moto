#!/bin/bash
set -euo pipefail
# PreToolUse hook for Write|Edit - block editing linter/formatter configs
# Agents should fix code to pass checks, not modify the checker config

FILE_PATH=$(jq -r '.tool_input.file_path // .tool_input.file // empty')
[[ -z "$FILE_PATH" ]] && exit 0

BASENAME=$(basename "$FILE_PATH")

case "$BASENAME" in
  .eslintrc*|.prettierrc*|biome.json|.ruff.toml|ruff.toml|\
  .shellcheckrc|.stylelintrc*|.markdownlint*)
    echo "BLOCKED: Do not modify linter/formatter config to pass checks. Fix the code instead." >&2
    exit 2
    ;;
esac
exit 0
