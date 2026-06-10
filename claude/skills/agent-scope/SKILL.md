---
---
name: agent-scope
description: |
  Enforce scoped write access for AI coding agents. Use when starting a new task,
  before committing changes, when asked to "check scope", "validate my diff",
  "did I touch anything I shouldn't", or when working in a monorepo where
  protected modules (auth, billing, migrations) must not be silently modified.
---

# agent-scope — Scope Guard for AI Coding Agents

**agent-scope** stops AI agents from silently changing code outside their intended task.

- Read broadly (`**/*`)
- Write narrowly (scoped paths)
- Ask before touching protected code
- Run checks before finishing

## When to use

- Starting a new task in a monorepo
- Agent keeps touching unrelated modules
- Need to lock auth, billing, or database layers
- Want a CI gate that catches scope violations in PRs

## Quick setup

```bash
npm install -g agent-scope
agent-scope init
```

Edit `agent.scope.yml`:

```yaml
version: "0.1"
mode: strict

task:
  id: "your-task-id"
  title: "Your task title"

scope:
  read:
    - "**/*"
  write:
    - "apps/web/settings/**"
    - "packages/email/**"
    - ".agent-scope/**"
  protected:
    - "packages/auth/**"
    - "packages/billing/**"
    - "db/migrations/**"
  approval_required:
    - "package.json"
    - "pnpm-lock.yaml"
```

## Daily workflow

### Before editing

Review `agent.scope.yml` to confirm your write boundaries.

### After editing

```bash
agent-scope check
```

If violations appear, do **not** proceed. Your options:

1. **Revert** the out-of-scope changes
2. **Request** scope expansion:
   ```bash
   agent-scope request packages/auth/session.ts \
     --reason "Need to expose email preference in session"
   ```
3. **Approve** if human already gave permission:
   ```bash
   agent-scope approve packages/auth/session.ts
   ```

### Before finishing

```bash
agent-scope run
```

This validates scope and then runs `checks.before_done` from the config.

## Integration with agents

### Claude Code hook

Add to your workflow:

```bash
agent-scope check --json
```

If the JSON response shows `"status": "blocked"`, revert the violating files or create a scope request before continuing.

### Cursor / Codex

Add a rule to your project:

> Before completing any task, run `agent-scope check`. If scope violations are found, revert the violating files or request scope expansion. Do not silently modify protected modules.

## CI / GitHub Action

```yaml
name: Agent Scope
on:
  pull_request:
jobs:
  scope:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - run: npm install -g agent-scope
      - run: agent-scope check --base origin/${{ github.base_ref }}
```

## Reference

- **Repo**: https://github.com/floomhq/agent-scope
- **NPM**: https://www.npmjs.com/package/agent-scope
- **Full docs**: https://github.com/floomhq/agent-scope#readme

## Enforcement model

Priority order:

```
protected > approved > approval_required > write > blocked
```

- **protected**: always blocked unless explicitly approved
- **approval_required**: needs explicit approval
- **write**: allowed by default
- **strict mode**: everything else is blocked
- **warn mode**: everything else is a warning (exit 0), protected still blocked
