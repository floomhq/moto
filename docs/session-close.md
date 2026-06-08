# Session close behavior

Moto keeps a **managed session registry** on the remote host under
`/root/.local/state/codex-guardian/`:

| File | Purpose |
|------|---------|
| `sessions.tsv` | Active managed set — `moto up` / `axo` reopen missing tabs from here |
| `closed-sessions.tsv` | Tombstones — intentionally closed sessions stay out of `moto up` |
| `pending-sessions.tsv` | Explicit adopt queue for new sessions |
| `cs-launch-exits.tsv` | Exit audit log (`rc=0` / `rc=130` = intentional close) |

## Intentional close (Ctrl+C / clean exit)

`/root/bin/cs-launch` wraps Claude/Codex/OpenCode in tmux. Exit code **0** or **130**
(Ctrl+C) triggers:

1. Prune row from `sessions.tsv` / pending / adhoc
2. Append tombstone to `closed-sessions.tsv`
3. Run `session-registry-sync`
4. **Then** `tmux kill-session`

Step order matters: the `session-closed` tmux hook runs `session-registry-sync` in
the background. If tmux is killed first, that sync can read stale registry state and
**restore** the row — so Ctrl+C looked successful but `moto up` reopened the tab.

## Kill from Mac

| Action | Effect |
|--------|--------|
| **⌘W** | Close iTerm tab only — remote tmux keeps running |
| **⌘⌃W twice** (~1s) | `moto kill SESSION` + close tab |
| **`moto kill project/task`** | Kill tmux, prune registry, tombstone |

Install the iTerm binding after `install.sh mac`:

```bash
$(dirname "$(which moto)")/ax-tab-kill-install   # or mac/bin/ax-tab-kill-install from repo
# restart iTerm
```

## Verify a close stuck

On AX41:

```bash
grep 'project/task' /root/.local/state/codex-guardian/cs-launch-exits.tsv | tail -3
grep 'project/task' /root/.local/state/codex-guardian/sessions.tsv || echo "not in registry"
grep 'project/task' /root/.local/state/codex-guardian/closed-sessions.tsv || echo "not tombstoned"
tmux has-session -t 'project/task' 2>/dev/null && echo tmux alive || echo tmux gone
```

Ghost (tmux gone, still in `sessions.tsv`, not tombstoned) → `moto kill project/task`.
