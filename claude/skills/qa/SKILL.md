---
name: qa
description: >
  Analyze a diff or set of changes and identify which pages, routes, components,
  and systems are affected. Use before shipping code, when asked to "qa this",
  "review my changes", "what's affected", "blast radius", or "qa check".
  Produces a structured impact analysis.
---

# QA Skill

## Step 1: Get the diff

```bash
git diff main...HEAD
# or for staged changes:
git diff --cached
# or for a specific commit range:
git diff <from>..<to>
```

## Step 2: Categorize changes

For each changed file, identify:
- **Type**: frontend / backend / config / tests / docs / infra
- **Scope**: which feature/module/route is affected
- **Risk**: low / medium / high

## Step 3: Impact analysis

### Frontend changes
- Which pages/routes render the changed components?
- Are there loading/error states to test?
- Are there mobile/desktop variants to check?
- Does the change affect layout shift or performance?

### Backend changes
- Which API endpoints are affected?
- Which consumers call those endpoints?
- Are there database queries that changed?
- Are there cron jobs or background tasks affected?

### Config/env changes
- Which environments are affected?
- Is there a migration or deployment step needed?
- Are there secrets that need to be rotated or updated?

### Breaking changes
- Are any public interfaces changing signature?
- Are any database schemas changing?
- Are any API contracts changing?

## Step 4: Test plan

Generate a concrete test checklist based on the affected areas:

```
TEST PLAN for this diff:

Pages/routes to verify:
- [ ] /path/to/page - verify [specific behavior]
- [ ] /other/route - verify [specific behavior]

API endpoints to verify:
- [ ] GET /api/endpoint - verify [expected response]

Edge cases to check:
- [ ] [specific edge case]
- [ ] [error state]

Regression checks (ensure nothing broke):
- [ ] [existing feature that could be affected]
```

## Step 5: Risk summary

```
QA SUMMARY
Files changed: N
Risk level: [LOW / MEDIUM / HIGH]
Affected areas: [list]
Manual testing required: [YES / NO]
Recommended: [SHIP / NEEDS MORE TESTING / STOP]
```
