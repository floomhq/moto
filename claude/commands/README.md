# Custom Slash Commands for Claude Code

Claude Code supports custom slash commands defined as Markdown files.

## How it works

1. Place `.md` files in `~/.claude/commands/` (global) or `.claude/commands/` (per-project)
2. The filename becomes the command name: `commit.md` -> `/commit`
3. When you type `/commit` in Claude Code, the file's content is injected as a system prompt
4. The command can reference `$ARGUMENTS` to accept user input after the slash command

## Directory structure

```
~/.claude/commands/       # Global commands (available in all projects)
  commit.md
  review.md
.claude/commands/         # Project-specific commands
  deploy.md
  test.md
```

## Example: /commit command

Create `~/.claude/commands/commit.md`:

```markdown
Review all staged changes with `git diff --cached`. Write a concise commit message following conventional commits format (feat:, fix:, docs:, refactor:, test:, chore:). The message should explain WHY, not WHAT. Create the commit. Do not push.
```

## Example: /review command with arguments

Create `~/.claude/commands/review.md`:

```markdown
Review the following code or file for bugs, security issues, and style problems. Be specific and actionable. File or topic: $ARGUMENTS
```

Usage: `/review src/auth.ts`

## Tips

- Keep commands focused on a single task
- Use `$ARGUMENTS` for commands that need user input
- Project commands override global commands with the same name
- Commands can reference other tools (git, npm, etc.) that Claude Code has access to
