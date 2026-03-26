---
name: docker-deploy
description: >
  Self-hosted Docker deployment for your services. Use when user says "docker
  deploy", "rebuild container", "restart container", or needs to deploy a
  self-hosted service (not Vercel/Render).
---

# Docker Deploy Skill

Detect the target project, build, deploy, and verify. Never guess - confirm project from context or ask.

<!-- Customize: replace the example projects below with your own Docker services -->

## Projects

### Example: Web App (Dev Server)

- Path: `~/my-app/`
- Container: `my-app`
- Ports: 3000->3000

**Build and deploy:**
```bash
cd ~/my-app
docker build -t my-app:latest .
docker stop my-app 2>/dev/null || true
docker rm my-app 2>/dev/null || true
docker run -d --name my-app -p 3000:3000 my-app:latest
```

**Verify:**
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
```

---

### Example: API Service (Remote Server)

- Source: `/path/to/api/main.py`
- Deploy path (remote): `/opt/my-api/`
- Container: `my-api`, port 8090

**Deploy flow:**
```bash
# 1. Copy updated file(s) to remote
scp /path/to/api/main.py remote-server:/opt/my-api/main.py

# 2. Rebuild and restart on remote
ssh remote-server "cd /opt/my-api && docker compose build && docker compose up -d"
```

**Verify:**
```bash
curl -s -o /dev/null -w "%{http_code}" https://api.example.com/health
```

**Env vars**: `/opt/my-api/.env` on remote (do not overwrite without reading first).

---

### Example: Stateful Service (WhatsApp Gateway, DB, etc.)

<!-- Customize: for services where recreating the container destroys state -->

- Container: `my-gateway`, port 19000
- Config: `/opt/my-gateway/`

**CRITICAL: NEVER run `docker-compose down` or `docker-compose up` on stateful containers.**
This destroys session state (e.g., WhatsApp linking, DB data).

**Restart only:**
```bash
docker restart my-gateway
```

---

## Workflow

1. Detect project from user input.
2. If ambiguous, ask: "Which project?"
3. Run the build/deploy sequence for that project.
4. Run verification step and show the HTTP status code or container status.
5. Report result. If verification fails, check container logs.

**Check logs if something breaks:**
```bash
# Local containers
docker logs --tail 50 <container-name>

# Remote containers
ssh remote-server "docker logs --tail 50 <container-name>"
```
