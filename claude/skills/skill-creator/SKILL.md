---
name: skill-creator
description: Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.
---

# Skill Creator

This skill provides guidance for creating effective skills.

## About Skills

Skills are modular, self-contained packages that extend Claude's capabilities by providing
specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific
domains or tasks - they transform Claude from a general-purpose agent into a specialized agent
equipped with procedural knowledge.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

## Core Principles

### Concise is Key

The context window is a public good. Only add context Claude doesn't already have. Challenge each piece of information: "Does Claude really need this explanation?"

Prefer concise examples over verbose explanations.

### Anatomy of a Skill

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts)
```

#### SKILL.md (required)

- **Frontmatter** (YAML): Contains `name` and `description` fields (required). The description is the primary triggering mechanism - be clear and comprehensive about what the skill is and when to use it.
- **Body** (Markdown): Instructions loaded AFTER the skill triggers.

#### Bundled Resources (optional)

**Scripts (`scripts/`)**: Executable code for tasks that require deterministic reliability or are repeatedly rewritten. Token efficient, deterministic.

**References (`references/`)**: Documentation intended to be loaded as needed into context. Use for database schemas, API documentation, domain knowledge, company policies, detailed workflow guides.

**Assets (`assets/`)**: Files not intended to be loaded into context, but used within the output Claude produces. Templates, images, icons, boilerplate code, fonts.

#### What NOT to Include

Do NOT create extraneous documentation files (README.md, INSTALLATION_GUIDE.md, CHANGELOG.md, etc.). The skill should only contain information needed for an AI agent to do the job.

### Progressive Disclosure Design

Skills use a three-level loading system:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Claude

Keep SKILL.md body under 500 lines. Split content into separate files when approaching this limit.

## Skill Creation Process

1. Understand the skill with concrete examples
2. Plan reusable skill contents (scripts, references, assets)
3. Create the skill directory and SKILL.md
4. Implement resources and write SKILL.md
5. Test by using the skill on real tasks
6. Iterate based on real usage

### Writing the Description

The `description` field is the primary triggering mechanism. Include:
- What the skill does
- Specific triggers/contexts for when to use it
- All "when to use" information (the body is only loaded after triggering)

Example:
```yaml
description: "Comprehensive document creation, editing, and analysis. Use when Claude needs to work with professional documents (.docx files) for: (1) Creating new documents, (2) Modifying content, (3) Working with tracked changes, (4) Adding comments"
```

### Writing the Body

- Use imperative/infinitive form
- Keep to essentials - avoid what Claude already knows
- Reference bundled resources clearly: "See scripts/rotate_pdf.py"
- Use progressive disclosure: link to reference files for details

## Installation

Copy the skill directory to `~/.claude/commands/`:

```bash
cp -r my-skill/ ~/.claude/commands/my-skill/
```

The skill is then available as `/my-skill` in Claude Code.
