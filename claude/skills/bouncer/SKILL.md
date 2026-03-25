---
name: bouncer
description: >
  Pre-flight check before starting any significant work. Use when starting a new task,
  before making changes to production systems, or when asked to "check if this is safe",
  "should I do this", "validate my plan", or "bouncer check". Evaluates risk, reversibility,
  and whether the right preconditions are met before proceeding.
---

# Bouncer: Pre-flight Risk Check

Before proceeding with any significant action, run this check. The bouncer's job is to catch bad ideas before they become problems.

## The Three Questions

1. **Is this reversible?**
   - If yes: proceed carefully
   - If no: require explicit confirmation and atomic commit first

2. **Is this the right time?**
   - Are there uncommitted changes that should be committed first?
   - Are there tests that should pass first?
   - Is there a blocking issue that should be resolved first?

3. **Is the scope correct?**
   - Is the proposed change proportional to the stated problem?
   - Are there unintended side effects?
   - Is this solving the root cause or a symptom?

## Risk Categories

### Green (proceed)
- Additive changes (new files, new functions)
- Changes to development/test environments
- Reversible config changes
- Changes with good test coverage

### Yellow (proceed with caution)
- Modifying existing logic
- Database schema changes with migration
- Changes affecting multiple consumers
- Production config changes

### Red (require explicit confirmation)
- Deleting data or files
- Breaking API changes
- Production deployments without test pass
- Changes to auth or security logic
- Any `rm -rf`, `DROP TABLE`, or irreversible operations

## Checklist

Before any significant change:
- [ ] Understand what is being changed and why
- [ ] Identify all files/systems affected (grep for callers)
- [ ] Confirm tests exist or will be written
- [ ] Confirm the change is reversible OR have a rollback plan
- [ ] For production changes: confirm staging was tested first

## Response Format

When invoked, output:

```
BOUNCER CHECK
Risk level: [GREEN / YELLOW / RED]
Reversible: [YES / NO / PARTIAL]
Preconditions met: [YES / NO - missing: ...]
Recommendation: [PROCEED / PROCEED WITH CAUTION / STOP AND CONFIRM]
Reason: [brief explanation]
```
