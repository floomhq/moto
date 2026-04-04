#!/bin/bash
# Block commands that minimize, hide, or close terminal windows
# This hook runs before Bash commands and blocks problematic ones

# Read the input JSON from stdin
INPUT=$(cat)

# Extract the command from the tool_input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Patterns that minimize/hide terminal windows
BLOCK_PATTERNS=(
    "set visible of process.*Terminal.*to false"
    "set visible of process.*iTerm.*to false"
    "set miniaturized of.*window.*to true"
    "minimize.*Terminal"
    "minimize.*iTerm"
    "tell application.*Terminal.*to close"
    "tell application.*iTerm.*to close"
    "keystroke.*h.*command down"  # Cmd+H to hide
    "set frontmost of process.*Terminal.*to false"
)

for pattern in "${BLOCK_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qiE "$pattern"; then
        echo "BLOCKED: This command would minimize/hide terminal windows, which is not allowed."
        echo "Pattern matched: $pattern"
        exit 1
    fi
done

# Command is allowed
exit 0
