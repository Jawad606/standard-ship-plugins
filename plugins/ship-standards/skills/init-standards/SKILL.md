---
name: init-standards
description: Set up the ship-standards workflow (specs, decision logs, tests, verification, CI) in a repository. Works in two modes — adopting an EXISTING codebase without overwriting its conventions, or bootstrapping a NEW project. Use when the user runs /init-standards, says "set up standards", "add the workflow to this repo", "onboard this project", "make this repo agent-ready", or starts a new project and wants the standard setup.
---

# Init Standards

Install the workflow into the current repo. The guiding rule: **the repo's existing
conventions win over this plugin's defaults.** The plugin adds a process (spec → build →
test → evaluate); it does not impose a new code style on a codebase that already has one.

## Step 1 — Detect mode

Inspect the repo root before changing anything:

- `git status` (must be a git repo; if dirty, tell the user and suggest committing first)
- `package.json` / `pnpm-workspace.yaml` / `turbo.json` / `pyproject.toml` / `requirements.txt`
- existing `CLAUDE.md`, `AGENTS.md`, `CONTRIBUTING.md`, `.github/workflows/`
- `.ship-standards.json` (already initialised → switch to "update" mode: only refresh what changed)

**Existing mode**: source files already exist. **New mode**: empty or near-empty repo.

## Step 2 — Discover (existing mode)

Build a picture of how this repo already works. Record findings; don't fix anything yet.

1. **Stack & package manager**: from lockfiles (`pnpm-lock.yaml`, `yarn.lock`,
   `package-lock.json`, `bun.lockb`, `uv.lock`, `poetry.lock`).
2. **Commands**: read `scripts` in every `package.json` (and `Makefile`, `pyproject`) and map
   them to: `lint`, `typecheck`, `test`, `e2e`, `build`. If a command doesn't exist, mark it
   missing — never invent one that isn't runnable.
3. **Test setup**: Vitest / Jest / Pytest / Playwright / Cypress configs, and where tests live.
4. **Conventions**: open 2–3 representative modules per app (e.g. one NestJS module, one
   Next.js route, one shared util). Note folder structure, naming, where business logic lives,
   error handling, validation library, DB access pattern.
5. **CI**: what existing workflows already check.
6. **Graphify**: check `graphify-out/` or whether `graphify` is on PATH.

## Step 3 — Present the plan and ask

Show the user a short plan before writing anything:

- What was detected (stack, commands, conventions — 5–10 lines)
- Files that will be **created** vs **edited**
- Gaps found (e.g. "no e2e tests", "no typecheck script", "CI doesn't run tests")
- Optional additions, each needing a yes: installing deps, adding CI, installing Graphify

Never install dependencies, add CI workflows, or edit existing config without an explicit yes.

## Step 4 — Write files

Always (both modes):

1. **`.ship-standards.json`** — the source of truth other skills and hooks read:
   ```json
   {
     "version": "0.1.0",
     "mode": "existing",
     "baseBranch": "main",
     "commands": { "lint": "pnpm lint", "typecheck": "pnpm typecheck", "test": "pnpm test", "e2e": null, "build": "pnpm build" },
     "specsDir": "specs",
     "decisionsDir": ".decisions",
     "enforceDecisionLog": true
   }
   ```
2. **`CLAUDE.md`** — insert the block from `references/claude-md-block.md` between
   `<!-- ship-standards:start -->` and `<!-- ship-standards:end -->` markers.
   If the file exists, add or replace only that block; never touch the rest. Fill the
   "Project conventions" section with what Step 2 actually found, with file examples.
3. **`specs/README.md`** and **`specs/000-template.md`** (copy from the `spec` skill's
   `references/spec-template.md`).
4. **`.decisions/.gitkeep`**.

Only if the user agreed:

5. **CI** — adapt `references/ci-workflow.yml` to the detected commands and package manager.
   In existing repos with CI, propose a diff to the current workflow instead of a new file.
6. **Missing test tooling** — New mode defaults: Vitest (TS libs/Next.js), Jest (NestJS default),
   Pytest (Python), Playwright (e2e). Existing mode: fill gaps with whatever the repo already
   uses; don't add Vitest to a Jest repo.
7. **Graphify** — suggest `uv tool install graphifyy && graphify claude install --project`
   and run `/graphify .` once the codebase has meaningful size.

## Step 5 — New mode extras

For a new project, ask 2–3 questions (app type, stack confirmation, monorepo or single app),
then scaffold using the defaults in the `engineering-standards` skill, and write the first
spec together with the user before any feature code.

## Step 6 — Report

Finish with: what was set up, what gaps remain, and the next command to run
(usually `/spec <first feature>` or `/verify` to confirm the commands work).
