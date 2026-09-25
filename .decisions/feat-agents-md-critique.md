# Merge Critique: feat/agents-md

**Task:** Make AGENTS.md the single file for workflow rules, imported by CLAUDE.md (spec 001).
**Base:** main · **Files changed:** 17 · **Inputs missing:** no manual run of /init-standards against a real repo

## Summary
`/init-standards` now writes the workflow block to `AGENTS.md`, which most agents read, and adds
an `@AGENTS.md` import to `CLAUDE.md` for Claude Code. There's one copy of the rules and no manual
copy step. Repos set up by an older version are migrated, including the old symlink setup.
Wording, docs and this repo's own files follow the change, the version is 0.4.0, and the broken
critique-reviewer frontmatter is fixed. **Check most carefully:** the migration text in
`init-standards/SKILL.md` step 4.3. It has never been run against a real repo.

## Files
| File | Status | Responsibility | Why it exists / changed |
|---|---|---|---|
| `plugins/ship-standards/skills/init-standards/SKILL.md` | modified | Setup steps | Core change: AGENTS.md block, CLAUDE.md import, migration. *Evidence: spec AC-1–3* |
| `.../init-standards/references/agents-md-block.md` | renamed | Block template | The old name pointed to the wrong file; content is unchanged. *Evidence: decision-log* |
| `hooks/scripts/session-start.sh` | modified | Session context | The message named CLAUDE.md. *AC-4* |
| `skills/engineering-standards/SKILL.md`, `skills/merge-critique/SKILL.md`, `.../decision-log.md` | modified | File-name mentions | *AC-4* |
| `README.md`, `plugins/ship-standards/README.md`, `docs/setup.md` | modified | User docs | Removes the copy/symlink step and the CLAUDE.md fallbacks for each tool. *AC-5* |
| `AGENTS.md`, `CLAUDE.md` | moved / new stub | This repo's own rules | Applies the same layout to this repo |
| `agents/critique-reviewer.md` | modified | Reviewer agent | Frontmatter now parses. Only the indentation changed. *Evidence: `claude plugin validate`* |
| `.claude-plugin/marketplace.json`, `plugin.json` | modified | Version | 0.4.0. *AC-6* |
| `specs/001-…`, `.decisions/feat-agents-md*.md` | added | Spec, decision log | Workflow |

## Key decisions
### 1. AGENTS.md is the only copy, and CLAUDE.md imports it
- **Chose:** the block goes in AGENTS.md, and CLAUDE.md gets `@AGENTS.md`
- **Rejected:** asking which tool the team uses; writing the block into both files
- **Tradeoff:** one source for every tool. Gemini CLI still needs one setting.
- **Evidence:** decision-log, plus the vendor docs linked in `docs/setup.md`. The reason originally recorded, "Claude Code doesn't read AGENTS.md", was **wrong for newer versions**. The skill text now gives the right reason: older versions don't read it, and any CLAUDE.md without the import hides it.

### 2. Migration: a symlink or stub is removed first, and AGENTS.md wins a conflict
- **Chose:** delete a symlinked or stub AGENTS.md before writing. If the two blocks differ, show a diff and keep AGENTS.md by default.
- **Rejected:** ignoring these cases
- **Evidence:** the old `docs/setup.md` told users to symlink. Without this step, CLAUDE.md would import itself and the block would be lost. **judgment call** on which file wins.

## Risks and weak spots
- AC-1–3 were checked by reading, not by running `/init-standards` on a scratch repo.
- It's unverified that Claude Code v2.1.277+ reads AGENTS.md natively; only the reviewer reported it. The design works either way.
- The CLAUDE.md fallback settings for Codex and Copilot were removed from the docs. Users who stay on 0.3.x and don't re-run init lose that guidance.
- This repo's own `AGENTS.md` doesn't have the YAGNI paragraph from the template. That drift started in 0.2.0 and this PR doesn't fix it.

## Spec coverage
| AC | Implemented | Test |
|---|---|---|
| AC-1 | yes, `init-standards/SKILL.md` 4.2–4.3 | manual read only |
| AC-2 | yes | manual read only |
| AC-3 | yes, including symlinks and conflicts | manual read only |
| AC-4 | yes | grep: no instruction to put the rules in CLAUDE.md remains |
| AC-5 | yes | grep: no copy/symlink step remains |
| AC-6 | yes | `claude plugin validate` ×2 passes; version grep |

## Testing
- **Tested (run):** `bash -n` on the hook scripts; `claude plugin validate .` and `claude plugin validate plugins/ship-standards`; `session-start.sh` and `stop-check.sh` smoke-run on this branch; greps for AC-4 and AC-5.
- **Not tested:** a real `/init-standards` run (new repo, existing files, migration); the other tools loading `AGENTS.md`; Claude Code loading the `@AGENTS.md` import in a new session.

## Out of scope / unrelated changes
- Pointer to the setup guide in init-standards step 3. It's small, and the spec allows it.

## Questions the reviewer should ask
1. Should we run `/init-standards` once on a scratch repo that has an old CLAUDE.md block before tagging 0.4.0?
2. Should this repo's AGENTS.md get the YAGNI paragraph now or in a follow-up?
