#!/bin/bash
# PreToolUse hook for Write|Edit - block writes to secrets, credentials, keys

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path
[ -z "$FILE" ] && exit 0

PROTECTED_PATTERNS=(
    "/secrets/"
    "credentials"
    "\.pem$"
    "\.key$"
    "id_rsa"
    "id_ed25519"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if echo "$FILE" | grep -qiE "$pattern"; then
        echo "BLOCKED: Cannot modify sensitive file matching: $pattern"
        echo "File: $FILE"
        exit 2
    fi
done

exit 0
