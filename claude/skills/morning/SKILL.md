---
name: morning
description: >
  Daily briefing: unified status check across all systems. Unread email counts,
  open GitHub issues, active workplans, todos, system health. Use when user
  says "morning", "daily briefing", "status", "what's going on", "catch me up",
  "what did I miss", or starts a new day.
---

# Morning Briefing Skill

Run a unified daily status check across all systems. Output a concise dashboard.

## Steps

### 1. Unread Emails

Check unread count across accounts via IMAP. Do NOT read message bodies, only count.

<!-- Customize: replace with your email accounts -->

```python
import imaplib

accounts = [
    # ("email@example.com", "app-password", "imap.gmail.com"),
]

for email, pw, server in accounts:
    try:
        m = imaplib.IMAP4_SSL(server)
        m.login(email, pw)
        m.select("INBOX", readonly=True)  # readonly preserves unread status
        _, data = m.search(None, "UNSEEN")
        count = len(data[0].split()) if data[0] else 0
        print(f"{email}: {count} unread")
        m.logout()
    except Exception as e:
        print(f"{email}: ERROR {e}")
```

Use `readonly=True` (or `BODY.PEEK[]` for message reads) to preserve unread status.

### 2. Open GitHub Issues

<!-- Customize: replace with your projects and gh account aliases -->

```bash
# Switch to project account, list issues
# gh-<project>
gh issue list --state open --limit 20 2>/dev/null | head -20
```

### 3. Active Workplans

```bash
find ~ -name "WORKPLAN-*.md" -mtime -30 2>/dev/null | sort
```

### 4. Todos

<!-- Customize: point to your todo file -->
```bash
cat ~/path/to/todos.md 2>/dev/null
```

### 5. System Health (Abbreviated)

```bash
# Docker containers
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null

# Orphan check
pgrep -f "chrome-headless-shell|remotion|playwright" | wc -l
```

## Output Format

Present as a concise dashboard table:

```
## Morning Briefing - YYYY-MM-DD

### Unread Email
| Account               | Unread |
|-----------------------|--------|
| work@example.com      | 3      |
| personal@example.com  | 0      |

### Open GitHub Issues
| Project    | Count | Top Issue               |
|------------|-------|-------------------------|
| my-project | 4     | #125 Critical bug (P0)  |

### Active Workplans
- WORKPLAN-20260315-feature.md (12d ago)

### Todos
[contents of todo file]

### System Health
| Container  | Status  |
|------------|---------|
| my-app     | Up 3d   |

Orphan processes: 0
```

Keep it scannable. No prose. Tables and bullets only.
