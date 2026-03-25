---
name: blast-radius
description: >
  Map the full impact of a proposed change before making it. Use before refactors,
  API changes, database migrations, or any modification to shared code. Triggers:
  "blast radius", "what will break", "impact analysis", "what depends on this",
  "is it safe to change this", or before any significant refactor.
---

# Blast Radius Skill

## Purpose

Before changing anything, understand everything it touches. The blast radius is the set of systems, files, users, and processes that will be affected by a change.

## Step 1: Identify the target

What exactly is being changed?
- A function signature
- A database schema
- An API endpoint
- A configuration value
- A shared utility
- An environment variable

## Step 2: Find all consumers

```bash
# Find all usages of a function/variable
grep -r "functionName" --include="*.ts" --include="*.js" .

# Find all imports of a module
grep -r "from './module'" --include="*.ts" .

# Find all references to a table
grep -r "table_name" --include="*.sql" --include="*.py" .

# Find all callers of an API endpoint
grep -r '"/api/endpoint"' .
grep -r "fetch.*endpoint" .
```

## Step 3: Map the dependency tree

```
[Changed thing]
├── Direct consumers (files that use it directly)
│   ├── Consumer A
│   │   └── Who uses Consumer A?
│   └── Consumer B
│       └── Who uses Consumer B?
└── Indirect consumers (things that use consumers)
```

## Step 4: Classify impact

For each consumer:

| Consumer | Impact Type | Severity | Action Needed |
|----------|-------------|----------|---------------|
| file.ts | Breaking | HIGH | Update call sites |
| test.ts | Breaking | MEDIUM | Update tests |
| api.ts | Breaking | HIGH | Update + version bump |

**Impact types:**
- **Breaking**: Will fail to compile/run without update
- **Behavioral**: Will compile but behavior changes
- **None**: No impact (consumer is isolated)

## Step 5: Migration plan

For breaking changes:
1. List all files that need updating
2. Estimate effort per file
3. Define the migration order (what to update first)
4. Plan for parallel operation (old + new) if needed for zero-downtime

## Step 6: Risk assessment

```
BLAST RADIUS REPORT
Target: [what is changing]
Direct consumers: N files
Indirect consumers: M files
Breaking changes: [YES/NO]

HIGH RISK areas:
- [file/system] because [reason]

Estimated effort: [S/M/L]
Migration required: [YES/NO]
Rollback plan: [description or N/A]

RECOMMENDATION: [PROCEED / PROCEED WITH MIGRATION PLAN / STOP AND REDESIGN]
```

## Common Gotchas

- **Serialized data**: If you change a data structure that's stored (database, localStorage, cache), old data won't match new code
- **External contracts**: If the API is public or used by external systems, breaking changes need versioning
- **Implicit contracts**: Types that aren't enforced (e.g., "this object always has a `name` field") but are expected by consumers
- **Environment variables**: Renaming/removing env vars requires coordinated deploy
- **Database migrations**: Column renames require code + migration to deploy atomically
