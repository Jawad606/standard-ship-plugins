# 002 — Enforce passing checks (verify proof + Stop gate + CI)

**Status:** done
**Owner:** Jawad · **Ticket:** none · **Branch:** feat/verify-gate

## Goal
Today nothing forces checks to pass: `/verify` is only an instruction, and the Stop hook only
checks that a decision log exists. Add a session gate (the agent can't finish with unverified
changes) and make CI plus branch protection the recommended merge gate, which can't be faked.

## User stories
- As a reviewer, I want to know the agent actually ran the checks on the code I'm merging.
- As a team lead, I want untested code blocked at merge regardless of which agent or person wrote it.

## Acceptance criteria
- **AC-1:** When `/verify` finishes, it writes `.decisions/<branch-slug>-verify.json` with `result` (`pass`|`fail`), per-gate results, and the time it ran.
- **AC-2:** Given source files changed on a feature branch and the proof file is missing, when the agent stops, then the Stop hook blocks once with a reason asking it to run `/verify`.
- **AC-3:** Given the proof file has `"result": "fail"`, or any changed source file is newer than the proof file, when the agent stops, then the hook blocks once.
- **AC-4:** Given a passing proof file newer than every changed source file (and a decision log), the hook does not block.
- **AC-5:** The hook still never blocks when `stop_hook_active` is true, on the base branch, or when no source files changed. The verify gate is skipped when `enforceVerify` is `false` or no command is configured. Decision-log and verify reasons are combined into one block.
- **AC-6:** `/init-standards` presents CI as the recommended option. If the user agrees, it also offers to require the CI check with branch protection, run only on a second yes, and explains the manual steps if `gh` can't do it. It adds `.decisions/*-verify.json` to `.gitignore`.
- **AC-7:** A runnable test covers AC-2–AC-5 and runs as part of the repo's `test` command. Version is 0.5.0 everywhere and `claude plugin validate` passes.

## Out of scope
- A behavioural smoke-check step (separate spec).
- Making the hook run the tests itself: it has a 15s timeout, and CI does that.
- Tamper-proofing the proof file. CI is the tamper-proof layer.

## Affected areas
- `plugins/ship-standards/hooks/scripts/stop-check.sh`: add the verify gate.
- `plugins/ship-standards/skills/verify/SKILL.md`: write the proof file.
- `plugins/ship-standards/skills/init-standards/SKILL.md`: CI recommended, branch protection, `.gitignore`, `enforceVerify` key.
- `plugins/ship-standards/skills/merge-critique/SKILL.md`: the Testing section cites the proof file.
- `plugins/ship-standards/README.md`, `docs/setup.md`: config key and troubleshooting.
- `tests/stop-check.test.sh` (new), `.ship-standards.json` (test command).

## Data model changes
New local file `.decisions/<slug>-verify.json` (gitignored):
`{"result":"pass","gates":{"lint":"pass","test":"pass","e2e":"skipped"},"at":"2026-09-27T10:00:00Z"}`.
New config key `enforceVerify` (default true).

## API contract
none

## Edge cases & failure modes
- A deleted source file counts as a change but has no mtime → skip it in the freshness check.
- Proof file written, then more edits → stale (AC-3).
- A repo with no configured commands → the gate is skipped (AC-5), so it can never block forever.
- Tools without `stop_hook_active` (Antigravity) → could loop; the docs already say to keep the hook off there.

## Test plan
| AC | Test type | Location |
|---|---|---|
| AC-1 | manual: run `/verify` in this repo, file appears | this repo |
| AC-2–AC-5 | shell test in temp git repo | `tests/stop-check.test.sh` |
| AC-6 | manual read of the skill | `skills/init-standards/SKILL.md` |
| AC-7 | `/verify` | `.ship-standards.json` commands |

## Open questions
- none
