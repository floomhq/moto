---
name: ship
description: >
  Sync main, run tests on merged code, do a pre-landing review, push, and create a PR.
  Use when user says "ship", "push and PR", "create PR", "ship it", "push to review",
  or asks to submit code for review. More thorough than a simple commit+push.
---

# Ship Skill

## Step 1: QA check

Before shipping, analyze the diff and verify:
- Which files changed and why
- Whether tests exist for the changes
- Whether the change is complete (no TODOs, no debug code, no console.logs)
- Whether env vars or config need updating

Run:
```bash
git diff main...HEAD
```

## Step 2: Sync with main

```bash
git fetch origin
git rebase origin/main
```

If conflicts arise, resolve them before continuing.

## Step 3: Run tests on the merged code

```bash
# Run whatever test suite exists
npm test        # or pytest, cargo test, go test, etc.
npm run build   # Verify build passes
npm run lint    # Verify linting passes
```

Do NOT ship if tests fail.

## Step 4: Pre-landing review

Check the final diff one more time:
```bash
git diff origin/main...HEAD
```

Look for:
- Accidental debug code or console.logs
- Hardcoded values that should be env vars
- Missing error handling
- Breaking changes to public APIs
- Security issues (XSS, injection, exposed secrets)

## Step 5: Push

```bash
git push origin HEAD
```

If the branch doesn't exist remotely yet:
```bash
git push -u origin HEAD
```

## Step 6: Create PR

```bash
gh pr create --title "<title>" --body "<body>"
```

**PR title format:** `<type>: <description>` (e.g., `fix: correct auth token expiry`, `feat: add dark mode`)

**PR body should include:**
- What changed and why
- How to test
- Any breaking changes
- Screenshots for UI changes

## Step 7: Verify

After creating the PR:
- Check CI is running (not failing)
- Verify the PR description is accurate
- Return the PR URL to the user

## Rules

- NEVER push directly to main/master without a PR (unless repo has no branch protection and user explicitly asks)
- NEVER push with failing tests
- NEVER skip the pre-landing review
- Always create PRs as draft if the work is not complete
