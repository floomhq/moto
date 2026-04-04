# Claude Skills

Skills are slash commands that extend Claude's capabilities with specialized knowledge, workflows, and tool integrations. Think of them as "onboarding guides" that transform Claude from a general-purpose agent into a specialized agent equipped with procedural knowledge for specific domains.

## What Skills Are

Each skill is a directory containing a `SKILL.md` file (required) and optional bundled resources:

```
skill-name/
├── SKILL.md              # Required: metadata + instructions
├── scripts/              # Optional: executable scripts
├── references/           # Optional: reference docs loaded as needed
└── assets/               # Optional: templates, fonts, files used in output
```

The `SKILL.md` file has two parts:
- **YAML frontmatter**: `name` and `description` fields. The description is what Claude reads to determine when to trigger the skill.
- **Markdown body**: Instructions loaded after the skill is triggered.

Claude reads ALL skill descriptions at startup to know what's available. The body is only loaded when the skill is triggered - this keeps the context window lean.

## How to Install

If you use the repo's `install.sh` script, skills are installed automatically. Manual copying is only needed if you are not using the installer.

Copy the skill directory into `~/.claude/commands/`:

```bash
# Install a single skill
cp -r skills/debug/ ~/.claude/commands/debug/

# Install all skills
cp -r skills/*/ ~/.claude/commands/

# Verify installation
ls ~/.claude/commands/
```

After installation, the skill is available as `/<skill-name>` in Claude Code.

## How Skills Trigger

Skills trigger when Claude detects a match between the user's request and a skill's `description`. The description should include:
- What the skill does
- Specific trigger phrases
- When to use it

Claude also proactively invokes skills when it detects a matching task, even without an explicit slash command.

## How to Create Your Own

Use the `skill-creator` skill for guided creation, or follow this template:

```markdown
---
name: my-skill
description: >
  What this skill does and when to use it. Include specific trigger phrases
  like "when user says X" or "use when user asks to Y". This description
  is what Claude reads to decide whether to invoke the skill.
---

# My Skill Title

## Overview

[What this skill provides that Claude doesn't already know]

## Step 1: [First step]

[Instructions...]

## Step 2: [Second step]

[Instructions...]
```

Key principles:
- Only include information Claude doesn't already have
- Prefer examples over explanations
- Keep SKILL.md under 500 lines; move details to reference files
- The description is the trigger mechanism - make it comprehensive

See `skill-creator/SKILL.md` for the full guide.

## Included Skills

| Skill | Description |
|-------|-------------|
| **agents** | Scan running Claude sessions to see what other agents are working on |
| **algorithmic-art** | Create generative art using p5.js with seeded randomness and interactive controls |
| **blast-radius** | Map full impact of a proposed change before making it |
| **bouncer** | Pre-flight risk check before starting significant work |
| **brand-guidelines** | Apply Anthropic's official brand colors and typography to any artifact |
| **browse** | Browse the web, read pages, extract information, interact with websites |
| **browser-use** | Automate browser interactions for web testing, form filling, and data extraction |
| **canvas-design** | Create visual art and design in .png and .pdf using design philosophy |
| **cold-outreach** | Write effective cold outreach messages for sales, partnerships, or networking |
| **compass** | Strategic direction check - assess whether current work aligns with stated priorities |
| **cost** | Estimate and analyze costs for AI/cloud services and infrastructure |
| **debug** | Systematic root-cause debugging workflow for errors and unexpected behavior |
| **deep-audit** | Comprehensive codebase or system audit with prioritized findings |
| **deploy** | Deploy projects to Vercel, Render, Docker, or Supabase |
| **dns** | IONOS DNS management: add, update, delete records via API |
| **doc-coauthoring** | Structured 3-stage workflow for co-authoring documents and specs |
| **docker-deploy** | Self-hosted Docker deployment for containerized services |
| **docx** | Create, read, edit, and manipulate Word documents (.docx files) |
| **email-check** | Check, read, and search emails across IMAP accounts without marking as read |
| **food-finder** | Find restaurants and food delivery options near a location via Swiggy + Google Maps |
| **frontend-design** | Create distinctive, production-grade frontend interfaces with high design quality |
| **geo** | Geographic data validator for aviation/travel apps: IATA codes, distances, routes |
| **gh-launch** | GitHub repo launch checklist: secret scan, README polish, SEO, license, go public, distribution |
| **health** | System audit: Docker, Chrome, mounts, orphans, disk, memory |
| **internal-comms** | Write internal communications: 3P updates, newsletters, FAQs, incident reports |
| **issue** | GitHub issue management with multi-account switching and per-project label conventions |
| **linkedin-copy** | Write LinkedIn posts, profile copy, and professional content |
| **mcp-builder** | Guide for creating high-quality MCP servers in TypeScript or Python |
| **morning** | Daily briefing: unread emails, open issues, workplans, todos, system health |
| **negotiator** | Negotiation analyst for high-stakes deals: BATNA, message scoring, counter-offers |
| **new-project** | Scaffold a new project with standard setup, GitHub repo, and platform config |
| **pdf** | Read, merge, split, rotate, create, and OCR PDF files |
| **post-to-x** | Cross-post LinkedIn content to X (Twitter) with text adaptation and media upload |
| **pptx** | Create, read, edit, and design PowerPoint presentations (.pptx files) |
| **product** | Product strategy and UX decision-making for user-facing features |
| **qa** | Analyze a diff and identify affected pages, routes, and systems |
| **recall** | Post-compaction context recovery from session transcripts |
| **republic-design** | Republic-style design reviewer and scorer for pitch decks and investor materials |
| **retro** | Run a retrospective on a completed sprint, project, or time period |
| **review-video** | Review videos by extracting frames and analyzing them visually |
| **seo** | Technical SEO auditor: crawlability, schema.org, sitemaps, Core Web Vitals |
| **session-learn** | Meta-skill: derive new skills and CLAUDE.md rules from past session analysis |
| **ship** | Sync, test, review, push, and create a PR for code changes |
| **skill-creator** | Guide for creating new skills that extend Claude's capabilities |
| **slack-gif-creator** | Create animated GIFs optimized for Slack with PIL utilities and animation concepts |
| **slide-design** | Visual design system for high-quality presentation slides |
| **subagent-templates** | Templates and patterns for spawning and coordinating parallel Claude agents |
| **target-loop** | Iterative improvement loop for any target output until it hits a quality bar |
| **theme-factory** | Apply one of 10 pre-set color/font themes to any artifact (slides, docs, HTML) |
| **ui-audit** | UX/product review + wireframe comparison with Playwright screenshots and CSS extraction |
| **ux-audit** | Independent UX audit using Gemini as judge, scoring 7 UX dimensions with screenshots |
| **vault** | Context vault operations: todos, log entries, vault search, strategy docs |
| **video-edit** | AI-powered video editing: trim, concat, overlays, audio mix, voiceover, social export |
| **wa** | WhatsApp read/send with safe verification gate and SQLite DB access |
| **webapp-testing** | Test local web applications using Playwright |
| **web-artifacts-builder** | Build complex claude.ai HTML artifacts with React, Tailwind CSS, and shadcn/ui |
| **workplan** | Create, update, and close work plans for multi-step tasks |
| **xlsx** | Create, read, edit, and analyze Excel spreadsheets (.xlsx files) |
| **yc-pitch-deck** | Create YC-optimized investor pitch decks with slide structure and storytelling arc |
| **yc-video** | Plan, audit, and score startup launch videos using YC-grade production standards |

## Customization

Many skills reference environment variables or project-specific paths that you'll need to configure:

- `email-check`: Set up IMAP credentials for your email accounts
- `deploy`: Update with your project's specific deployment commands
- `compass`: Point to your own strategy/status file
- `new-project`: Update the default GitHub organization

Skills are designed to be starting points. Edit them to match your workflow.
