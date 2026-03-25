---
name: deep-audit
description: >
  Comprehensive codebase or system audit. Use when asked to "audit the codebase",
  "review everything", "find all issues", "security audit", "performance audit",
  "code quality review", or "find tech debt". Produces a structured report with
  findings prioritized by severity.
---

# Deep Audit Skill

## Purpose

A systematic, thorough review of a codebase, system, or artifact. Not a quick scan - a deep investigation that surfaces issues a casual review would miss.

## Step 1: Define audit scope

Clarify:
- What is being audited? (codebase, API, database, infrastructure, specific module)
- What type of audit? (security, performance, code quality, UX, all)
- What is the output? (prioritized issue list, report, PR with fixes)

## Step 2: Gather context

```bash
# Understand the project structure
find . -type f -name "*.ts" | head -50
ls -la

# Read key files
cat CLAUDE.md README.md package.json

# Check recent changes
git log --oneline -20

# Check open issues
gh issue list --limit 20
```

## Step 3: Run automated checks

### Code quality
```bash
# TypeScript errors
npx tsc --noEmit

# Linting
npm run lint

# Test coverage
npm test -- --coverage
```

### Security
```bash
# Check for known vulnerabilities
npm audit

# Check for hardcoded secrets
grep -r "password\|secret\|api_key\|token" --include="*.ts" --include="*.js" . | grep -v ".test." | grep -v "node_modules"
```

### Dependencies
```bash
# Outdated packages
npm outdated

# Unused dependencies (if depcheck is available)
npx depcheck
```

## Step 4: Manual review

### Security checklist
- [ ] No secrets in code or git history
- [ ] Input validation on all user-controlled data
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (output escaping)
- [ ] Authentication on protected routes
- [ ] Authorization checks (can user access this resource?)
- [ ] Rate limiting on public endpoints
- [ ] Error messages don't expose internals

### Code quality checklist
- [ ] No dead code (functions never called, variables never used)
- [ ] No duplicate logic (DRY violations)
- [ ] No magic numbers/strings (should be named constants)
- [ ] No TODO/FIXME comments without linked issues
- [ ] Error handling is consistent and not swallowed
- [ ] Logging is useful (not too verbose, not missing)

### Performance checklist
- [ ] No N+1 queries
- [ ] No synchronous operations in async contexts
- [ ] Database queries have appropriate indexes
- [ ] Large data sets are paginated
- [ ] Expensive operations are cached when appropriate

### Maintainability checklist
- [ ] Functions are small and single-purpose
- [ ] Dependencies are pinned to exact versions
- [ ] Environment variables are documented in .env.example
- [ ] CLAUDE.md or README is up to date

## Step 5: Prioritize findings

For each finding:

| Severity | Description |
|----------|-------------|
| P0 (Critical) | Security vulnerability, data loss risk, production outage risk |
| P1 (High) | Significant bug, major performance issue, important missing feature |
| P2 (Medium) | Code quality issue, minor bug, missing test coverage |
| P3 (Low) | Style issues, minor improvements, nice-to-haves |

## Step 6: Output format

```
DEEP AUDIT REPORT
Scope: [what was audited]
Date: [today]

SUMMARY
Files reviewed: N
Issues found: N (P0: X, P1: X, P2: X, P3: X)

P0 - CRITICAL
1. [Issue title]
   File: [path]
   Description: [what the problem is]
   Impact: [what can go wrong]
   Fix: [how to fix it]

P1 - HIGH
1. [Issue title]
   ...

P2 - MEDIUM
...

P3 - LOW
...

RECOMMENDED NEXT STEPS
1. [Most important action]
2. [Second most important action]
```
