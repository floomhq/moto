#!/bin/bash
set -euo pipefail
# Stop hook - track token costs per model per session
# Writes JSONL entries to ~/.claude/metrics/costs.jsonl

INPUT=$(cat)
INPUT_TOKENS=$(echo "$INPUT" | jq -r '.usage.input_tokens // 0' 2>/dev/null)
OUTPUT_TOKENS=$(echo "$INPUT" | jq -r '.usage.output_tokens // 0' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
MODEL=$(echo "$INPUT" | jq -r '.model // "unknown"' 2>/dev/null)

[[ "$MODEL" == "unknown" ]] && MODEL="${CLAUDE_MODEL:-unknown}"
[[ "$INPUT_TOKENS" == "0" && "$OUTPUT_TOKENS" == "0" ]] && exit 0

case "$MODEL" in
  *haiku*)  IN_RATE=0.80; OUT_RATE=4.00 ;;
  *sonnet*) IN_RATE=3.00; OUT_RATE=15.00 ;;
  *opus*)   IN_RATE=15.00; OUT_RATE=75.00 ;;
  *)        IN_RATE=3.00; OUT_RATE=15.00 ;;
esac

COST=$(awk -v it="$INPUT_TOKENS" -v ir="$IN_RATE" -v ot="$OUTPUT_TOKENS" -v or_="$OUT_RATE" \
  'BEGIN {printf "%.6f", (it * ir + ot * or_) / 1000000}')

mkdir -p "$HOME/.claude/metrics"

jq -nc \
  --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --arg sid "$SESSION_ID" \
  --arg model "$MODEL" \
  --argjson in "$INPUT_TOKENS" \
  --argjson out "$OUTPUT_TOKENS" \
  --arg cost "$COST" \
  '{timestamp:$ts, session_id:$sid, model:$model, input_tokens:$in, output_tokens:$out, estimated_cost_usd:$cost}' \
  >> "$HOME/.claude/metrics/costs.jsonl"

exit 0
