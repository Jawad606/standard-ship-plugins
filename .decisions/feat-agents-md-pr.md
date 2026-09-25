## Summary
`/init-standards` now writes the workflow rules to **`AGENTS.md`**, which Cursor, Copilot, Codex, Antigravity, OpenCode, Windsurf and Cline read, and adds an `@AGENTS.md` import to `CLAUDE.md` for Claude Code. There's one copy of the rules, every tool gets them, and nothing has to be copied by hand. Bumps the plugin to **0.4.0**.

Spec: `specs/001-agents-md-canonical.md` · Full critique: `.decisions/feat-agents-md-critique.md`

## Changes
- `init-standards`:
  - writes the block to AGENTS.md and makes sure CLAUDE.md has `@AGENTS.md`
  - migrates old setups where the block is in CLAUDE.md, including a symlinked or stub AGENTS.md
  - when both files have a block and they differ, shows a diff and keeps AGENTS.md by default
- Block template renamed from `claude-md-block.md` to `agents-md-block.md`.
- The session-start hook, `engineering-standards`, `merge-critique` and `decision-log.md` now name AGENTS.md.
- README and `docs/setup.md`: removed the "copy the block into AGENTS.md" step and the CLAUDE.md fallback settings for each tool. Gemini CLI still needs `context.fileName`.
- This repo: its rules moved to `AGENTS.md`, and `CLAUDE.md` is now just `@AGENTS.md`.
- Fixed the `critique-reviewer.md` frontmatter, which didn't parse. Only the indentation changed.

## Key decisions
- **AGENTS.md plus an import, instead of asking which tool:** asking breaks on mixed teams and goes stale when someone switches tools, and writing both files lets the copies drift.
- **AGENTS.md wins a conflict between the two blocks:** it's the new canonical file. This is a judgment call.

## Risks
- The migration steps have been checked by reading only. `/init-standards` hasn't been run on a real repo.
- Users on 0.3.x who don't re-run init lose the removed fallback settings for Codex and Copilot.

## Testing
- [x] `bash -n plugins/ship-standards/hooks/scripts/*.sh`
- [x] `claude plugin validate .` and `claude plugin validate plugins/ship-standards`
- [x] Hooks smoke-run on this branch
- [ ] `/init-standards` on a scratch repo (new, existing, old CLAUDE.md block)
