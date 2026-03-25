# Memory Index

<!-- This file is auto-loaded into every Claude conversation (first ~200 lines) -->
<!-- Keep it under 200 lines. For detailed notes, create topic files and link to them. -->
<!-- Update immediately after corrections; save patterns after 2+ confirmations -->

## Project Paths

| Project | Path | Status |
|---------|------|--------|
| Example Project 1 | `~/path/to/project1` | Active |
| Example Project 2 | `~/path/to/project2` | Legacy |

Add your projects here. Link to `memory/project-paths.md` if the list grows beyond 5 entries.

## Key Contacts

| Name | Phone | Role | Notes |
|------|-------|------|-------|
| Contact 1 | +1 234 567 8901 | Role | Notes |

Add contacts relevant to your work. Store WhatsApp JIDs in topic files.

## Writing Preferences

- **No em dashes** - Use commas, semicolons, colons instead
- **Clear & direct** - "State facts, not beliefs" (no "I think", "I believe", "It appears")
- **Tables over paragraphs** - Scannable, concise
- **No preambles** - Start with content, not "Sure!" or "I'd be happy to"

See `memory/communication.md` for full style guide.

## Communication Format

- **TLDR first** - Summary before details
- **Verify before implementing** - Check claims with evidence, don't assume
- **No sycophancy** - Don't say "great question" or agree to avoid conflict
- **Push back when right** - Honest pushback > unhelpful agreement

## Corrections

Track lessons learned from mistakes here. Each entry prevents a future error.

| Date | Mistake | Fix | Prevention |
|------|---------|-----|-----------|
| 2026-03-25 | Example error | How it was fixed | How to prevent next time |

Keep this section updated. Move complex topics to dedicated files.

## Infrastructure

- **Main server** - Example: dedicated server for heavy compute
- **Deployment** - Example: Vercel for frontend, custom server for API

See `memory/infrastructure.md` for detailed server list, SSH aliases, port mappings.

## Tools & APIs

| Service | Key Location | Expires |
|---------|--------------|---------|
| Example API | `~/.env.local` or memory | Date |

Store sensitive keys securely. Link to `memory/api-keys.md` if you have multiple services.

## Notes

- Raw session transcripts persist at `~/.claude/projects/*/` (JSONL, never deleted)
- Use `recall_search "keyword"` to recover compacted context
- Read memory/README.md for detailed system explanation
