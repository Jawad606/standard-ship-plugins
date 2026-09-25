## Where the workflow rules live — 2026-09-25
- **Context:** Only Claude Code read the block that /init-standards wrote to CLAUDE.md; users of other tools had to copy it by hand.
- **Options:** ask which tool and write that tool's file; write the block to both files; AGENTS.md as the only copy + `@AGENTS.md` import in CLAUDE.md
- **Chose:** AGENTS.md + `@AGENTS.md` import
- **Why:** Mixed teams and tool switches break the "ask" option; writing both files lets the copies drift. User agreed in chat.
- **Evidence:** vendor docs in docs/setup.md (Cursor, Copilot, Codex, Antigravity, OpenCode, Windsurf and Cline read AGENTS.md; Gemini CLI via context.fileName)
- **Confidence:** medium. `@AGENTS.md` import is standard Claude Code memory syntax but untested in this branch.
- **Revisit if:** Claude Code starts reading AGENTS.md natively (then drop the CLAUDE.md stub).

## Rename claude-md-block.md → agents-md-block.md — 2026-09-25
- **Context:** Template no longer targets CLAUDE.md.
- **Options:** keep the old name, rename
- **Chose:** rename
- **Why:** The old name would point readers at the wrong file; only init-standards references it.
- **Evidence:** `grep -rn claude-md-block` → only skills/init-standards/SKILL.md
- **Confidence:** high
- **Revisit if:** none
