# Primitive-First Architecture (Enforced)

**ZERO TOLERANCE.** You may not write, modify, or propose any infrastructure, deployment, networking, containerization, or platform code until this skill is fully satisfied. "Infrastructure" includes: Dockerfiles, docker-compose, K8s YAML, Terraform, Pulumi, CI/CD beyond basic GitHub Actions, self-hosted queues, custom API gateways, and hand-rolled OpenAPI specs.

## Phase 1: Mandatory Stack Archaeology (Cannot Skip)

Read and cite the following files in THIS repository:
- `package.json`, `requirements.txt`, `Cargo.toml`, `go.mod`, or equivalent dependency manifests
- `README.md`
- Any existing `docker*`, `infra/`, `deploy*`, `terraform*`, `pulumi*` files or directories
- `CLAUDE.md` or `AGENTS.md` if present
- Any existing `.decisions/` or `adr/` files

Output a bullet list of:
- Current runtime/framework versions
- Existing deployment platform
- Current database/cache/message queue
- Any existing managed services already in use

If these files do not exist, state EXPLICITLY: "No [file] found."

## Phase 2: Core Primitive Declaration

State the primitive in exactly this format:

**Primitive:** [One sentence. No brand names. No implementation details.]

Examples:
- ❌ "We need a Docker container running FastAPI with Celery."
- ✅ "We need to accept arbitrary Python code from users, run it in a sandbox, and return stdout plus any generated files."
- ❌ "We need a Kubernetes cluster with RabbitMQ."
- ✅ "We need to enqueue background jobs reliably and retry them if they fail."

## Phase 3: Mandated Web Research (Anti-Hallucination Lock)

You MUST use web search (`SearchWeb`) or fetch a real URL (`FetchURL`) to find current (2024–2025) managed services for this primitive.

Requirements:
- List minimum 3 candidates
- Provide a real, working URL for each (not a hallucinated one)
- State pricing model and one hard limit (timeout, concurrency, file size, region availability, etc.)
- If the primitive involves **running user code, sandboxes, or untrusted code execution**: **e2b.dev MUST be the first candidate evaluated.** You are not allowed to omit it.

If you cannot fetch or search a real URL, you have NOT completed this phase. Do not proceed.

## Phase 4: The Default Rule

**Managed service is the DEFAULT. Custom infrastructure is the EXCEPTION.**

You may only propose custom infrastructure if ALL of the following are true:
1. You have a specific, falsifiable rejection for EACH managed service candidate (not generic "doesn't fit our needs")
2. You have compared costs at Floom's current/expected scale (cite actual numbers, not guesses)
3. You have checked the managed service's documentation and confirmed it lacks a required feature (cite the doc URL)

**Banned justifications (will be rejected):**
- "We need more control."
- "For future flexibility."
- "We might scale to X."
- "It's cheaper at scale." (without actual numbers)
- "We want to avoid vendor lock-in." (for an MVP or early-stage feature)
- "It's simple to self-host." (it is never simple)

## Phase 5: Hard Stop Gate

If you are proposing ANY custom infrastructure after Phase 4, you MUST stop and output exactly:

```
🚨 CUSTOM INFRASTRUCTURE PROPOSED 🚨

Primitive: [from Phase 2]
Rejected Services: [from Phase 3 with SPECIFIC feature/cost/limit reasons]
Justification: [from Phase 4]
Cost Comparison: [actual numbers, not guesses]

AWAITING USER APPROVAL. DO NOT PROCEED WITH IMPLEMENTATION.
```

**You are FORBIDDEN from writing implementation code** (Dockerfiles, YAML, configs, scripts) until the user explicitly approves in writing.

## Phase 6: Decision Record

Regardless of outcome, create a decision record so the next agent doesn't re-research the same question.

- If custom infrastructure is approved: create `.decisions/ADR-NNN-[short-name].md`
- If a managed service is chosen: create `.decisions/ADR-NNN-use-[service].md`

Template:
```markdown
# ADR-NNN: [Title]

Date: [YYYY-MM-DD]
Primitive: [from Phase 2]
Candidates Considered: [list with URLs]
Decision: [chosen approach]
Rationale: [specific reasons]
Rejected Alternatives: [specific reasons for each rejection]
```

## Floom-Specific Landmines (DO NOT REPEAT)

The following were proposed by agents in the past and were objectively wrong. If you are considering anything in the **Wrong Path** column, you are making the same mistake again.

| Primitive | Wrong Path (Past Agent Mistakes) | Correct Default |
|---|---|---|
| Run user code safely | Modal + Railway + custom Docker + hand-rolled OpenAPI | **e2b SDK** |
| Background jobs / queues | Self-hosted RabbitMQ, custom worker pools, Redis queues | **Inngest, Trigger.dev, QStash** |
| API schemas for LLM functions | Hand-written OpenAPI from scratch | **OpenAI / Anthropic function schemas** |
| File uploads / assets | Self-hosted MinIO, custom S3 wrapper | **UploadThing, Cloudflare R2** |
| Authentication | Custom JWT + session store + hand-rolled OAuth | **Clerk, Auth.js, Supabase Auth** |
| Database hosting | Self-managed Postgres on EC2/DigitalOcean | **Supabase, Neon, PlanetScale** |
| Email | Self-hosted SMTP, custom email service | **Resend, Loops, Postmark** |
| Scheduling / Cron | Self-hosted cron container, node-cron | **QStash, Inngest, Trigger.dev** |

## Enforcement Note

This skill is not a suggestion. It is a hard pre-condition.

**Writing a Dockerfile when e2b exists is not helpful—it is expensive.**

Do not let the user's urgency or your desire to be helpful override this lock. If you are unsure whether something counts as "infrastructure," err on the side of running this skill.
