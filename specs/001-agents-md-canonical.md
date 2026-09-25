# 001 — AGENTS.md as the canonical workflow file

**Status:** done
**Owner:** Jawad · **Ticket:** none · **Branch:** feat/agents-md

## Goal
`/init-standards` writes the workflow block only to `CLAUDE.md`, which most non-Claude tools
don't read. Make `AGENTS.md` the single source of the rules, with `CLAUDE.md` importing it, so
every tool on a mixed team gets the same rules with no copy step and no drift.

## User stories
- As a Cursor/Codex/Copilot user on a team that ran `/init-standards`, I want the workflow rules loaded without doing anything extra.
- As a Claude Code user, I want nothing to change for me.

## Acceptance criteria
- **AC-1:** Given a repo with no `AGENTS.md`/`CLAUDE.md`, when `/init-standards` runs, then the block is written to `AGENTS.md` and `CLAUDE.md` contains `@AGENTS.md`.
- **AC-2:** Given an existing `AGENTS.md` and/or `CLAUDE.md` with team content, when `/init-standards` runs, then only the marked block in `AGENTS.md` is added/replaced, and `CLAUDE.md` gains a single `@AGENTS.md` line if missing; other content is untouched.
- **AC-3:** Given a repo initialised with an older version (block in `CLAUDE.md`), when `/init-standards` runs in update mode, then the block is moved to `AGENTS.md` and replaced in `CLAUDE.md` by `@AGENTS.md`.
- **AC-4:** The session-start hook message and every skill that names the conventions file refer to `AGENTS.md` (with `CLAUDE.md` still accepted).
- **AC-5:** README and `docs/setup.md` no longer tell users to copy the block into `AGENTS.md`.
- **AC-6:** Version is 0.4.0 in `plugin.json` and both places in `marketplace.json`, and `claude plugin validate` passes for the marketplace and the plugin.

## Out of scope
- Asking which tool the user uses (rejected: mixed teams, stale answers).
- Writing per-tool hook/agent config automatically. `/init-standards` only points to the setup guide.

## Affected areas
- `plugins/ship-standards/skills/init-standards/SKILL.md` — step 4 writes `AGENTS.md` + `@AGENTS.md` import; migration.
- `plugins/ship-standards/skills/init-standards/references/claude-md-block.md` → `agents-md-block.md`.
- `plugins/ship-standards/hooks/scripts/session-start.sh` — message.
- `skills/engineering-standards`, `skills/merge-critique` (+ `references/decision-log.md`) — file name mentions.
- `README.md`, `plugins/ship-standards/README.md`, `docs/setup.md`.
- This repo's own `CLAUDE.md` → `AGENTS.md`.
- `agents/critique-reviewer.md` — frontmatter fix (needed for AC-6).

## Data model changes
none

## API contract
none

## Edge cases & failure modes
- `CLAUDE.md` already contains `@AGENTS.md` → don't add a second one.
- Tools that read both files (OpenCode reads `AGENTS.md` first and ignores `CLAUDE.md`) → fine, same content.
- Gemini CLI reads neither by default → the setup guide covers the `context.fileName` setting.

## Test plan
| AC | Test type | Location |
|---|---|---|
| AC-1–AC-3 | manual: follow the skill steps against the spec | `skills/init-standards/SKILL.md` |
| AC-4, AC-5 | grep for stale `CLAUDE.md`-only wording | `/verify` + `grep -rn CLAUDE.md` |
| AC-6 | `claude plugin validate`, `bash -n` | `/verify` |

## Open questions
- none
