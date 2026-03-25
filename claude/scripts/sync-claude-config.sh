#!/bin/bash
# Sync Claude Code config (CLAUDE.md + MEMORY.md) across machines
# Edit SOURCE and TARGETS for your setup
set -e

SOURCE_CLAUDE_MD="$HOME/.claude/CLAUDE.md"
SOURCE_MEMORY_MD="$HOME/.claude/projects/-$(echo $HOME | tr '/' '-' | sed 's/^-//')/memory/MEMORY.md"

# Add your server SSH aliases here
TARGETS=(
    # "dev-server"
    # "prod-server"
)

for target in "${TARGETS[@]}"; do
    scp -q "$SOURCE_CLAUDE_MD" "$target":~/.claude/CLAUDE.md
    echo "Synced CLAUDE.md to $target"
done

echo "Done syncing Claude config"
