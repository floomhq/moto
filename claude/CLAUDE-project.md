# Project: <YOUR_PROJECT_NAME>

<!-- Drop this file in your project root as CLAUDE.md -->
<!-- It overrides/extends the global ~/.claude/CLAUDE.md for this project only -->

## Tech Stack

<!-- Customize: list your actual stack -->

| Layer | Technology |
|-------|-----------|
| Language | TypeScript / Python / Go / ... |
| Framework | Next.js / FastAPI / ... |
| Database | PostgreSQL (Supabase) / SQLite / ... |
| ORM | Prisma / Drizzle / SQLAlchemy / ... |
| Styling | Tailwind CSS / CSS Modules / ... |
| Deployment | Vercel / Docker / AWS / ... |
| CI/CD | GitHub Actions / ... |

## Key Files & Architecture

<!-- Customize: map out the files that matter most -->

```
src/
  app/              # Routes / pages
  components/       # Shared UI components
  lib/              # Utilities, API clients, helpers
  hooks/            # Custom React hooks (if applicable)
  types/            # Shared type definitions
```

| File / Dir | Purpose |
|-----------|---------|
| `src/app/layout.tsx` | Root layout, providers, global styles |
| `src/lib/db.ts` | Database client singleton |
| `src/lib/auth.ts` | Authentication helpers |
| `.env.example` | All required env vars (documented) |

## Project-Specific Rules

<!-- Customize: override or extend global rules for this project -->

- **Branch strategy**: `main` is production. Feature branches off `main`. PRs required.
- **Commit style**: conventional commits (`feat:`, `fix:`, `chore:`, `refactor:`)
- **Import style**: absolute imports via `@/` alias (e.g., `@/lib/db`)

## Testing

<!-- Customize: describe your testing conventions -->

| Type | Tool | Command |
|------|------|---------|
| Unit | Vitest / Jest / pytest | `npm test` |
| Integration | Vitest / pytest | `npm run test:integration` |
| E2E | Playwright | `npx playwright test` |

- Tests live next to source files (`*.test.ts`) or in `__tests__/` dirs
- Run tests before every commit: `npm test`
- Minimum coverage: none enforced, but new code needs tests

## Deployment

<!-- Customize: describe how this project deploys -->

| Environment | URL | Branch | Auto-deploy |
|-------------|-----|--------|-------------|
| Production | `<YOUR_PROD_URL>` | `main` | Yes |
| Preview | `<YOUR_PREVIEW_URL>` | `preview` / PR branches | Yes |
| Local | `http://localhost:3000` | any | N/A |

**Deploy checklist:**
1. All tests pass locally
2. `npm run build` succeeds with no warnings
3. Env vars match between `.env.example` and deployment platform
4. Database migrations applied (if any)

## Terminology

<!-- Customize: project-specific terms that Claude should know -->

| Term | Meaning |
|------|---------|
| `<term>` | `<definition>` |

## Known Gotchas

<!-- Customize: things that have bitten you before -->

- Example: "The API returns dates as UTC strings without Z suffix, always parse with `parseISO`"
- Example: "Supabase RLS is enabled, queries without auth context return empty arrays (not errors)"
