---
name: docker-deploy
description: >
  Self-hosted Docker deployment for Floom (AX41), FlyFast API (Hetzner), and
  Clawdbot (AX41). Use when user says "docker deploy", "deploy floom",
  "deploy flyfast api", "rebuild container", "restart container", or needs
  to deploy a self-hosted service (not Vercel/Render).
---

# Docker Deploy Skill

Detect the target project, build, deploy, and verify. Never guess - confirm project from context or ask.

## Projects

### Floom (AX41 - this machine)

- Path: `~/floom/`
- DNS: floom.dev -> 65.21.90.216
- Nginx: `/etc/nginx/sites-available/floom`
- Container: `floom-demo`
- Ports: 3004->3000 (frontend), 3005->3001 (API)

**Build and deploy:**
```bash
cd ~/floom
docker build -t floom-web:latest .
docker stop floom-demo 2>/dev/null || true
docker rm floom-demo 2>/dev/null || true
docker run -d --name floom-demo -p 3004:3000 -p 3005:3001 floom-web:latest
```

**Verify:**
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3004
```

---

### FlyFast API (Hetzner VPS)

- Source (AX41): `/root/opensky-app/api/main.py`
- Deploy path (Hetzner): `/opt/flyfast/`
- API URL: https://api.flyfast.app
- Container: `opensky-api`, port 8090, 2 CPUs / 2GB RAM limit

**Deploy flow:**
```bash
# 1. Copy updated file(s) to Hetzner
scp /root/opensky-app/api/main.py hetzner:/opt/flyfast/main.py

# 2. Rebuild and restart on Hetzner
ssh hetzner "cd /opt/flyfast && docker compose build && docker compose up -d"
```

**Verify:**
```bash
curl -s -o /dev/null -w "%{http_code}" https://api.flyfast.app/health
```

**Env vars**: `/opt/flyfast/.env` on Hetzner (do not overwrite without reading first).

---

### Clawdbot (AX41 - this machine)

- Container: `clawdbot`, port 19000
- Config: `/opt/clawdbot/`
- Control: `clawdbot-ctl {start|stop|restart|logs|login|status|send}`

**CRITICAL: NEVER run `docker-compose down` or `docker-compose up` on clawdbot.**
This destroys the WhatsApp session, requiring a QR code scan from Federico's phone.

**Restart only:**
```bash
docker restart clawdbot
# or
clawdbot-ctl restart
```

**Verify:**
```bash
clawdbot-ctl status
```

---

## Workflow

1. Detect project from user input (Floom / FlyFast / Clawdbot).
2. If ambiguous, ask: "Which project - Floom, FlyFast API, or Clawdbot?"
3. Run the build/deploy sequence for that project.
4. Run verification step and show the HTTP status code or container status.
5. Report result. If verification fails, check container logs.

**Check logs if something breaks:**
```bash
# AX41 containers
docker logs --tail 50 <container-name>

# Hetzner containers
ssh hetzner "docker logs --tail 50 opensky-api"
```
