#!/bin/bash
# PreToolUse hook for Bash - scan for secrets before git push
# Requires: gitleaks (https://github.com/gitleaks/gitleaks)

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only run on git push commands
if ! echo "$COMMAND" | grep -qE "git push"; then
    exit 0
fi

# Run gitleaks on staged changes
RESULT=$(gitleaks git --no-banner --staged 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "BLOCKED: Secrets detected in staged changes!"
    echo ""
    echo "$RESULT"
    echo ""
    echo "Fix: Remove the secrets, then try again."
    exit 2
fi

exit 0
