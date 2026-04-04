#!/bin/bash
# PreCompact hook: Save critical state before context compaction
set -euo pipefail

STATE_DIR=".claude/precompact-state"
mkdir -p "$STATE_DIR"

cat > "$STATE_DIR/last-state.md" <<STATE
# Pre-Compaction State Snapshot
Saved at: $(date -u +%Y-%m-%dT%H:%M:%SZ)

## Active Files (recently modified)
$(git diff --name-only HEAD 2>/dev/null | head -20 || echo "(none)")

## Uncommitted Changes Summary
$(git diff --stat 2>/dev/null | tail -5 || echo "(not a git repo)")

## Target Loop State
$(head -15 .claude/target-loop.local.md 2>/dev/null || echo "(no active loop)")

## Last Test Results
$(tail -20 .claude/last-test-output.txt 2>/dev/null || echo "(none)")

## Build Status
$(tail -10 .claude/last-build-output.txt 2>/dev/null || echo "(none)")
STATE

echo "Pre-compaction state saved."
