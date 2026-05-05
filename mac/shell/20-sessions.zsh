# shellcheck shell=bash
# (sourced from ~/.zshrc.d/; zsh-compatible syntax)
# fstack — session shortcuts (zsh functions)
# Wraps the `fstack` CLI, plus keeps the classic `ax*` aliases for muscle memory.

# ── Primary commands ────────────────────────────────────────────────
# These are just thin aliases; all logic lives in the command binary.

_fstack_cli() {
  if command -v fstack >/dev/null 2>&1; then
    fstack "$@"
  else
    moto "$@"
  fi
}

# Open/attach a Claude session as an iTerm tab.
ax() { _fstack_cli new "${1:-main/main}"; }
axc() { _fstack_cli newx "${1:-main/main}"; }
axoc() { _fstack_cli newo "${1:-main/main}"; }

# Add a tab without attempting to reattach first (= same as `ax` now).
axn()  { _fstack_cli attach "${1:-main/main}"; }
axnx() { _fstack_cli newx "${1:-main/main}"; }

axlist() { _fstack_cli ls; }
axl()    { _fstack_cli ls; }

axk() {
  [[ -z "${1:-}" ]] && { echo "usage: axk session-name" >&2; return 1; }
  _fstack_cli kill "$1"
}

# Send an image to the server; prints the remote path (useful for Claude prompts).
aximg() {
  [[ -z "${1:-}" ]] && { echo "usage: aximg PATH" >&2; return 1; }
  _fstack_cli img "$1"
}

# Open a single fresh iTerm window for one session (legacy).
axwin() {
  local session="${1:-main/main}"
  osascript -e "tell application \"iTerm\"
    create window with default profile
    tell current session of current window
      write text \"if command -v fstack >/dev/null 2>&1; then fstack attach $session; else moto attach $session; fi\"
    end tell
  end tell" 2>/dev/null || echo "warning: could not control iTerm"
}
