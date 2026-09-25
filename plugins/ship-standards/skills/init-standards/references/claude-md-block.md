<!-- ship-standards:start -->
## Workflow (ship-standards)

Follow Spec → Context → Build → Test → Evaluate → Deploy for every feature or non-trivial fix.

1. **Spec first.** Don't start a feature without a spec in `specs/`. If none exists, run the
   `spec` skill and get the user to confirm it. Small fixes (<30 lines, no behaviour change)
   are exempt.
2. **Context.** Before changing unfamiliar code, read `graphify-out/GRAPH_REPORT.md` if it
   exists, and at least one existing module that does something similar. Match its patterns.
3. **Build.** Stay inside the spec's scope. No drive-by refactors; note them instead.
   **YAGNI:** build only what the current spec needs. No abstraction until there are two
   real callers, no config option or parameter nobody asked for, no "future-proofing" layers.
   If something seems likely to be needed later, note it in the decision log instead of
   building it. YAGNI never removes validation, authZ, error handling, or tests; those are
   needed now. Existing repo patterns still apply.
4. **Decision log.** When choosing between real alternatives (library, file placement, data
   model, pattern), append an entry to `.decisions/<branch>.md`, with `/` in the branch name replaced by `-` (format: merge-critique skill).
   Record the real reason, including "first thing that worked".
5. **Test.** Every acceptance criterion maps to at least one test. Run `/verify` before
   saying a task is done; never claim tests pass without running them.
6. **Evaluate.** When the task is finished, run `/merge-critique` to produce the reviewer report.

## Project commands
<!-- filled from .ship-standards.json -->
- lint: `…`  · typecheck: `…`  · test: `…`  · e2e: `…`  · build: `…`

## Project conventions
<!-- filled by init-standards from the actual codebase, with file examples -->
- Structure: …
- Business logic lives in: … (e.g. `src/modules/*/*.service.ts`)
- Validation: …
- DB access: …
- Error handling: …
<!-- ship-standards:end -->
