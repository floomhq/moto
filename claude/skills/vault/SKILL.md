---
name: vault
description: >
  Context vault operations: read/update todos, add log entries, search vault
  content, read strategy/project docs, update project files. Use when user says
  "vault", "add todo", "update todos", "log entry", "search vault", "check todos",
  "context vault", "add to log", or any operation on a personal context vault.
---

# Vault

<!-- Customize: set your vault path and git remote -->

Context vault at `<VAULT_PATH>`. A mono-repo for all non-code context: strategy, legal, taxes, pitches, brand, projects.

## Sensitivity Rules

<!-- Customize: define your sensitivity levels per folder -->

| Level | Folders | Rule |
|-------|---------|------|
| CRITICAL | `legal/`, `taxes/` | NEVER echo content. Acknowledge existence only. |
| HIGH | `cv/`, `team/` | Summarize; no verbatim PII (DOB, ID numbers, salaries) |
| MEDIUM | `secretary/`, `strategy/`, `projects/` | Read and share freely; redact API keys/passwords |
| LOW | `brand/`, `content/`, `research/` | Read and share freely |

**Never echo:** API keys, passwords, legal PII, contract amounts, tax figures.

## Commit Rules

<!-- Customize: set your commit prefix -->

- Prefix: `context-agent:` (e.g., `context-agent: update todos`)
- Never include sensitive data in commit messages
- Always push after committing

## Operations

### 1. Update Todos

```bash
cd <VAULT_PATH> && git pull
# Read current state
cat secretary/todos.md
# Edit: add/remove/update items with Edit tool
git add secretary/todos.md
git commit -m "context-agent: update todos"
git push
```

### 2. Add Log Entry

Target file: `secretary/logs/YYYY-MM.md`

```bash
cd <VAULT_PATH> && git pull
# Append timestamped entry: ## YYYY-MM-DD HH:MM UTC\n\n<entry text>\n
git add secretary/logs/$(date +%Y-%m).md
git commit -m "context-agent: add log entry"
git push
```

### 3. Search Vault

```bash
grep -r "keyword" <VAULT_PATH>/ --include="*.md" -l
# Then read matching files (respecting sensitivity rules above)
```

### 4. Read Strategy / Projects

```bash
ls <VAULT_PATH>/strategy/
cat <VAULT_PATH>/strategy/<file>.md
```

### 5. Update Project Docs

```bash
cd <VAULT_PATH> && git pull
# Edit file with Edit tool
git add projects/<file>.md
git commit -m "context-agent: update <project> docs"
git push
```

## Workflow Template

For any vault write operation:

1. `cd <VAULT_PATH> && git pull` (always pull first)
2. Read the target file (understand current state)
3. Edit with Edit tool
4. `git add <file> && git commit -m "context-agent: <action>" && git push`
5. Confirm to user without echoing CRITICAL content
