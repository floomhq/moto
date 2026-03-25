---
name: retro
description: >
  Run a retrospective on a completed sprint, project, or time period.
  Use when user says "retro", "retrospective", "what went well", "what did we learn",
  "review the week/sprint/project", or asks to reflect on recent work.
  Produces a structured reflection with actionable improvements.
---

# Retro Skill

## Purpose

A retrospective identifies what worked, what didn't, and how to improve. It's not a blame exercise - it's a learning exercise.

## Step 1: Gather context

Ask (if not already clear):
- What time period or project are we retrospecting?
- Were there specific goals set at the start?
- Are there any standout events (wins, blockers, incidents) to discuss?

## Step 2: Review what happened

Look at evidence from the period:
```bash
# Review recent commits
git log --oneline --since="1 week ago"

# Review closed issues
gh issue list --state closed --limit 20

# Review PRs merged
gh pr list --state merged --limit 20
```

## Step 3: Structure the retro

### What went well
- Accomplishments: what was shipped, completed, or improved
- Practices that worked: processes, tools, approaches that helped
- Unexpected wins

### What didn't go well
- Blocked or delayed items
- Technical debt incurred
- Communication gaps
- Estimates that were off

### Surprises
- Things that took longer than expected (and why)
- Things that were easier than expected
- External factors that changed the plan

### Learnings
- What would be done differently?
- What was learned about the codebase, users, or process?
- What assumptions were proven wrong?

## Step 4: Action items

For each identified issue, generate a concrete action item:

```
ACTION ITEMS:
1. [Problem] → [Action] → [Owner] → [By when]
2. [Problem] → [Action] → [Owner] → [By when]
```

Action items must be:
- Specific (not "improve testing" but "add integration tests for auth flow")
- Achievable (can be done in the next sprint)
- Owned (someone is responsible)

## Output Format

```
RETRO: [Period]
Date: [Today]

WINS
- [win 1]
- [win 2]

DIDN'T GO WELL
- [issue 1]
- [issue 2]

SURPRISES
- [surprise 1]

LEARNINGS
- [learning 1]
- [learning 2]

ACTION ITEMS
- [ ] [action 1]
- [ ] [action 2]
```
