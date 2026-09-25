<!-- ship-standards:start -->
## Workflow (ship-standards)

Follow Spec → Context → Build → Test → Evaluate → Deploy for every feature or non-trivial fix.

1. **Spec first.** Don't start a feature without a spec in `specs/`. If none exists, run the
   `spec` skill and get the user to confirm it. Small fixes (<30 lines, no behaviour change)
   are exempt.
2. **Context.** Before changing unfamiliar code, read `graphify-out/GRAPH_REPORT.md` if it
   exists, and at least one existing module that does something similar. Match its patterns.
3. **Build.** Stay inside the spec's scope. No drive-by refactors — note them instead.
4. **Decision log.** When choosing between real alternatives (library, file placement, data
   model, pattern), append an entry to `.decisions/<branch>.md`, with `/` in the branch name replaced by `-` (format: merge-critique skill).
   Record the real reason, including "first thing that worked".
5. **Test.** Every acceptance criterion maps to at least one test. Run `/verify` before
   saying a task is done; never claim tests pass without running them.
6. **Evaluate.** When the task is finished, run `/merge-critique` to produce the reviewer report.

## Project commands
<!-- filled from .ship-standards.json -->
- lint: `bash -n plugins/ship-standards/hooks/scripts/*.sh`  · typecheck: none  · test: `claude plugin validate . && claude plugin validate plugins/ship-standards`  · e2e: none  · build: none

## Project conventions
<!-- filled by init-standards from the actual codebase, with file examples -->
- Structure: this repo is a Claude Code plugin marketplace. `.claude-plugin/marketplace.json` lists plugins; each plugin lives in `plugins/<name>/` with `.claude-plugin/plugin.json`, `skills/<skill>/SKILL.md` (+ `references/`), `agents/*.md`, `hooks/hooks.json` + `hooks/scripts/*.sh`.
- Business logic lives in: skill instructions (`plugins/ship-standards/skills/*/SKILL.md`); long templates go in that skill's `references/` (e.g. `skills/spec/references/spec-template.md`), not inline.
- Frontmatter: skills and agents need valid YAML frontmatter (`name`, `description`). Multi-line agent descriptions with `<example>` blocks must use a `description: |` block scalar (see `agents/critique-reviewer.md`) — `claude plugin validate` catches this.
- Hooks: plain bash, no dependencies beyond git/grep/sed/awk (no `jq`); exit 0 silently when not applicable; always respect `stop_hook_active` in Stop hooks (see `hooks/scripts/stop-check.sh`).
- Versioning: keep `version` in sync across `marketplace.json` (metadata + plugin entry) and `plugin.json`.
- Validation: no DB, no runtime code — correctness is `claude plugin validate` + `bash -n`.
<!-- ship-standards:end -->
