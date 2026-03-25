#!/bin/bash
# PreToolUse hook for Bash - block direct WhatsApp message sends
# Forces sends through a verified send script that checks contact numbers
# from the SQLite DB first, preventing messages to wrong contacts.
#
# Customize the grep patterns below for your WhatsApp gateway CLI name.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$COMMAND" ] && echo '{"decision": "approve"}' && exit 0

# Block direct gateway sends (customize pattern for your WhatsApp gateway)
if echo "$COMMAND" | grep -qiE '(clawdbot-ctl|openclaw)\s+send'; then
  echo '{"decision": "block", "reason": "BLOCKED: Direct WhatsApp send is prohibited. Use safe-wa-send script which verifies contact numbers from the SQLite DB first."}'
  exit 0
fi

if echo "$COMMAND" | grep -qiE 'docker\s+exec.*whatsapp.*send'; then
  echo '{"decision": "block", "reason": "BLOCKED: Direct docker exec send to WhatsApp container is prohibited. Use safe-wa-send script instead."}'
  exit 0
fi

echo '{"decision": "approve"}'
