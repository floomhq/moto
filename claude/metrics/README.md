# Cost Tracking System

Automated token usage and cost tracking for Claude Code sessions.

## How It Works

Every Claude session writes cost data to a JSONL file via the Stop event hook. This creates an auditable log of model usage and estimated costs.

## Data Flow

1. **Stop event triggered** - When a Claude session ends or reaches a checkpoint
2. **Hook executes** - `~/.claude/hooks/cost-tracker.sh` captures:
   - Timestamp (ISO 8601)
   - Session ID
   - Model name
   - Input tokens
   - Output tokens
   - Estimated cost (USD)
3. **Written to JSONL** - One JSON object per line in `costs.jsonl`
4. **Queryable via jq** - Analyze costs using standard Unix tools

## File Location

```
~/.claude/costs.jsonl
```

Each line is a valid JSON object:
```json
{"timestamp":"2026-03-25T10:30:45Z","session_id":"abc123","model":"claude-haiku-4-5-20251001","input_tokens":5000,"output_tokens":2000,"cost_usd":0.0045}
{"timestamp":"2026-03-25T10:45:12Z","session_id":"def456","model":"claude-opus-4-6","input_tokens":10000,"output_tokens":5000,"cost_usd":0.15}
```

## Cost Calculation

Pricing (as of 2026-03-25):
- **Claude Haiku 4.5**: $0.80/1M input, $4.00/1M output
- **Claude Opus 4.6**: $3.00/1M input, $15.00/1M output

Formula:
```
cost = (input_tokens / 1_000_000) * input_rate + (output_tokens / 1_000_000) * output_rate
```

## Query Examples

### Total Cost (All Time)

```bash
jq '[.[].cost_usd] | add' ~/.claude/costs.jsonl
# Output: 12.45
```

### Cost Today

```bash
jq --arg date "2026-03-25" \
  '[.[] | select(.timestamp | startswith($date)) | .cost_usd] | add' \
  ~/.claude/costs.jsonl
# Output: 3.20
```

### Cost by Model

```bash
jq 'group_by(.model) | map({model: .[0].model, total: (map(.cost_usd) | add)})' \
  ~/.claude/costs.jsonl
# Output:
# [{"model":"claude-haiku-4-5-20251001","total":4.50},
#  {"model":"claude-opus-4-6","total":7.95}]
```

### Cost by Day

```bash
jq 'group_by(.timestamp | split("T")[0]) | map({date: .[0].timestamp | split("T")[0], cost: (map(.cost_usd) | add)})' \
  ~/.claude/costs.jsonl
# Output:
# [{"date":"2026-03-24","cost":5.20},
#  {"date":"2026-03-25","cost":7.25}]
```

### Sessions Over $1 USD

```bash
jq '.[] | select(.cost_usd > 1.0) | "\(.timestamp) - \(.model) - $\(.cost_usd)"' \
  ~/.claude/costs.jsonl
# Output:
# "2026-03-25T10:45:12Z - claude-opus-4-6 - $2.15"
```

### Average Cost per Session

```bash
jq '[.[] | .cost_usd] | {count: length, total: add, average: (add / length)}' \
  ~/.claude/costs.jsonl
# Output:
# {"count":42,"total":12.45,"average":0.296}
```

### Top 10 Most Expensive Sessions

```bash
jq 'sort_by(-.cost_usd) | .[0:10] | .[] | "\(.timestamp) - \(.model) - \(.input_tokens) in, \(.output_tokens) out - $\(.cost_usd)"' \
  ~/.claude/costs.jsonl
```

## The /cost Skill

Claude Code includes a `/cost` skill that generates reports automatically:

```bash
# Weekly cost summary
/cost --period week

# Cost by model
/cost --group-by model

# Markdown report
/cost --format markdown > cost-report.md
```

## Backup & Analysis

### Monthly Export
```bash
# Export costs as CSV
jq -r '.[] | [.timestamp, .session_id, .model, .input_tokens, .output_tokens, .cost_usd] | @csv' \
  ~/.claude/costs.jsonl > costs-march-2026.csv
```

### Retention
- **No automatic cleanup** - costs.jsonl grows indefinitely
- **Suggested archival** - After 6 months, move to `costs-YYYY-MM.jsonl`
- **Script to archive**:
  ```bash
  #!/bin/bash
  month=$(date -d "3 months ago" +%Y-%m)
  cutoff=$(date -d "3 months ago" +%s)
  jq --arg cutoff "$cutoff" '.[] | select(.timestamp | fromdateiso8601 < ($cutoff | tonumber))' \
    ~/.claude/costs.jsonl > costs-${month}.jsonl
  ```

## Performance Optimization

For large costs.jsonl files (1000+ sessions):

### Index by date (bash)
```bash
# Create a sorted, cached version
sort ~/.claude/costs.jsonl > ~/.claude/costs-sorted.jsonl

# Query faster
jq --arg date "2026-03-25" \
  '.[] | select(.timestamp | startswith($date))' \
  ~/.claude/costs-sorted.jsonl | jq -s '[.[] | .cost_usd] | add'
```

### Compress old entries (bash)
```bash
# Keep last 1000 entries uncompressed, archive rest
tail -1000 ~/.claude/costs.jsonl > /tmp/recent.jsonl
head -n -1000 ~/.claude/costs.jsonl | gzip > ~/.claude/costs-archive.jsonl.gz
cat /tmp/recent.jsonl > ~/.claude/costs.jsonl
```

## Integration with CI/CD

### Cost check on PR (GitHub Actions)
```yaml
- name: Check token cost
  run: |
    cost_usd=$(jq '[.[] | select(.timestamp | startswith("'$(date +%Y-%m-%d)'"))] | map(.cost_usd) | add' ~/.claude/costs.jsonl)
    if (( $(echo "$cost_usd > 5.0" | bc -l) )); then
      echo "Daily cost exceeded $5 USD"
      exit 1
    fi
```

## Troubleshooting

### No costs.jsonl file
- Ensure `~/.claude/hooks/cost-tracker.sh` exists and is executable
- Check if sessions are writing to the file: `ls -l ~/.claude/costs.jsonl`
- Verify the hook is registered in Claude Code config

### Missing entries
- Cost tracking started after session began - wait for next session's end event
- Check Stop event is firing: Look for Hook event in session logs

### Incorrect calculations
- Verify pricing rates match Claude's current pricing (rates change quarterly)
- Check jq syntax for calculation formulas
- Confirm model name spelling matches pricing table

## What's Tracked

| Field | Example | Notes |
|-------|---------|-------|
| timestamp | `2026-03-25T10:30:45Z` | ISO 8601, UTC |
| session_id | `abc123def456` | Unique per Claude Code session |
| model | `claude-opus-4-6` | Model ID used for this session |
| input_tokens | `5000` | Tokens processed as input |
| output_tokens | `2000` | Tokens generated as output |
| cost_usd | `0.0045` | Estimated cost in USD |

## Privacy

- Costs only track tokens and model, not conversation content
- No message text, file contents, or user data is logged
- Safe to share cost reports with team members

## Best Practices

1. **Review weekly** - Check `/cost --period week` every Friday
2. **Archive monthly** - Move old costs to costs-YYYY-MM.jsonl
3. **Alert on spikes** - Set alert if daily cost > $10
4. **Track by project** - If using session IDs, correlate with git branches
5. **Version your pricing** - Document when pricing rates changed in comments

## See Also

- `~/.claude/hooks/cost-tracker.sh` - Hook that writes cost data
- `~/.claude/costs.jsonl` - The data file
- `/cost` skill - Generate cost reports
- Session logs - `~/.claude/projects/*/` for detailed trace data
