#!/bin/bash
# Stop hook wrapper - Gemini independent quality gate
# Opt-in: touch ~/.claude/.gemini-audit-enabled
# Opt-out: rm ~/.claude/.gemini-audit-enabled
# Requires: GEMINI_API_KEY or GOOGLE_API_KEY env var, pip install google-genai

[ -f "$HOME/.claude/.gemini-audit-enabled" ] || exit 0
[ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc" 2>/dev/null
[ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc" 2>/dev/null
exec python3 "$HOME/.claude/hooks/gemini-audit.py"
