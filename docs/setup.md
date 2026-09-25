# Setup guide

ship-standards is built as a Claude Code plugin, but its core is plain [Agent Skills](https://agentskills.io)
(`skills/*/SKILL.md`), which most coding agents now read. This guide covers every supported tool.

| Part | What it is | Portable? |
|---|---|---|
| Skills | `init-standards`, `spec`, `engineering-standards`, `verify`, `merge-critique` | Yes: every tool below |
| Agent | `critique-reviewer` (read-only reviewer) | Some tools; `merge-critique` works without it |
| Hooks | SessionStart (context) + Stop (decision-log reminder) | Varies; optional |
| Instructions | Workflow block `/init-standards` writes to `CLAUDE.md` | Every tool, via `AGENTS.md` if needed |

**Only the skills are required.** The hooks and the agent are optional extras: the workflow
still runs without them.

## Contents

- [Quick start (any tool)](#quick-start-any-tool)
- [Claude Code](#claude-code)
- [Cursor](#cursor)
- [GitHub Copilot in VS Code](#github-copilot-in-vs-code)
- [OpenAI Codex CLI](#openai-codex-cli)
- [Google Antigravity](#google-antigravity)
- [Gemini CLI](#gemini-cli)
- [OpenCode](#opencode)
- [Windsurf / Devin Desktop](#windsurf--devin-desktop)
- [Cline](#cline)
- [After install: every tool](#after-install-every-tool)
- [Troubleshooting](#troubleshooting)

---

## Quick start (any tool)

The [`skills` CLI](https://github.com/vercel-labs/skills) installs the skills into most agents in one step:

```bash
npx skills add Jawad606/standard-ship-plugins            # project scope, prompts for agents
npx skills add Jawad606/standard-ship-plugins -g         # user scope (all projects)
npx skills add Jawad606/standard-ship-plugins -a cursor  # one agent only
npx skills add Jawad606/standard-ship-plugins -l         # list skills without installing
```

This installs **skills only**. It does not install the agent or the hooks. For those, use
the per-tool sections below.

### Manual install

Clone once and copy (or symlink) the skill folders into the directory your tool reads:

```bash
git clone https://github.com/Jawad606/standard-ship-plugins ~/.ship-standards
cp -r ~/.ship-standards/plugins/ship-standards/skills/* <skills-dir>/
```

Keep each skill's `references/` folder next to its `SKILL.md`, because the skills load their
templates from there. To update later, run `git -C ~/.ship-standards pull` and copy again. If
you symlinked, the pull is all you need.

`.agents/skills/` is the shared project path. Cursor, Copilot, Codex, Antigravity, Gemini CLI,
OpenCode and Windsurf all read it (Cline is the exception), so one copy there covers a mixed
team.

---

## Claude Code

Claude Code gets everything, installed natively: skills, agent and hooks.

```
/plugin marketplace add Jawad606/standard-ship-plugins
/plugin install ship-standards@jawad-plugins
```

Or from a shell:

```bash
claude plugin marketplace add Jawad606/standard-ship-plugins
claude plugin install ship-standards@jawad-plugins
```

To update:

```bash
claude plugin marketplace update jawad-plugins    # refresh the catalog
claude plugin update ship-standards@jawad-plugins # update the installed copy
```

Restart Claude Code after installing or updating. Refreshing the marketplace alone does
**not** update an installed plugin.

**Team auto-install:** commit this to the project's `.claude/settings.json`. Teammates are
then offered the marketplace when they trust the folder:

```json
{
  "extraKnownMarketplaces": {
    "jawad-plugins": { "source": { "source": "github", "repo": "Jawad606/standard-ship-plugins" } }
  },
  "enabledPlugins": { "ship-standards@jawad-plugins": true }
}
```

**Windows:** the hooks run with `bash`, so install [Git for Windows](https://git-scm.com/download/win)
and make sure `bash` is on your PATH.

---

## Cursor

Cursor supports skills, the agent (loaded from `.claude/agents/`) and the hooks, which it
imports from Claude settings.

**Skills:** `npx skills add Jawad606/standard-ship-plugins -a cursor`. Manually, copy them to
`.cursor/skills/` or `.agents/skills/` in the project, or to `~/.cursor/skills/` for all
projects. Cursor also reads `.claude/skills/` and `~/.claude/skills/`, so it picks up an
existing Claude setup. Invoke a skill with `/spec`, `/verify` and so on, or let Cursor
choose one automatically.
[Docs](https://cursor.com/docs/context/skills)

**Agent:** copy `plugins/ship-standards/agents/critique-reviewer.md` to `.cursor/agents/` or
`.claude/agents/`. Cursor ignores the `tools:` field, so if you want to enforce read-only,
add `readonly: true` to the frontmatter.
[Docs](https://cursor.com/docs/subagents)

**Instructions:** Cursor reads `AGENTS.md` and `.cursor/rules/*.mdc`, but not `CLAUDE.md`.
See [After install](#after-install-every-tool).
[Docs](https://cursor.com/docs/context/rules)

**Hooks:** Cursor imports Claude hooks from `.claude/settings.json` when
*Settings → Agents → Third-Party Imports* is on (the default). It also translates a Stop
`"block"` into a follow-up message. Add this to the project's `.claude/settings.json`,
using the clone from [Manual install](#manual-install):

```json
{
  "hooks": {
    "SessionStart": [{ "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.ship-standards/plugins/ship-standards/hooks/scripts/session-start.sh" }] }],
    "Stop":         [{ "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.ship-standards/plugins/ship-standards/hooks/scripts/stop-check.sh" }] }]
  }
}
```

Cursor does not document `stop_hook_active`. If the Stop reminder repeats, cap it with a
native `.cursor/hooks.json` entry that sets `"loop_limit": 1`.
[Hooks](https://cursor.com/docs/agent/hooks) · [Third-party hooks](https://cursor.com/docs/reference/third-party-hooks)

---

## GitHub Copilot in VS Code

Copilot supports skills, the agent and the hooks (hooks are in Preview). It can also install
the Claude plugin directly.

**Easiest: install the plugin.** VS Code understands the Claude plugin format and expands
`${CLAUDE_PLUGIN_ROOT}` in hook commands. Add this to `settings.json`:

```json
{
  "chat.plugins.enabled": true,
  "chat.plugins.marketplaces": ["Jawad606/standard-ship-plugins"]
}
```

Then install `ship-standards` from the plugins view, or run *Command Palette → install plugin
from Git repo*.
[Docs](https://code.visualstudio.com/docs/agent-customization/agent-plugins)

**Manual setup:**
- **Skills:** copy them to `.github/skills/`, `.agents/skills/` or `.claude/skills/`, or to
  `~/.copilot/skills/` for all projects. Invoke with `/spec` or let Copilot pick one.
  [Docs](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- **Agent:** copy it to `.github/agents/` or `.claude/agents/`. Copilot's tool names differ
  from Claude's, so delete the `tools:` line if the agent fails to load.
  [Docs](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
- **Instructions:** Copilot reads `AGENTS.md` and `.github/copilot-instructions.md`. To have it
  read `CLAUDE.md`, enable `chat.useClaudeMdFile`.
- **Hooks:** enable `chat.useClaudeHooks` and use the same `.claude/settings.json` block shown
  in the [Cursor](#cursor) section.
  [Docs](https://code.visualstudio.com/docs/copilot/customization/hooks)

---

## OpenAI Codex CLI

Codex supports skills and the hooks. The agent has to be converted to TOML.

**Skills:** `npx skills add Jawad606/standard-ship-plugins -a codex`. Manually, copy them to
`.agents/skills/` in the repo or to `~/.agents/skills/`. Invoke with `$spec`, `$verify` and so
on, through `/skills`, or let Codex pick one automatically.
[Docs](https://learn.chatgpt.com/docs/build-skills)

**Instructions:** Codex reads `AGENTS.md`. To make it read `CLAUDE.md` as well, add this to
`~/.codex/config.toml`:

```toml
project_doc_fallback_filenames = ["CLAUDE.md"]
```

[Docs](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

**Agent:** Codex subagents are TOML files. Create `.codex/agents/critique-reviewer.toml` and
paste the body of `critique-reviewer.md` (the text after the frontmatter) into
`developer_instructions`:

```toml
name = "critique-reviewer"
description = "Fresh-context skeptical reviewer that challenges a finished change before merge."
sandbox_mode = "read-only"
developer_instructions = """
<paste the body of agents/critique-reviewer.md here>
"""
```

[Docs](https://learn.chatgpt.com/docs/agent-configuration/subagents)

**Hooks:** Codex uses the same event names and the same Stop `{"decision":"block"}` JSON as
Claude, so both scripts work unchanged. Add them to `.codex/hooks.json` in the repo, or to
`~/.codex/hooks.json`:

```json
{
  "hooks": {
    "SessionStart": [{ "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.ship-standards/plugins/ship-standards/hooks/scripts/session-start.sh" }] }],
    "Stop":         [{ "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.ship-standards/plugins/ship-standards/hooks/scripts/stop-check.sh" }] }]
  }
}
```

[Docs](https://learn.chatgpt.com/docs/hooks)

**Plugins:** `codex plugin marketplace add Jawad606/standard-ship-plugins` should also work,
because Codex reads `.claude-plugin/marketplace.json` as a legacy format. This hasn't been
tested with this repo, so use the manual steps if it fails.

---

## Google Antigravity

Antigravity supports skills. The agent needs small edits, and only the Stop hook ports
(Antigravity has no SessionStart event).

**Skills:** `npx skills add Jawad606/standard-ship-plugins -a antigravity`. Manually, copy them
to `.agents/skills/` in the workspace, or globally to `~/.gemini/config/skills/`
(Antigravity 2.0/IDE) or `~/.gemini/antigravity-cli/skills/` (the `agy` CLI). Invoke with
`/spec` or let Antigravity pick one.
[Docs](https://antigravity.google/docs/skills)

**Instructions:** Antigravity reads `AGENTS.md`, `GEMINI.md` and `.agents/rules/*.md`, but not
`CLAUDE.md`.
[Docs](https://antigravity.google/docs/rules)

**Agent:** copy it to `.agents/agents/critique-reviewer.md`, then edit the frontmatter:
- add `subagent: true`
- delete the `tools:` line, or replace it with Antigravity tool names such as `view_file` and `run_command`
- keep `model: inherit`

[Docs](https://antigravity.google/docs/subagents)

**Hooks:** there's no SessionStart event, so skip that hook. The Stop script also doesn't work
as-is: Antigravity continues the loop on `"decision":"continue"`, where Claude uses `"block"`.
Copy `stop-check.sh`, change `"block"` to `"continue"` in the copy, and register the copy in
`.agents/hooks.json`:

```json
{
  "ship-standards": {
    "enabled": true,
    "Stop": [{ "matcher": "", "hooks": [{ "type": "command", "command": "bash ./.agents/stop-check.sh", "timeout": 15 }] }]
  }
}
```

Antigravity doesn't send `stop_hook_active`, so the script's once-only guard won't fire. Keep
this hook off unless you need it.
[Docs](https://antigravity.google/docs/hooks)

> For unpaid tiers, Gemini CLI was replaced by Antigravity CLI (`agy`) on 2026-06-18. The same
> steps apply to `agy`.

---

## Gemini CLI

Gemini CLI supports skills, the agent and both hooks.

**Skills:**

```bash
gemini skills install https://github.com/Jawad606/standard-ship-plugins.git --consent
```

Or copy them to `.agents/skills/` or `.gemini/skills/`, or to `~/.gemini/skills/` for all
projects. Gemini activates skills automatically and asks for consent first; manage them with
`/skills list`.
[Docs](https://geminicli.com/docs/cli/skills/)

**Instructions:** Gemini reads `GEMINI.md` by default. To add the other files, set this in
`.gemini/settings.json`:

```json
{ "context": { "fileName": ["AGENTS.md", "CLAUDE.md", "GEMINI.md"] } }
```

[Docs](https://geminicli.com/docs/cli/gemini-md/)

**Agent:** copy it to `.gemini/agents/critique-reviewer.md` and delete the `tools:` line (Gemini
uses its own tool names). Invoke it with `@critique-reviewer`.
[Docs](https://geminicli.com/docs/core/subagents/)

**Hooks:** Gemini's Stop event is called `AfterAgent`. It sends `stop_hook_active` and accepts
`"block"`, so the scripts work unchanged. Add this to `.gemini/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [{ "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.ship-standards/plugins/ship-standards/hooks/scripts/session-start.sh" }] }],
    "AfterAgent":   [{ "matcher": "", "hooks": [{ "type": "command", "command": "bash ~/.ship-standards/plugins/ship-standards/hooks/scripts/stop-check.sh" }] }]
  }
}
```

Gemini expects stdout from a hook to be JSON only. `session-start.sh` prints plain text, so if
Gemini rejects it, drop the SessionStart hook. The workflow block in the instructions file
covers the same ground.
[Docs](https://geminicli.com/docs/hooks/reference/)

---

## OpenCode

OpenCode supports skills and the agent (after conversion). The hooks can't run as bash.

**Skills:** `npx skills add Jawad606/standard-ship-plugins -a opencode`. Manually, copy them to
`.opencode/skills/` or `.agents/skills/`, or to `~/.config/opencode/skills/`. OpenCode also
reads `.claude/skills/`. The model loads skills through its `skill` tool, so ask for one by
name ("use the spec skill for …"). If you want `/spec` as a slash command, add a matching file
under `.opencode/commands/`.
[Docs](https://opencode.ai/docs/skills)

**Instructions:** OpenCode reads `AGENTS.md` and falls back to `CLAUDE.md`, so nothing extra is
needed.
[Docs](https://opencode.ai/docs/rules)

**Agent:** copy it to `.opencode/agents/critique-reviewer.md` and edit the frontmatter:
- add `mode: subagent`
- replace the `tools:` line with a `permission` block that denies edits

Invoke it with `@critique-reviewer`.
[Docs](https://opencode.ai/docs/agents)

**Hooks:** OpenCode has no shell-hook config, only JS/TS plugins. Skip the hooks; the workflow
block in `AGENTS.md`/`CLAUDE.md` still tells the agent to log decisions and run `/verify`.
[Docs](https://opencode.ai/docs/plugins)

---

## Windsurf / Devin Desktop

Windsurf, now Devin Desktop (Cascade), supports skills only. It has no custom subagents, and
neither hook ports.

**Skills:** `npx skills add Jawad606/standard-ship-plugins -a windsurf`. Manually, copy them to
`.devin/skills/` (legacy `.windsurf/skills/`) or `.agents/skills/`, or globally to
`~/.codeium/windsurf/skills/`. Cascade also reads `.claude/skills/` when reading Claude Code
config is enabled. Invoke a skill with `@spec` (Cascade doesn't use slash for skills) or let it
choose.
[Docs](https://docs.devin.ai/desktop/cascade/skills)

**Instructions:** Cascade reads `AGENTS.md` and `.devin/rules/*.md`.
[Docs](https://docs.devin.ai/desktop/cascade/agents-md)

**Agent and hooks:** not supported. `merge-critique` runs its review inline when the agent is
missing. Cascade hooks have no session-start event and can't block at stop.

---

## Cline

Cline supports skills only. Custom agents and bash hooks aren't supported.

**Skills:** copy them to `.cline/skills/` or `.claude/skills/` in the project, or to
`~/.cline/skills/` for all projects. Cline's docs don't list `.agents/skills/`, so pass `-a cline` if
you use `npx skills`. Invoke with `/spec` or let Cline choose. You can toggle skills in the
Skills panel.
[Docs](https://docs.cline.bot/customization/skills.md)

**Instructions:** Cline reads `AGENTS.md` and `.clinerules/`.
[Docs](https://docs.cline.bot/customization/cline-rules.md)

**Agent and hooks:** not supported in the VS Code extension. `merge-critique` falls back to an
inline review.

---

## After install: every tool

1. **Initialise each repo once:** run `/init-standards` (or ask for "the init-standards
   skill"). It writes `.ship-standards.json`, a workflow block in `CLAUDE.md`, `specs/` and
   `.decisions/`.
2. **Tools that don't read `CLAUDE.md`** (Cursor, Antigravity, Windsurf, Cline, and Codex
   without the fallback setting) need the workflow block in `AGENTS.md`. Either:
   - ask the agent to "copy the `ship-standards` block from CLAUDE.md into AGENTS.md", or
   - symlink the file: `ln -s CLAUDE.md AGENTS.md`. On Windows, run
     `mklink AGENTS.md CLAUDE.md` in cmd with Developer Mode on.
3. **Check the commands work:** run `/verify`.
4. **Daily loop:** `/spec <feature>` → build → `/verify` → `/merge-critique` (add `pr` to open
   the PR).

## Troubleshooting

| Symptom | Fix |
|---|---|
| Skill not listed | Check the folder is `<skills-dir>/<name>/SKILL.md` (not nested one level deeper), then restart the tool. |
| Skill loads but can't find its template | Its `references/` folder wasn't copied. Copy the whole skill folder. |
| Claude Code still shows the old version | Run `claude plugin update ship-standards@jawad-plugins`, then restart. `marketplace update` alone isn't enough. |
| Hooks do nothing on Windows | `bash` isn't on your PATH. Install Git for Windows. |
| Stop reminder keeps repeating | Your tool doesn't send `stop_hook_active`. Use its loop limit (Cursor `loop_limit`), or set `"enforceDecisionLog": false` in `.ship-standards.json`. |
| Agent file fails to load | Delete the `tools:` line; tool names differ between vendors. |
| Workflow rules ignored | Your tool doesn't read `CLAUDE.md`. See [step 2](#after-install-every-tool). |

---

*Paths checked against vendor docs on 2026-09-25. Agent tools change often, so if a path above
stops working, the linked doc for that tool is the source of truth.*
