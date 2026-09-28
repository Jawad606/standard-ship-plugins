---
name: verify
description: Run the project's quality gates (lint, typecheck, unit/integration tests, e2e, build) using the commands recorded in .ship-standards.json, and map results back to the spec's acceptance criteria. Use when the user runs /verify, before claiming any coding task is done, before running merge-critique, or when the user asks "does it all pass", "run the checks", "is this ready".
---

# Verify

Prove the change works, rather than asserting it.

## Steps

1. Read `.ship-standards.json`. If missing, detect commands from `package.json` scripts and
   suggest running `init-standards`.
2. Run gates in order, stopping at the first hard failure only if later gates depend on it:
   lint → typecheck → test → e2e (if configured and relevant to the change) → build.
   In a monorepo, prefer scoped runs for changed packages first (e.g. `pnpm --filter`,
   `turbo run test --filter=...[origin/main]`), then the full run before finishing.
3. On failure: show the relevant error lines (not the whole log), fix the cause, re-run.
   Never skip, delete, or `.only`/`.skip` tests to get green.
4. Find the active spec (branch name, or the most recent `approved` spec touching changed
   files) and build the AC coverage table: for each AC, the test(s) covering it, or **not covered**.
5. Write the proof file `.decisions/<branch-slug>-verify.json` (branch name with `/` → `-`),
   only after actually running the gates, as the last step, after your final edit:
   ```json
   {"result": "pass", "gates": {"lint": "pass", "typecheck": "pass", "test": "pass", "e2e": "skipped", "build": "pass"}, "at": "2026-09-27T10:00:00Z"}
   ```
   `result` is `pass` only if every gate that ran passed; otherwise `fail`. The Stop hook
   blocks finishing while this file is missing, failed, or older than any changed source
   file, so re-run `/verify` after any further edit. Never write `pass` without running the
   gates. CI re-runs the same commands, so a false `pass` gets caught at merge.

## Output

```
Gate        Result   Notes
lint        pass
typecheck   pass
test        pass     142 passed
e2e         skipped  no UI change
build       pass

AC coverage (specs/004-leave-approval.md)
AC-1  covered  leave.service.spec.ts > "AC-1: ..."
AC-2  NOT COVERED
```

End with a one-line verdict: **ready for merge-critique** or **not ready — <reason>**.
