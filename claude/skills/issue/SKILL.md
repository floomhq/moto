---
name: issue
description: >
  GitHub issue management with multi-account support. Creates, lists, views,
  and closes issues with correct labels and conventions per project. Use when
  user says "create issue", "file bug", "issue for X", "list issues", "open
  issues", "triage", or "close issue".
---

# GitHub Issue Management

Manage GitHub issues across multiple accounts. Always use GitHub Issues, never
ISSUES.md files.

## Step 1: Detect Project and Switch Account

Determine which project from context (cwd, user mention). If ambiguous, ask.

<!-- Customize: replace with your projects and gh account aliases -->

| Project | Account alias | Repo |
|---------|--------------|------|
| project-a | `gh-project-a` | auto-detect from cwd |
| project-b | `gh-project-b` | `org/repo-name` |
| personal | `gh-personal` | auto-detect from cwd |

Check current account first:
```bash
gh auth status
```

Switch to correct account before any `gh` command.

## Step 2: Execute the Right Command

### Create Issue

```bash
gh issue create --title "..." --label "LABELS" --body "BODY"
```

<!-- Customize: define your label conventions per project -->

For projects with strict labeling: ALWAYS include required labels.
Ask the user for priority if not provided.

For repos you're not in the directory of:
```bash
gh issue create --repo org/repo-name --title "..." --body "..."
```

### List Issues

```bash
gh issue list --state open
gh issue list --label "P0" --state open
gh issue list --label "P0,frontend" --state open
```

### View Issue

```bash
gh issue view 123
```

### Close Issue

Always close with a comment explaining the resolution:
```bash
gh issue close 123 --comment "Fixed in commit abc123. Verified on live site."
```

## Label Conventions

<!-- Customize: define label conventions per project -->

### Example: Priority + Area labeling

| Type | Labels |
|------|--------|
| Priority | `P0` (critical), `P1` (high), `P2` (medium), `P3` (low) |
| Area | `frontend`, `backend`, `pipeline` |

Always include one from each group. If user doesn't specify priority, ask.

## Issue Body Format

For bug reports:
```
**Steps to reproduce:**
1.
2.

**Expected:**

**Actual:**

**Context:** [URL, env, user account if relevant]
```

For feature requests:
```
**Problem:**

**Proposed solution:**

**Acceptance criteria:**
- [ ]
```

Keep bodies concise. No filler. Facts only.

## Rules

- NEVER use ISSUES.md files. GitHub Issues only.
- ALWAYS verify the active account matches the project before any write operation.
- When closing an issue: ALWAYS include a comment with the fix reference.
- If the project cannot be determined from context, ask before proceeding.
