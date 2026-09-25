---
name: engineering-standards
description: Default engineering standards for building features — structure, TypeScript/NestJS/Next.js/Python practices, testing strategy, security and AI-feature practices. Use whenever writing or changing code in a repo that uses ship-standards, when scaffolding a new project, or when the user asks "what's the right way to structure/test this". The repo's own CLAUDE.md conventions always override these defaults.
---

# Engineering Standards

These are **defaults**. Precedence: user's instruction in this session > repo `CLAUDE.md`
conventions > existing code patterns > this file. In an existing codebase, consistency with
what's there beats the "ideal" pattern. If a default here would conflict, follow the repo and
optionally note the difference in the decision log.

## Build rules

- One responsibility per file/module. If you can't describe it in one line, split it.
- Business logic in services/domain modules — not in controllers, route handlers, or
  React components.
- Validate at the boundary (DTOs with class-validator in NestJS, Zod in Next.js/Node),
  trust types inside.
- No `any` without a comment explaining why. Prefer narrow types over casts.
- Errors: throw typed/domain errors, map to HTTP at the edge. Never swallow errors silently.
- Config via env with validation at startup; never hardcode secrets or URLs.
- Keep changes inside the spec's scope. Put unrelated improvements in the report instead.

## Testing strategy

See `references/testing.md`. Minimum bar per change: each acceptance criterion covered by
at least one test, and the full `test` command passes locally before claiming done.

## Security checklist (every change touching input, auth, or data)

- AuthZ checked in the service layer, not only by the route guard or UI.
- Parameterised queries / ORM only; no string-built SQL.
- No secrets, tokens, or PII in logs.
- File uploads: type and size limits enforced server-side.

## AI features (when the product itself calls LLMs)

- Wrap providers behind one interface so models can be swapped.
- Trace every LLM call (Langfuse or OpenTelemetry): prompt version, model, latency, tokens.
- Keep prompts in versioned files, not inline strings scattered across the code.
- Maintain a small eval set (20–50 real cases) in `evals/`; run it when prompts or
  models change, and record the result in the decision log.
- Validate structured LLM output with a schema (Zod/Pydantic) and handle failures.

## New-project defaults

Monorepo (pnpm + Turborepo) with `apps/web` (Next.js), `apps/api` (NestJS), `packages/*`
for shared types/config. Postgres via Docker Compose for local dev and integration tests.
Vitest for web and packages, Jest for NestJS, Playwright for e2e, Pytest for Python services.
