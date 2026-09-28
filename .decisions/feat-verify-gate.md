## Freshness check: mtime vs content hash — 2026-09-27
- **Context:** The Stop hook must know whether /verify ran after the last edit.
- **Options:** HEAD SHA (fails for uncommitted work, which is the normal case); hash of the diff computed identically by skill and hook; file mtime (`find -newer`)
- **Chose:** mtime
- **Why:** POSIX-only, no shared script the skill would need to locate across tools, correct for the common edit→verify→edit case. The ceiling is clock skew and `touch`, which is acceptable because CI is the tamper-proof layer.
- **Evidence:** tests/stop-check.test.sh "AC-3 edit after verify"
- **Confidence:** medium
- **Revisit if:** agents are seen touching files to dodge the gate, or false blocks appear from tools that rewrite files (formatters on save)

## Proof file gitignored, not committed — 2026-09-27
- **Context:** Where `.decisions/<slug>-verify.json` lives.
- **Options:** commit it (reviewers see it); gitignore it
- **Chose:** gitignore
- **Why:** It's per-machine and goes stale on every edit, so committing it would add churn and a false signal. CI's status check is the reviewer-facing proof.
- **Evidence:** judgment call
- **Confidence:** medium
- **Revisit if:** teams without CI want the proof visible in PRs

## Skip the gate when no command is configured — 2026-09-27
- **Context:** A repo with all commands null could never produce a pass.
- **Options:** block anyway; skip silently
- **Chose:** skip
- **Why:** Otherwise the hook blocks forever in exactly the repos that can't satisfy it.
- **Evidence:** test "AC-5 no commands configured"
- **Confidence:** high
- **Revisit if:** none

## Branch protection via `gh api` only on a separate yes, with a pre-check — 2026-09-27
- **Context:** CI only enforces anything when the check is required.
- **Options:** docs only; offer `gh api` PUT
- **Chose:** offer `gh api` after checking for existing rules; manual steps otherwise
- **Why:** The PUT replaces existing protection, so blind use could wipe a team's review rules.
- **Evidence:** constraint: GitHub branch protection PUT replaces the full rule set (UNVERIFIED against current API docs)
- **Confidence:** medium
- **Revisit if:** GitHub rulesets make a safer additive API the default
