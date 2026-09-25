# Ship-Standards

Plugin marketplace by [Muhammad Jawad Hassan](https://jawadhassan.dev). The plugins work in
Claude Code, and their skills also work in Cursor, GitHub Copilot, Codex, Antigravity, Gemini CLI,
OpenCode, Windsurf and Cline.

| Plugin | Description |
|---|---|
| [ship-standards](plugins/ship-standards) | Spec → Context → Build → Test → Evaluate → Deploy workflow for agentic coding, for new and existing repos |

## Setup

### Claude Code (full plugin: skills, agent, hooks)

```
/plugin marketplace add Jawad606/standard-ship-plugins
/plugin install ship-standards@jawad-plugins
```

To update: `claude plugin marketplace update jawad-plugins`, then
`claude plugin update ship-standards@jawad-plugins`, then restart Claude Code.

### Any other tool (skills)

```bash
npx skills add Jawad606/standard-ship-plugins            # this project
npx skills add Jawad606/standard-ship-plugins -g         # all projects
npx skills add Jawad606/standard-ship-plugins -a cursor  # one tool only
```

Or copy `plugins/ship-standards/skills/*` into your tool's skills folder, keeping each skill's
`references/` folder with it:

| Tool | Project skills folder | Invoke | Agent | Hooks |
|---|---|---|---|---|
| Cursor | `.cursor/skills/` or `.agents/skills/` | `/spec` | ✓ | ✓ |
| GitHub Copilot (VS Code) | `.github/skills/` or `.agents/skills/` | `/spec` | ✓ | ✓ |
| Codex CLI | `.agents/skills/` | `$spec` | TOML | ✓ |
| Gemini CLI | `.gemini/skills/` or `.agents/skills/` | auto | ✓ | ✓ |
| Antigravity | `.agents/skills/` | `/spec` | edit | Stop only |
| OpenCode | `.opencode/skills/` or `.agents/skills/` | by name | edit | ✗ |
| Windsurf / Devin Desktop | `.devin/skills/` or `.agents/skills/` | `@spec` | ✗ | ✗ |
| Cline | `.cline/skills/` | `/spec` | ✗ | ✗ |

Only the skills are required. The agent and hooks are optional, and the workflow still runs
without them. In the Agent column, "TOML" and "edit" mean the agent file needs converting or
small frontmatter changes first.

Copilot can also install the Claude plugin directly: add `"chat.plugins.marketplaces": ["Jawad606/standard-ship-plugins"]` to VS Code settings.

**Full setup for every tool** (agent files, hook config, instruction files, troubleshooting) is in the **[setup guide](docs/setup.md)**.

### Then, in any repo

```
/init-standards          # once per repo
/spec <feature>          # before building
/verify                  # before calling it done
/merge-critique          # reviewer report (add `pr` to open the PR)
```

If your tool reads `AGENTS.md` but not `CLAUDE.md` (Cursor, Antigravity, Windsurf, Cline),
copy the `ship-standards` block from `CLAUDE.md` into `AGENTS.md` after running `/init-standards`.
