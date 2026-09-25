## Where the workflow rules live — 2026-09-25
- **Context:** Only Claude Code read the block that /init-standards wrote to CLAUDE.md; users of other tools had to copy it by hand.
- **Options:** ask which tool and write that tool's file; write the block to both files; AGENTS.md as the only copy + `@AGENTS.md` import in CLAUDE.md
- **Chose:** AGENTS.md + `@AGENTS.md` import
- **Why:** Mixed teams and tool switches break the "ask" option; writing both files lets the copies drift. User agreed in chat.
- **Evidence:** vendor docs in docs/setup.md (Cursor, Copilot, Codex, Antigravity, OpenCode, Windsurf and Cline read AGENTS.md; Gemini CLI via context.fileName)
- **Confidence:** medium. `@path` import is documented Claude Code memory syntax; not run end to end in this branch.
- **Revisit if:** every supported Claude Code version reads AGENTS.md natively. Per the critique-reviewer, current docs say newer versions do when no CLAUDE.md exists (UNVERIFIED by me); the import is still needed for older versions and repos that already have a CLAUDE.md.

## Rename claude-md-block.md → agents-md-block.md — 2026-09-25
- **Context:** Template no longer targets CLAUDE.md.
- **Options:** keep the old name, rename
- **Chose:** rename
- **Why:** The old name would point readers at the wrong file; only init-standards references it.
- **Evidence:** `grep -rn claude-md-block` → only skills/init-standards/SKILL.md
- **Confidence:** high
- **Revisit if:** none

## Migration edge cases from review — 2026-09-25
- **Context:** critique-reviewer flagged that the old docs recommended symlinking AGENTS.md → CLAUDE.md, and that differing blocks in both files had no rule.
- **Options:** ignore (rare); handle in the skill text
- **Chose:** handle in init-standards step 4.3: remove a symlink/stub first; on conflicting blocks show a diff and keep AGENTS.md by default
- **Why:** Following the old symlink advice would otherwise make CLAUDE.md import itself and lose the block. AGENTS.md wins because it's the new canonical file.
- **Evidence:** old docs/setup.md "After install" step 2 (removed in this branch)
- **Confidence:** medium, not run against a real repo
- **Revisit if:** users report migration problems
