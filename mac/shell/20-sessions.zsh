# shellcheck shell=bash
# (sourced from ~/.zshrc.d/; zsh-compatible syntax)
# moto — session shortcuts (zsh functions)
# Wraps the `moto` CLI, plus keeps the classic `ax*` aliases for muscle memory.

# ── Primary commands ────────────────────────────────────────────────
# These are just thin aliases; all logic lives in the command binary.

_moto_cli() {
  moto "$@"
}

# Open/attach a Claude session as an iTerm tab.
ax() { _moto_cli new "${1:-main/main}"; }
axc() { _moto_cli newx "${1:-main/main}"; }
axoc() { _moto_cli newo "${1:-main/main}"; }

# Add a tab without attempting to reattach first (= same as `ax` now).
axn()  { _moto_cli attach "${1:-main/main}"; }
axnx() { _moto_cli newx "${1:-main/main}"; }

axlist() { _moto_cli ls; }
axl()    { _moto_cli ls; }

axk() {
  [[ -z "${1:-}" ]] && { echo "usage: axk session-name" >&2; return 1; }
  _moto_cli kill "$1"
}

# Send an image to the server; prints the remote path (useful for Claude prompts).
aximg() {
  [[ -z "${1:-}" ]] && { echo "usage: aximg PATH" >&2; return 1; }
  _moto_cli img "$1"
}

# Open a single fresh iTerm window for one session (legacy).
axwin() {
  local session="${1:-main/main}"
  osascript -e "tell application \"iTerm\"
    create window with default profile
    tell current session of current window
      write text \"moto attach $session\"
    end tell
  end tell" 2>/dev/null || echo "warning: could not control iTerm"
}
