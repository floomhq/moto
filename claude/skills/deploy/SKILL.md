---
name: deploy
description: >
  Deploy projects to their respective platforms. Use when user says
  "deploy", "push to prod", "ship it", "release", "deploy to preview",
  "deploy to production", "deploy backend", "deploy frontend".
  Handles Vercel, Render, Supabase Edge Functions, and Docker deployments.
---

# Deploy Skill

## Step 1: Identify the project

Determine which project to deploy from cwd or user's message. If ambiguous, ask.

## Step 2: Identify the platform

Common deployment targets:

### Vercel (frontend)
```bash
# Auto-deploy via git push
git push origin main       # or preview/production branch

# Manual deploy
vercel --token $VERCEL_TOKEN
```

### Render (backend)
```bash
# Trigger deploy via API
curl -s -X POST "https://api.render.com/v1/services/<SERVICE_ID>/deploys" \
  -H "Authorization: Bearer $RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"clearCache":"clear"}'
```

### Docker (self-hosted)
```bash
# Rebuild and restart container
docker compose build && docker compose up -d

# Or just restart
docker restart <container_name>
```

### Supabase Edge Functions
```bash
supabase functions deploy <function-name>
```

## Pre-deploy checklist

1. Run `git diff` to review what's being deployed
2. Run build locally: `npm run build` or equivalent
3. Run tests if they exist
4. Check for uncommitted `.env` changes (never commit secrets)

## Post-deploy verification

1. Check the live URL loads correctly
2. For API backends: hit the health endpoint (`/api/health`)
3. Check deploy logs for errors
4. Verify key functionality works end-to-end

## Project-specific notes

Check `CLAUDE.md` in the project root for project-specific deploy steps, branch strategies, and gotchas.
