#!/bin/bash
# claude-switch.sh - Simple account switcher for Claude Code
ACCOUNTS_DIR="$HOME/.claude-accounts"
CLAUDE_CONFIG="$HOME/.claude.json"
mkdir -p "$ACCOUNTS_DIR"

case "$1" in
    list)
        echo "Saved accounts:"
        for f in "$ACCOUNTS_DIR"/*.json; do
            [ -f "$f" ] || continue
            name=$(basename "$f" .json)
            email=$(python3 -c "import json; d=json.load(open('$f')); print(d.get('oauthAccount',{}).get('emailAddress','unknown'))" 2>/dev/null)
            echo "  $name -> $email"
        done
        echo ""
        echo "Current: $($0 current)"
        ;;
    add)
        [ -z "$2" ] && echo "Usage: claude-switch add <name>" && exit 1
        [ ! -f "$CLAUDE_CONFIG" ] && echo "No ~/.claude.json found. Login first." && exit 1
        cp "$CLAUDE_CONFIG" "$ACCOUNTS_DIR/$2.json"
        echo "Saved current account as '$2'"
        ;;
    use)
        [ -z "$2" ] && echo "Usage: claude-switch use <name>" && exit 1
        [ ! -f "$ACCOUNTS_DIR/$2.json" ] && echo "Account '$2' not found." && exit 1
        cp "$ACCOUNTS_DIR/$2.json" "$CLAUDE_CONFIG"
        email=$(python3 -c "import json; d=json.load(open('$CLAUDE_CONFIG')); print(d.get('oauthAccount',{}).get('emailAddress','unknown'))" 2>/dev/null)
        echo "Switched to '$2' ($email)"
        ;;
    current)
        [ -f "$CLAUDE_CONFIG" ] && python3 -c "import json; d=json.load(open('$CLAUDE_CONFIG')); print(d.get('oauthAccount',{}).get('emailAddress','not logged in'))" 2>/dev/null || echo "not logged in"
        ;;
    *)
        echo "Usage: claude-switch <list|add|use|current> [name]"
        ;;
esac
