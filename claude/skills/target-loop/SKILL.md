---
name: target-loop
description: >
  Iterative improvement loop for any target output (code, copy, design, document).
  Use when user wants to iterate until something is "perfect", "polished", or "production-ready",
  or asks to "keep improving", "iterate on this", "make it better", "polish this",
  or wants multiple rounds of refinement on a specific artifact.
---

# Target Loop Skill

## Purpose

A structured iterative improvement loop that continues until a target artifact reaches a defined quality bar. Prevents premature stopping and systematic drift from the goal.

## Step 1: Define the target

Before iterating, clearly define:
1. **What is the artifact?** (code, copy, design, document)
2. **What is "done"?** (specific quality criteria, not subjective)
3. **What is the completion signal?** (user says "good", tests pass, score threshold, etc.)
4. **Maximum iterations?** (default: 10)

Example completion criteria:
- "Copy: no filler words, every sentence earns its place, reads in under 60 seconds"
- "Code: all tests pass, no TypeScript errors, no console.logs"
- "Design: passes QA checklist, no overlapping elements, all text fits"

## Step 2: Baseline assessment

Before iterating, assess the current state:
- What's working well? (preserve this)
- What's the biggest problem? (fix this first)
- Score: X/10 with specific reasoning

## Step 3: Iterate

For each iteration:

```
ITERATION N/[MAX]
Current score: X/10
Biggest issue: [specific problem]
Fix applied: [what was changed]
New score: X/10
Remaining issues: [list]
```

**Iteration priorities:**
1. Fix the thing that matters most first
2. Don't fix multiple independent problems at once (hard to verify)
3. After each fix, re-evaluate the full artifact - one fix often creates another problem

## Step 4: Completion check

Before stopping, verify:
- [ ] Does the artifact meet ALL stated completion criteria?
- [ ] Is there anything that would make a skeptical reviewer reject this?
- [ ] Has the core goal been preserved through iterations?

If any check fails, continue iterating.

## Step 5: Final output

When done:
```
TARGET LOOP COMPLETE
Iterations: N
Final score: X/10
What changed: [summary of improvements]
Result: [the final artifact]
```

## Anti-patterns

- **Stopping at 8/10**: "Good enough" is not the goal. If the bar was set, hit it.
- **Fixing symptoms**: If the same type of issue keeps appearing, there's a root cause to fix.
- **Losing the core**: Iterations can drift from the original goal. Re-read the target criteria every 3 iterations.
- **Infinite loops**: Set a max iteration count. If not converging, the criteria may need refinement.
