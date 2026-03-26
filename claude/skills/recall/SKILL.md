---
name: recall
description: >
  Post-compaction context recovery. Reconstruct working context from session
  transcripts using MCP tools or CLI. Use when user says "recall", "recover
  context", "what was I doing", "after compaction", "lost context", or when
  context has been compacted and needs reconstruction.
---

# Recall Skill

Recover working context after compaction. JSONL transcripts are NEVER deleted - they persist at `~/.claude/projects/*/`. Compaction only clears the live context window.

## Workflow

### Step 1: Get Recent Messages

Use MCP tool (preferred):
```
recall_recent 5
```

CLI fallback:
```bash
session-recall --recent 10
```

### Step 2: Find Active Task

Search for what was being worked on:
```
recall_search "workplan|task|fixing|implementing|debugging"
```

CLI fallback:
```bash
session-recall "workplan task fixing implementing"
```

### Step 3: Find Active Workplan

```bash
find . ~/Downloads /root -name "WORKPLAN-*.md" -mtime -1 2>/dev/null | sort
```

Read the most recent one if found. It is the external brain - re-read it fully before continuing.

### Step 4: Reconstruct Context

From the recalled messages and workplan, identify:
- What task was in progress
- What step was last completed
- What the next step is
- Any errors or blockers encountered

Use targeted searches if needed:
```
recall_search "error|failed|blocked|next step"
recall_decisions
```

CLI fallback:
```bash
session-recall --report
session-recall "error failed blocked"
```

### Step 5: Persist Lessons (Optional)

If patterns or corrections were found in the session that should be saved:
```
recall_apply
```

## MCP Tools Reference

| Tool | Purpose |
|------|---------|
| `recall_search "keyword"` | Search transcripts by keyword |
| `recall_recent N` | Get last N human messages |
| `recall_report` | Analyze errors, retries, corrections |
| `recall_decisions` | Find key decisions made |
| `recall_list` | List available sessions |
| `recall_apply` | Persist lessons to CLAUDE.md/MEMORY.md |

## CLI Fallback Reference

```bash
session-recall "keyword"       # Search current session
session-recall --recent 10     # Last 10 human messages
session-recall --report        # Session analysis
session-recall --all 5         # Cross-session (last 5 sessions)
```

## Key Fact

Transcripts are at `~/.claude/projects/*/`. They are append-only JSONL files. Compaction does not touch them. Any content from any past session is recoverable. Never say "can't recover" compacted content.
