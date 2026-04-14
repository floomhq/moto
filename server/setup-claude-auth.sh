#!/bin/bash
# setup-claude-auth.sh - Push Claude Code auth from your Mac to a Linux dev server
#
# Usage: ./setup-claude-auth.sh [ssh-alias]
#   ssh-alias defaults to "dev"
#
# Run this from your Mac after provisioning a new server.
# Requires: Claude Code installed and logged in on this Mac.
#
# What it does:
#   1. Extracts your OAuth credentials from the macOS Keychain
#   2. Copies them to the server as ~/.claude/.credentials.json
#   3. Sets ANTHROPIC_AUTH_TOKEN in ~/.bashrc (suppresses the interactive sign-in screen)
#   4. Marks onboarding complete in ~/.claude.json so the theme picker doesn't block startup
#
# Background: Claude Code's headless OAuth flow on Linux is broken — the authorization
# code gets mangled on paste, and even when auth succeeds the TUI shows a sign-in screen
# because hasCompletedOnboarding is missing from ~/.claude.json. This script bypasses
# the entire flow by pushing credentials directly from the Mac Keychain.

set -euo pipefail

SERVER="${1:-dev}"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- 1. Extract credentials from macOS Keychain ---

info "Reading Claude Code credentials from macOS Keychain..."

CREDS=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)
if [ -z "$CREDS" ]; then
    err "No Claude Code credentials found in Keychain. Log in to Claude Code on this Mac first, then re-run."
fi

ACCESS_TOKEN=$(echo "$CREDS" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d['claudeAiOauth']['accessToken'])
" 2>/dev/null || true)

if [ -z "$ACCESS_TOKEN" ]; then
    err "Could not parse access token from credentials. Keychain entry may be malformed."
fi

ok "Credentials extracted (token: ${ACCESS_TOKEN:0:20}...)"

# --- 2. Verify SSH connection ---

info "Connecting to $SERVER..."
ssh -o ConnectTimeout=10 "$SERVER" "echo ok" > /dev/null 2>&1 || err "Cannot connect to $SERVER. Check your SSH config."
ok "Connected to $SERVER"

# --- 3. Copy credentials file ---

info "Copying credentials to $SERVER:~/.claude/.credentials.json..."
ssh "$SERVER" "mkdir -p ~/.claude"
echo "$CREDS" | ssh "$SERVER" "cat > ~/.claude/.credentials.json && chmod 600 ~/.claude/.credentials.json"
ok ".credentials.json installed"

# --- 4. Set ANTHROPIC_AUTH_TOKEN in .bashrc ---
# This tells Claude Code's interactive TUI that auth is already handled,
# suppressing the sign-in screen even before the credentials file is read.

info "Setting ANTHROPIC_AUTH_TOKEN in ~/.bashrc on $SERVER..."
ssh "$SERVER" "
    # Remove any stale entry first
    sed -i '/ANTHROPIC_AUTH_TOKEN/d' ~/.bashrc
    echo 'export ANTHROPIC_AUTH_TOKEN=\"${ACCESS_TOKEN}\"' >> ~/.bashrc
"
ok "ANTHROPIC_AUTH_TOKEN set in ~/.bashrc"

# --- 5. Mark onboarding complete in ~/.claude.json ---
# Without this, Claude Code shows a theme picker on every startup because
# hasCompletedOnboarding is absent from the config, regardless of auth state.

info "Marking onboarding complete on $SERVER..."
ssh "$SERVER" "python3 - <<'PYEOF'
import json, os, subprocess

path = os.path.expanduser('~/.claude.json')
d = json.load(open(path)) if os.path.exists(path) else {}

try:
    ver = subprocess.check_output(['claude', '--version'], text=True).split()[0]
except Exception:
    ver = 'unknown'

d['hasCompletedOnboarding'] = True
d['lastOnboardingVersion'] = ver

with open(path, 'w') as f:
    json.dump(d, f, indent=2)

print(f'Onboarding marked complete for Claude Code {ver}')
PYEOF"
ok "~/.claude.json updated"

# --- 6. Verify ---

info "Verifying auth on $SERVER..."
RESULT=$(ssh "$SERVER" "bash -i -c 'claude auth status 2>/dev/null'" 2>/dev/null || true)
if echo "$RESULT" | grep -q '"loggedIn": true'; then
    EMAIL=$(echo "$RESULT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('email','unknown'))" 2>/dev/null || echo "unknown")
    ok "Authenticated as $EMAIL"
else
    echo "Auth status: $RESULT"
    err "Auth verification failed. Try running 'claude auth status' on the server manually."
fi

echo ""
echo "============================================"
echo "  Claude Code auth configured on $SERVER"
echo "============================================"
echo ""
echo "  ssh $SERVER"
echo "  claude"
echo ""
echo "Note: The OAuth token expires in ~1 year. Re-run this script to refresh."
