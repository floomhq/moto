# shellcheck shell=bash
# (sourced from ~/.zshrc.d/; zsh-compatible syntax)
# fstack — open-all-sessions wrappers.
# The heavy lifting lives in `fstack up` (background). `axo` is kept as a legacy alias.

axo()    { _fstack_cli up; }
axo-fg() { _fstack_cli up -fg; }
