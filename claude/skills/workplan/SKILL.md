---
name: workplan
description: >
  Create, update, or close work plans for multi-step tasks. Use when starting
  refactors, bug lists, feature work, migrations, or any task with 2+ steps.
  Also use after auto-compaction to re-orient. Triggers: "workplan", "work plan",
  "create a plan", "what's the plan", "where was I", or when Claude detects
  a multi-step task that needs tracking.
---

# Work Plan Skill

Work plans are timestamped markdown files that survive auto-compaction. They are the external brain for multi-step work.

## File Convention

- **Location:** Project root, gitignored
- **Name:** `WORKPLAN-YYYYMMDD-slug.md` (e.g., `WORKPLAN-20260228-auth-refactor.md`)
- **One file per task/phase.** Do not reuse old workplans. Start fresh for each distinct effort.

## Actions

### Create (`/workplan` or `/workplan create`)

1. **Read first.** Before writing the plan, read all relevant files, issues, context.
2. **Ensure `.gitignore` includes `WORKPLAN-*.md`** (add if missing).
3. **Create the file** with this template:

```markdown
# Work Plan: [Title]

Created: YYYY-MM-DD HH:MM
Last updated: YYYY-MM-DD HH:MM
Status: IN PROGRESS

## Context

[Why this work exists. The problem. Root cause. Key constraints. Links to issues/PRs.]

## Roadmap

- [ ] 1. Step description
- [ ] 2. Step description
- [ ] 3. Step description

## Decisions

[Log architectural or approach decisions with timestamps]
- [HH:MM] Chose X over Y because Z

## Discovered Issues

[Things found along the way that were not in the original scope]
- [HH:MM] Found ... while working on step 2

## Verification Log

[Each completed item gets a verification entry]
- [HH:MM] Step 1: VERIFIED - ran `npm test`, all 42 tests pass
- [HH:MM] Step 3: VERIFIED - manually tested login flow, works
```

### Update (`/workplan update`)

1. Read the active `WORKPLAN-*.md` file(s) in the project root.
2. Update "Last updated" timestamp.
3. Check off completed items with verification timestamps.
4. Add any new discoveries or decisions.
5. Report current status.

### Close (`/workplan close`)

1. Read the active workplan.
2. Verify ALL items are checked off with verification timestamps.
3. Run final verification (build, tests, manual checks).
4. Change status to `DONE`.
5. Add final summary:
```markdown
## Completed

Closed: YYYY-MM-DD HH:MM
All N items implemented and verified. Build passes. Tests pass.
```

### Resume (after compaction)

When context has been compacted or unsure where you left off:

1. Find active workplans: look for `WORKPLAN-*.md` in project root.
2. Read the workplan file.
3. Identify the first unchecked item.
4. Continue from there.

## Rules

1. **VERIFIED means tested.** Not "I think it works." Run it, see it pass, then mark verified. Include what you ran and the result.
2. **Update timestamps on every change.** Future context (post-compaction) depends on this.
3. **New discoveries go in immediately.** Do not keep them only in context.
4. **Never delete the plan** until the user confirms the work is done.
5. **One concern per checklist item.** Break big steps into smaller verifiable pieces.
6. **If a step fails verification,** log the failure, keep it unchecked, add what went wrong.
