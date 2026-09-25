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
- existing `AGENTS.md`, `CLAUDE.md` (does it already hold a ship-standards block or `@AGENTS.md`?), `CONTRIBUTING.md`, `.github/workflows/`
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
- If the team also uses other agents (Cursor, Codex, Gemini CLI, …), point them to the setup
  guide for per-tool hooks and the reviewer agent:
  https://github.com/Jawad606/standard-ship-plugins/blob/main/docs/setup.md

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
2. **`AGENTS.md`** — the one place the workflow rules live (read by Cursor, Copilot, Codex,
   Antigravity, OpenCode, Windsurf, Cline). Insert the block from `references/agents-md-block.md`
   between `<!-- ship-standards:start -->` and `<!-- ship-standards:end -->` markers.
   Create the file if absent; if it exists, add or replace only that block and never touch
   the rest. Fill the "Project conventions" section with what Step 2 actually found, with
   file examples.
3. **`CLAUDE.md`** — import `AGENTS.md` so Claude Code loads it in every version (older
   versions don't read `AGENTS.md`, and any `CLAUDE.md` without the import hides it). Make sure
   the file has a line that is exactly `@AGENTS.md` or `@./AGENTS.md`, outside backticks or
   code blocks (a mention inside code doesn't import). Add it at the top if missing; create the
   file if absent. Don't copy the block here.

   **Migrating** (runs in update mode too) from an older setup where the block is in `CLAUDE.md`:
   - If `AGENTS.md` is a symlink to `CLAUDE.md`, or a text stub containing just `CLAUDE.md`
     (a symlink checked out with `core.symlinks` off), delete it first, then create a real file.
   - Move the block into `AGENTS.md` and delete it from `CLAUDE.md`, keeping everything else in
     `CLAUDE.md`.
   - If both files already have a ship-standards block and they differ, show the user a diff
     and keep the `AGENTS.md` version unless they choose otherwise.
4. **`specs/README.md`** and **`specs/000-template.md`** (copy from the `spec` skill's
   `references/spec-template.md`).
5. **`.decisions/.gitkeep`**.
6. **PR template**: `.github/pull_request_template.md` from `references/pull_request_template.md`.
   GitHub fills every new PR body with it automatically (web UI and interactive `gh pr create`).
   If the repo already has a template (`.github/pull_request_template.md`,
   `.github/PULL_REQUEST_TEMPLATE/`, or `docs/`), don't overwrite it: show a merged version
   that keeps the team's sections and adds the missing ones, and apply it only on a yes.

Only if the user agreed:

7. **CI** — adapt `references/ci-workflow.yml` to the detected commands and package manager.
   In existing repos with CI, propose a diff to the current workflow instead of a new file.
8. **Missing test tooling** — New mode defaults: Vitest (TS libs/Next.js), Jest (NestJS default),
   Pytest (Python), Playwright (e2e). Existing mode: fill gaps with whatever the repo already
   uses; don't add Vitest to a Jest repo.
9. **Graphify** — suggest `uv tool install graphifyy && graphify claude install --project`
   and run `/graphify .` once the codebase has meaningful size.

## Step 5 — New mode extras

For a new project, ask 2–3 questions (app type, stack confirmation, monorepo or single app),
then scaffold using the defaults in the `engineering-standards` skill, and write the first
spec together with the user before any feature code.

## Step 6 — Report

Finish with: what was set up, what gaps remain, and the next command to run
(usually `/spec <first feature>` or `/verify` to confirm the commands work).
