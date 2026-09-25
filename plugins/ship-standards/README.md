# ship-standards

A Claude Code plugin that makes coding agents follow one workflow in every repo:

**Spec → Context → Build → Test → Evaluate → Deploy**

It works in **existing** codebases (it reads and respects their conventions) and **new** ones (it scaffolds sensible defaults).

## Components

| Type | Name | What it does |
|---|---|---|
| Skill | `init-standards` | Detects new vs existing repo, discovers commands and conventions, writes `.ship-standards.json`, a marked block in `CLAUDE.md`, `specs/`, `.decisions/`. CI, deps and Graphify only with your yes. |
| Skill | `spec` | Writes `specs/NNN-feature.md` with testable acceptance criteria (`AC-1`…). |
| Skill | `engineering-standards` | Default build, testing, security and AI-feature rules. Repo conventions override them. |
| Skill | `verify` | Runs lint → typecheck → test → e2e → build from the config and maps tests to ACs. |
| Skill | `merge-critique` | Evidence-backed report for whoever merges: why each file and decision, risks, what's untested. |
| Agent | `critique-reviewer` | Fresh-context, read-only reviewer used by merge-critique. |
| Hook | SessionStart | Loads branch, decision-log path and active specs; nudges `/init-standards` in uninitialised repos. |
| Hook | Stop | If source changed on a feature branch with no decision log, asks Claude once to record decisions and verify. |

## Install

```
/plugin marketplace add Jawad606/standard-ship-plugins
/plugin install ship-standards@jawad-plugins
```

Then, in any repo:

```
/init-standards          # once per repo
/spec <feature>          # before building
... build ...
/verify                  # before calling it done
/merge-critique          # before merge / as PR description
```

## Configuration — `.ship-standards.json`

```json
{
  "baseBranch": "main",
  "commands": { "lint": "pnpm lint", "typecheck": "pnpm typecheck", "test": "pnpm test", "e2e": "pnpm e2e", "build": "pnpm build" },
  "specsDir": "specs",
  "decisionsDir": ".decisions",
  "enforceDecisionLog": true
}
```

Set `enforceDecisionLog` to `false` to turn off the Stop-hook reminder in a repo.

## Team auto-install

Commit this to a project's `.claude/settings.json` so teammates get the marketplace when they trust the folder:

```json
{ "extraKnownMarketplaces": { "jawad-plugins": { "source": { "source": "github", "repo": "Jawad606/standard-ship-plugins" } } } }
```

## Requirements

`git` and `bash` (the hooks use only POSIX tools, with no jq or node needed). Graphify is optional: `uv tool install graphifyy`.
