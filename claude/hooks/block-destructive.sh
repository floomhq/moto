#!/bin/bash
# PreToolUse hook for Bash - block destructive commands
# Prevents: rm -rf /, git force push, DROP TABLE, curl|bash, disk wipe

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

BLOCK_PATTERNS=(
    "rm -rf /"
    "rm -rf ~"
    "rm -rf \*"
    "push.*--force"
    "push -f"
    "reset --hard origin"
    "checkout \."
    "git restore \."
    "git clean -fd"
    "DROP TABLE"
    "drop table"
    "TRUNCATE"
    "truncate"
    "> /dev/sd"
    "mkfs\."
    "dd if=.*of=/dev"
    "curl.*\|.*bash"
    "curl.*\|.*sh"
    "wget.*\|.*bash"
    "wget.*\|.*sh"
)

for pattern in "${BLOCK_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qiE "$pattern"; then
        echo "BLOCKED: Destructive command detected: $pattern"
        exit 2
    fi
done

exit 0
