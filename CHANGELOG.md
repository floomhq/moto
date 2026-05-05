# Changelog

## Unreleased

- Added demo GIF framework (`docs/demos/`) with asciinema + agg recording workflow
- Added `whatsapp/README.md` demo placeholder
- README diet: trimmed main README to landing-page format
- Added architecture diagram (`assets/architecture.svg`)
- Added comparison table vs bare Claude Code
- Added FAQ section

## 2026-04-27

- Renamed repo from `buildingopen/moto` to `floomhq/fstack`
- Added 17th hook: `sandbox-heavy-tasks.sh` for memory-hungry command interception
- Added `ai-sidecar-health` script for provider verification
- Expanded skills catalog to 60+ commands

## 2026-04-15

- Added low-cost AI sidecar routing (Groq, OpenRouter, NVIDIA NIM, local Ollama)
- Added `enforce-hetzner-heavy-tasks.sh` hook for CPU task routing
- Added `rate-limit-auto-resume.sh` with macOS `at` scheduling

## 2026-03-25

- Initial public release (formerly `buildingopen/claude-setup`)
- Extracted from 500+ real Claude Code sessions
- Core: CLAUDE.md templates, 17 safety hooks, skills system, memory pattern
- Mac + remote Linux workstation integration
- WhatsApp gateway, Gmail IMAP, browser automation
