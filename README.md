# claude-setup

A battle-tested Claude Code configuration for developers who use Claude as their primary coding partner. Includes CLAUDE.md templates, safety hooks, 30+ skills, server infrastructure, browser automation, WhatsApp/Gmail integration, and terminal workflow tools.

This is the full stack that powers a real production workflow, open-sourced and templated for reuse.

## What's Included

| Directory | What | Why |
|-----------|------|-----|
| `claude/` | CLAUDE.md templates, hooks, scripts, skills, memory system | The core Claude Code config |
| `server/` | Systemd services, safety utilities, browser automation, tmux/bash | Dev server infrastructure |
| `whatsapp/` | OpenClaw gateway, verified send, SQLite contact lookup | WhatsApp messaging integration |
| `gmail/` | IMAP integration, multi-account email checking | Email access for Claude |
| `cron/` | Job templates, health checks, safe-pipeline usage | Recurring task automation |

## Quick Start

```bash
git clone https://github.com/buildingopen/claude-setup.git
cd claude-setup
./install.sh
```

The install script symlinks configs into `~/.claude/` and prompts for environment variables.

## Core Components

### CLAUDE.md Templates

Two templates that encode months of iteration on how to make Claude Code reliable:

- **`claude/CLAUDE.md`** - Global config (`~/.claude/CLAUDE.md`). Engineering principles, self-audit checklist, error recovery patterns, communication standards, quality gates. This is the file that makes Claude stop saying "should work" and start verifying.
- **`claude/CLAUDE-project.md`** - Per-project template. Tech stack, key files, testing conventions, deployment config. Drop into any project root.

Key patterns in the global CLAUDE.md:
- **Read First, Code Later** - 80% reading, 20% writing. No code changes without understanding context.
- **Self-Audit** - No completion claims without fresh verification evidence. BANNED: "should work now"
- **Rationalization Red Flags** - Table of thoughts that signal the agent is about to skip process
- **Error Recovery** - Data-driven rules from 10,000+ error analysis (e.g., never retry a blocked hook)
- **Ripple Check** - After every change, audit the diff for env vars, dependencies, breaking changes

### Safety Hooks

12 hooks that prevent Claude from doing damage. Wired into `settings.json` and triggered automatically.

| Hook | Event | What It Does |
|------|-------|-------------|
| `block-destructive.sh` | PreToolUse (Bash) | Blocks `rm -rf /`, `git reset --hard`, `DROP TABLE`, `curl\|bash` |
| `cost-tracker.sh` | Stop | Tracks token costs per model/session to `costs.jsonl` |
| `protect-sensitive-files.sh` | PreToolUse (Write/Edit) | Blocks writes to `.pem`, `.key`, `id_rsa`, credentials |
| `protect-config-files.sh` | PreToolUse (Write/Edit) | Blocks editing linter/formatter configs to bypass checks |
| `scan-secrets-before-push.sh` | PreToolUse (Bash) | Runs gitleaks before `git push` |
| `enforce-package-manager.sh` | PreToolUse (Bash) | Detects lock file, blocks wrong package manager |
| `suggest-compact.sh` | PreToolUse (Edit/Write/Bash) | Counts tool calls, suggests `/compact` at threshold |
| `post-compaction-recall.sh` | PreToolUse (any) | Detects post-compaction, suggests session-recall |
| `enforce-server-routing.sh` | PreToolUse (Bash) | Blocks CPU-heavy tasks locally, routes to dev server |
| `gemini-audit.sh` + `.py` | Stop | Opt-in Gemini quality gate: scores output 1-10, blocks if < 10 |
| `block-wa-send.sh` | PreToolUse (Bash) | Blocks unverified WhatsApp sends |

See [`claude/hooks/README.md`](claude/hooks/README.md) for setup instructions.

### Scripts

| Script | What It Does |
|--------|-------------|
| `gemini-fetch.sh` | Fetch blocked URLs via Gemini API (fallback for WebFetch) |
| `claude-auto-resume.sh` | Auto-retry on rate limits with exponential backoff |
| `claude-rate-limit-watcher.sh` | Background daemon monitoring for rate limits |
| `claude-switch.sh` | Switch between multiple Claude accounts |
| `sync-claude-config.sh` | Sync CLAUDE.md across machines via SCP |

### Skills (30+)

Reusable slash commands that extend Claude's capabilities. Each skill is a `.md` file with specialized prompts and workflows.

**Shipping & QA:** bouncer (Gemini quality gate), ship (pre-merge workflow), qa (autonomous testing), debug (systematic debugging)

**Planning & Review:** retro (weekly retrospective), compass (strategic planning), blast-radius (impact analysis), deep-audit (full repo audit via Gemini)

**Document Generation:** pdf, docx, pptx, xlsx manipulation

**Design & Content:** frontend-design, slide-design, canvas-design, algorithmic-art, linkedin-copy, cold-outreach

**Infrastructure:** deploy (multi-project), email-check (IMAP), mcp-builder, webapp-testing, browse (browser automation)

**Meta:** skill-creator (create new skills), subagent-templates, new-project (scaffolding), target-loop (verified iteration), doc-coauthoring

See [`claude/skills/README.md`](claude/skills/README.md) for the full list and how to create your own.

### Memory System

An external brain pattern that persists knowledge across Claude sessions:

- **`MEMORY.md`** - Concise index file (< 200 lines) loaded into every conversation
- **Topic files** - Detailed notes on specific subjects (e.g., `whatsapp-reading.md`, `visual-verification.md`)
- Claude auto-updates these files as it learns your preferences, discovers patterns, and receives corrections

See [`claude/memory/README.md`](claude/memory/README.md) for the pattern.

### Server Infrastructure

Templates for running Claude Code on a dedicated dev server:

- **Systemd services** - Chrome headless with CDP, SSHFS mounts, CDP keepalive
- **Safety utilities** - `safe-pipeline` (flock + timeout + cgroup memory cap), `safe-run`, process cleanup
- **Browser automation** - Chrome CDP setup, bridge keeper for session persistence
- **Multi-account management** - GitHub, Render, Supabase account switching patterns
- **Terminal workflow** - tmux config, bashrc with 999K history, background task queue

### WhatsApp Integration

Send and read WhatsApp messages through Claude via the OpenClaw gateway:

- Docker-based WhatsApp Web gateway
- Verified send script with SQLite contact lookup (prevents wrong-number sends)
- Direct SQLite DB reading for message history

### Gmail Integration

Check email across multiple IMAP accounts:

- Multi-account IMAP integration
- Preserves read/unread status (`BODY.PEEK[]`)
- Standalone email checker script

## Architecture

```
~/.claude/
  CLAUDE.md          -> claude/CLAUDE.md (global config)
  settings.json      -> claude/settings.json (hooks + permissions)
  .mcp.json          -> claude/.mcp.json (MCP servers)
  hooks/             -> claude/hooks/ (safety hooks)
  scripts/           -> claude/scripts/ (utilities)
  commands/          -> claude/skills/ (slash commands)
  metrics/           -> cost tracking output
  memory/            -> external brain (MEMORY.md + topic files)

your-project/
  CLAUDE.md          <- claude/CLAUDE-project.md (per-project config)
```

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI
- `jq` (used by hooks)
- `gitleaks` (optional, for secret scanning hook)
- `python3` (for Gemini audit hook and some scripts)
- A Gemini API key (optional, for gemini-fetch and gemini-audit)

## Configuration

1. Copy `.env.example` to `.env` and fill in your values
2. Edit `claude/CLAUDE.md` to match your workflow
3. Update server SSH aliases in scripts if using multi-machine setup
4. Replace `$HOME` paths in `settings.json` with your actual home directory (or let `install.sh` handle it)

## Related Projects

- [openclaw-setup](https://github.com/buildingopen/openclaw-setup) - WhatsApp gateway setup (subset of this repo)
- [session-recall](https://www.npmjs.com/package/session-recall) - Recover context after Claude compaction

## License

MIT
