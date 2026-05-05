# Low-Cost AI Sidecars

`fstack` treats frontier agents as the control plane and routes bounded text work to cheaper sidecars. The goal is simple: spend premium model budget on judgment, orchestration, debugging, architecture, and final review; use cheaper/free models for narrow stateless work.

## Routing

| Route | Typical use | Notes |
|-------|-------------|-------|
| Gemini free / OAuth wrapper | broad repo summaries, docs drafts, test plans | Good for large text-in/text-out analysis when privacy constraints allow |
| Groq | single-file review, diff chunks, error logs | Fast stateless reviewer; prefer prompts with tight scope |
| OpenRouter free | backup free route | Expect provider throttling and model changes |
| NVIDIA NIM | hosted specialist sidecar | Use stronger models for difficult reasoning or code-specific second opinions |
| Local Ollama on the remote box | private/offline bounded work | Slow on CPU; advisory only, not final correctness authority |

## Recommended pattern

- Use hosted sidecars for stateless research, summaries, diff review, and second opinions.
- Use NVIDIA `deepseek-ai/deepseek-v4-pro` for high-depth reasoning, difficult code analysis, long-context synthesis, and planning.
- Use NVIDIA `qwen/qwen3-coder-480b-a35b-instruct` for code-specific second opinions.
- Use a local Ollama model only when privacy/offline locality matters and the prompt is self-contained.
- Keep final authority with Claude Code, Codex, tests, screenshots, builds, and direct evidence.

## API key storage

Provider keys belong in a local secret store, never in repos or shell startup files.

- **macOS**: Keychain services such as `codex:GROQ_API_KEY`, `codex:NVIDIA_API_KEY`, `codex:OPENROUTER_API_KEY`
- **Linux remote**: `~/.config/ai-sidecar/keys.json` with directory mode `700` and file mode `600`

## Scripts

- `ai-sidecar` — Call Groq, OpenRouter, or NVIDIA for bounded stateless text work
- `ai-sidecar-health` — Verify configured sidecar providers with tiny health checks
- `ai-provider-key` — Store sidecar provider keys in Keychain or a 0600 Linux key file
