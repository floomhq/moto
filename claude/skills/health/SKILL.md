---
name: health
description: >
  10-second audit of AX41 system state. Use when: "health check", "system
  status", "check system", "what's running", "orphans", "disk space",
  "check containers", or any question about the current state of the server.
---

# System Health Check

Run ALL checks in parallel (single Bash call with semicolons), then render one table.

## Checks to Run

```bash
echo "=== DOCKER ===" && docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null ; \
echo "=== CHROME 9222 ===" && curl -s --max-time 2 http://localhost:9222/json/version 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('Browser','unknown'))" 2>/dev/null || echo "DOWN" ; \
echo "=== CHROME 9223 ===" && curl -s --max-time 2 http://localhost:9223/json/version 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('Browser','unknown'))" 2>/dev/null || echo "DOWN" ; \
echo "=== SSHFS ===" && ls /mnt/mac/Library 2>/dev/null | head -1 || echo "NOT MOUNTED" ; \
echo "=== SSHFS ALT ===" && ls /Users/federicodeponte/Library 2>/dev/null | head -1 || echo "NOT MOUNTED" ; \
echo "=== ORPHANS ===" && pgrep -af "chrome-headless-shell|remotion|playwright|ffmpeg|puppeteer|whisper" 2>/dev/null | grep -v "grep" | grep -v "fix-claude-chrome" || echo "none" ; \
echo "=== DISK ===" && df -h / | tail -1 ; \
echo "=== TMP ===" && du -sh /tmp/* 2>/dev/null | sort -rh | head -5 ; \
echo "=== FAILED UNITS ===" && systemctl list-units --state=failed --no-legend 2>/dev/null | head -10 || echo "none" ; \
echo "=== MEMORY ===" && free -h | grep Mem ; \
echo "=== WORKTREES ===" && ls ~/.claude/worktrees/ 2>/dev/null || echo "none"
```

## Output Format

Render a single markdown table:

| Service | Status | Details |
|---------|--------|---------|
| clawdbot | OK / DOWN | Container status + uptime |
| floom-demo | OK / DOWN | Container status + ports |
| [other containers] | OK / DOWN | Name + status |
| Chrome :9222 (authenticated) | OK / DOWN | Browser version or "no response" |
| Chrome :9223 (chrome-full) | OK / DOWN | Browser version or "no response" |
| sshfs /mnt/mac | OK / DOWN | Mount healthy or not mounted |
| Orphan processes | OK / N found | List PIDs + names if any |
| Disk / | X% used | Used/total, warn if >80% |
| /tmp largest files | OK / WARN | Top entries if >500MB |
| Failed systemd units | OK / N failed | Unit names if any |
| Memory | X GB free | Used/total |
| Stale worktrees | OK / N found | Names if any |

## Status Rules

- OK: service running, mount healthy, no orphans, disk <80%, no failed units
- WARN: disk 80-90%, /tmp files >1GB, worktrees older than 7 days
- DOWN: container exited/missing, Chrome not responding, mount absent
- CRITICAL: disk >90%, memory <500MB free, P0 orphan processes (remotion/ffmpeg/whisper running without timeout)

## After the Table

If any DOWN or CRITICAL items exist, list them as a bulleted action list:
- "clawdbot is DOWN: run `docker restart clawdbot`"
- "Chrome :9222 is DOWN: check `ps aux | grep chrome`"
- "Orphan found (PID 1234 - ffmpeg): kill with `kill 1234`"
- "sshfs not mounted: run `sshfs ...` or check Mac SSH"

If everything is OK, one line: "All systems nominal."
