---
name: debug
description: >
  Systematic debugging workflow for any type of error or unexpected behavior.
  Use when user says "debug this", "why is this failing", "help me fix this error",
  "something is broken", or shares an error message or unexpected output.
  Follows a root-cause-first approach rather than trial-and-error patching.
---

# Debug Skill

## Principle: Root Cause, Not Quick Fix

The goal is to find WHY something is broken, not to patch the symptom. A quick fix that doesn't address the root cause will resurface.

## Step 1: Understand the failure

Collect the full picture:
- What is the exact error message? (copy verbatim, don't paraphrase)
- What was the expected behavior?
- What is the actual behavior?
- When did it start failing? (after which change?)
- Does it fail consistently or intermittently?
- What environment? (local / staging / prod, OS, Node/Python version)

## Step 2: Read the error carefully

Before touching any code:
- Read the FULL stack trace, not just the first line
- Note the file and line number where it originated
- Note any "caused by" or nested exceptions
- Check if there are warning messages before the error

## Step 3: Form a hypothesis

Based on the error, form a hypothesis about what's wrong. Common categories:
- **Data issue**: null/undefined where not expected, wrong type, out of range
- **Logic issue**: wrong condition, off-by-one, state mutation
- **Dependency issue**: wrong version, missing module, API change
- **Environment issue**: missing env var, wrong config, permission denied
- **Timing issue**: race condition, async/await missing, order of operations
- **Network issue**: timeout, DNS, CORS, SSL

## Step 4: Verify the hypothesis

**Verify, don't assume.** For each hypothesis:
```bash
# Add targeted logging to confirm
console.log('DEBUG:', variableName, typeof variableName);

# Check values at the point of failure
# Read the actual code at the error location
# Check the data flowing in
```

## Step 5: Find the root cause

Trace backwards from the failure:
1. Where does the error originate?
2. What called that code?
3. What data was passed?
4. Where was that data set?
5. Is the data wrong, or is the code wrong?

Use `git log` and `git blame` to understand when and why code was written a certain way.

## Step 6: Fix and verify

Once root cause is confirmed:
1. Make the minimal fix
2. Verify the original error is gone
3. Check no new errors were introduced
4. Add a test to prevent regression

## Step 7: Document

If the bug was non-obvious:
- Add a comment explaining why the fix works
- Add a test with a descriptive name
- Update docs if behavior changed

## Common Debugging Commands

```bash
# Node.js - check for syntax errors
node --check file.js

# Python - trace imports
python -v script.py 2>&1 | head -50

# Check if a port is in use
lsof -i :3000

# Check env vars
env | grep MY_VAR

# Check recent git changes
git log --oneline -20
git show <commit>

# Find where a function/variable is used
grep -r "functionName" --include="*.ts" .
```

## Anti-patterns to Avoid

- Never add a `|| defaultValue` to silence an error without understanding why it's null
- Never catch and swallow exceptions without logging
- Never assume the error is in the obvious place (it often isn't)
- Never make multiple changes at once when debugging - change one thing, test, then change the next
