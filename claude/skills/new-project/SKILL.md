---
name: new-project
description: >
  Scaffold a new project with standard setup. Use when user says
  "new project", "create project", "init project", "start new repo",
  "scaffold", "bootstrap", or asks to set up a new application from scratch.
  Handles GitHub repo creation, CLAUDE.md, env files, and platform setup.
---

# New Project Skill

## Step 1: Gather requirements

Ask (if not already clear):
1. Project name (kebab-case)
2. Tech stack: Next.js / Python FastAPI / Python CLI / Static HTML
3. Deploy target: Vercel / Render / Docker / None
4. Needs database? (Supabase / Postgres / SQLite)
5. Needs auth?
6. Needs payments?

## Step 2: Create the repo

```bash
# ALWAYS private by default
gh repo create <owner>/<name> --private --clone
cd <name>
```

## Step 3: Scaffold by stack

### Next.js (most common)
```bash
pnpm create next-app . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
```

### Python FastAPI
```bash
python -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn python-dotenv
cat > main.py << 'EOF'
from fastapi import FastAPI
app = FastAPI()

@app.get("/api/health")
def health():
    return {"status": "ok"}
EOF
cat > requirements.txt << 'EOF'
fastapi==0.115.0
uvicorn==0.32.0
python-dotenv==1.0.1
EOF
```

### Python CLI
```bash
python -m venv .venv
# Add entry_points to pyproject.toml
```

## Step 4: Create project CLAUDE.md

Every project gets a CLAUDE.md in root with:
- Project description and purpose
- Tech stack
- Key commands (dev, build, test, deploy)
- Architecture notes
- Known gotchas

## Step 5: Environment setup

```bash
# Create .env.example (tracked) with placeholder keys
# Create .env.local (gitignored) with real values
echo ".env.local" >> .gitignore
echo ".env" >> .gitignore
```

**NEVER commit real secrets. Only .env.example with placeholders.**

## Step 6: Git setup

```bash
cat >> .gitignore << 'EOF'
node_modules/
.next/
.env
.env.local
.env.production
__pycache__/
.venv/
*.pyc
.DS_Store
WORKPLAN-*.md
EOF

git add -A
git commit -m "Initial scaffold"
git push -u origin main
```

## Step 7: Platform setup (if applicable)

### Vercel
```bash
vercel link --token $VERCEL_TOKEN
# Set env vars in Vercel dashboard
```

### Supabase
```bash
supabase init
supabase link --project-ref <ref>
```

## Checklist before done

- [ ] Repo is PRIVATE on GitHub
- [ ] .gitignore covers secrets and build artifacts
- [ ] CLAUDE.md exists in project root
- [ ] .env.example has placeholder keys
- [ ] .env.local has real keys (gitignored)
- [ ] Build passes locally
- [ ] First commit pushed
