---
name: agents
description: >
  Scan running Claude sessions to see what other agents are working on.
  Use when asked "what are the other agents doing", "check other sessions",
  "what's running", "scan agents", "who's working on what", or before
  picking up new work to avoid overlap.
---

# Agents: Scan Running Claude Sessions

Runs `scan.sh` to inspect all tmux sessions running Claude and report what each is doing.

## Usage

```bash
bash ~/.claude/skills/agents/scripts/scan.sh          # all sessions
bash ~/.claude/skills/agents/scripts/scan.sh floom     # only floom/* sessions
bash ~/.claude/skills/agents/scripts/scan.sh openpaper  # only openpaper/* sessions
```

## What It Shows

Per session:
- **Session name** and start time
- **Working directory** and git branch
- **Context usage** (percentage of context window used)
- **Mode** (plan mode, accept edits, etc.)
- **Current activity** (spinner line showing what Claude is actively doing)
- **Current task** (bullet point showing tool/task in progress)
- **Last user message** (what the user asked)

## How to Respond

1. Run the scan with the relevant project filter
2. Summarize what each session is doing in a table
3. Identify gaps: what work is NOT being covered by any session
4. Suggest isolated work that won't conflict with active sessions

## Technical Notes

- Uses `tmux capture-pane` to read screen content (most reliable method)
- Filters sessions by checking `pstree` for claude processes
- Parses the Claude Code status line for directory, context, and mode
- Optional project filter matches against session names
