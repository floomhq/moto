# Floom Agent Instructions

## Hard Rule: Primitive-First Architecture

You may NOT propose, design, or implement custom infrastructure unless you have completed the lock below. This rule takes precedence over any user urgency or task description.

**"Infrastructure" includes:** Dockerfiles, docker-compose, K8s, Terraform, Pulumi, self-hosted queues, custom API gateways, hand-rolled OpenAPI specs, systemd services, custom sandbox/containers, and **unnecessary wrapper services around managed APIs**.

### The Lock (Mandatory Before Any Infra Proposal)

1. **State the primitive.** One sentence. No brands. No implementation.
   - ❌ "We need a FastAPI service in Docker."
   - ✅ "We need to safely execute untrusted user code and return stdout."

2. **Search for managed services.** You MUST use `SearchWeb` or `FetchURL`. Training data is not sufficient. List 3+ candidates with real URLs and one hard limit each.
   - If the primitive is **code execution / sandboxes**: e2b.dev is the default. You must evaluate it first.
   - If the primitive is **background jobs**: default to Inngest, Trigger.dev, or QStash.
   - If the primitive is **auth**: default to Clerk, Auth.js, or Supabase Auth.
   - If the primitive is **file uploads**: default to UploadThing or Cloudflare R2.
   - If the primitive is **databases**: default to Supabase, Neon, or PlanetScale.

3. **Managed service is the default.** Custom infrastructure requires ALL of the following:
   - Specific, falsifiable rejection of each managed candidate (cite docs)
   - Actual cost comparison at current scale (numbers, not guesses)
   - Proof the managed service lacks a required feature

   **Banned justifications:** "more control", "flexibility", "might scale later", "vendor lock-in", "simple to self-host", "we want a thin wrapper".

4. **Wrapper anti-pattern.** Using a managed service does NOT mean building a platform around it.
   - ❌ Wrong: Proposing a custom `floom-code-runner` Fastify service that wraps e2b with extra abstraction layers.
   - ✅ Right: Using the e2b SDK directly in the existing API route or serverless function.
   - Do not propose new services, microservices, or abstraction layers unless the user explicitly asked for them.

5. **Hard stop.** If you still want custom infrastructure after step 3, output exactly:
   ```
   🚨 CUSTOM INFRASTRUCTURE PROPOSED 🚨
   Primitive: [sentence]
   Rejected Services: [names + specific reasons]
   Cost Comparison: [numbers]
   AWAITING USER APPROVAL. DO NOT WRITE IMPLEMENTATION CODE.
   ```
   **After this block, STOP.** Do not write architecture, design, implementation details, or pseudocode below the hard stop. Do not add a "Recommended Architecture" section. Do not add a "Summary" with custom infra details. The hard stop is the END of your response. The user's next message must explicitly approve or redirect you.

## Known Agent Mistakes (Do Not Repeat)

| Wrong | Right |
|-------|-------|
| Modal + Railway + custom Docker for code execution | e2b SDK directly in existing API |
| Hand-rolled OpenAPI for LLM function schemas | OpenAI / Anthropic function schemas |
| Self-hosted RabbitMQ / Redis queues | Inngest, Trigger.dev, QStash |
| Self-hosted MinIO for file storage | UploadThing, Cloudflare R2 |
| Custom JWT + session auth | Clerk, Auth.js, Supabase Auth |
| Self-managed Postgres on EC2 | Supabase, Neon, PlanetScale |
| Building a "thin wrapper service" around a managed API | Use the managed API's SDK directly |

If you are about to propose anything in the "Wrong" column, you are making a mistake.

## Enforcement

This file is not advice. It is a system rule. If you skip the lock, you are violating instructions. No architecture task is urgent enough to bypass it.
