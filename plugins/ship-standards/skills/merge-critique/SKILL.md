---
name: merge-critique
description: Explain and critique a finished code change for the person who will review or merge it. Answers "why this approach?", "why does this file exist?", "why not X?", and flags weak spots honestly, with every claim backed by evidence from the repo, ticket, tests, or decision log. Use this whenever a coding task is finished and the user asks for a review summary, PR description, merge notes, change rationale, "explain your changes", "why did you do it this way", or runs /critique — even if they don't say "critique". Also use when a reviewer asks follow-up questions about a diff.
---

# Merge Critique

The reader of your output is about to merge code they didn't write. They need to know
what changed, why each decision was made, and where they should be suspicious. Your job
is to be the honest engineer who walks them through the PR — not a salesperson defending it.

## The core rule: no evidence, no claim

The biggest failure mode of this skill is inventing plausible reasons after the fact.
A confident but made-up justification is worse than none, because the reviewer will
trust it. So every "why" you give must point to one of these:

| Evidence type | Example |
|---|---|
| `repo-pattern` | "Matches existing pattern in `src/services/invoice.service.ts:42`" |
| `requirement` | "Ticket says exports must support >10k rows" |
| `decision-log` | "Logged during coding: rejected Redis cache, no infra for it yet" |
| `test` | "Covered by `leave.spec.ts > rejects overlapping dates`" |
| `constraint` | "Prisma doesn't support X, see docs link / error seen" |
| `measurement` | "Query went 1.8s → 120ms on seed data" |

If none apply, say so explicitly and label it **judgment call** or **no strong reason**.
That honesty is the most valuable thing in the report. Never upgrade a judgment call into
a principled decision.

## Step 1 — Gather inputs

Collect these before writing anything. Note in the report which ones were missing.

1. **The diff**: `git diff --stat <base>...HEAD`, then `git diff <base>...HEAD`.
   Base branch comes from `.ship-standards.json` (`baseBranch`), default `main`.
2. **The task**: the active spec in `specs/` (match by branch or changed files), plus any
   ticket or the original user request. Acceptance-criteria IDs (`AC-n`) anchor the report.
3. **Decision log**: `.decisions/<branch-name>.md` if it exists (format in
   `references/decision-log.md`). This is the primary source of *why*.
4. **Repo conventions**: `CLAUDE.md`, `CONTRIBUTING.md`, lint/format config, and 1–2
   existing modules similar to what was added (to check consistency).
5. **Tests**: which test files were added/changed, and whether they were run
   (check the session or run them if cheap).

If there is no decision log, you can still write the report, but reasons not grounded in
the repo, ticket, or tests must be marked **reconstructed — not recorded at the time**.

## Step 2 — Analyse like a skeptical reviewer

If the `critique-reviewer` agent is available, delegate this step to it. It reviews with
fresh context instead of the author's bias; build the report from its notes. Otherwise
do the analysis yourself using the questions below.

Run the `verify` skill first (or use its latest result in this session), so the Testing
section reports what was actually run, not what should pass.

Before writing, go through the diff file by file and ask:

- Why does this file exist? Could its job live in an existing file?
- Does it have one clear responsibility, or is it doing two things?
- Does it follow the repo's existing patterns? If it deviates, is there a reason?
- What alternatives were realistic, and why were they not chosen?
- What assumptions does this code make (data shape, env vars, ordering, auth, timezones)?
- What's untested? What would break first in production?
- Is anything in the diff unrelated to the task (scope creep, drive-by refactors)?

If you are the same agent that wrote the code, actively argue against your own choices
here. If a choice doesn't survive the argument, say so in the report rather than hiding it.

## Step 3 — Write the report

Save to `.decisions/<branch-name>-critique.md` (or print it if asked) using this template.
Keep it scannable; reviewers skim.

```markdown
# Merge Critique: <branch or PR title>

**Task:** <one line — what was asked>
**Base:** <base branch> · **Files changed:** <n> · **Inputs missing:** <e.g. no decision log / none>

## Summary
<3–5 sentences: what changed, the main approach, and the single most important thing
the reviewer should check.>

## Files
| File | Status | Responsibility | Why it exists / changed |
|---|---|---|---|
| `path/to/file.ts` | added | <one responsibility> | <reason> — *evidence: repo-pattern `x.ts:12`* |

## Key decisions
### 1. <Decision in a few words>
- **Chose:** <what>
- **Rejected:** <alternatives>
- **Tradeoff:** <what we gain / what we pay>
- **Evidence:** <type + pointer> | **judgment call**

<repeat for each non-trivial decision; skip trivial ones>

## Risks and weak spots
- <honest item — shortcut, assumption, perf concern, migration risk>

## Spec coverage
| AC | Implemented | Test |
|---|---|---|
| AC-1 | yes | `path/to/test > name` |

## Testing
- **Tested:** <what, and whether tests were actually run>
- **Not tested:** <what, and why>

## Speculative code (YAGNI)
- <abstraction / option / export not needed by the spec, with file:line and caller count, or "none">

## Out of scope / unrelated changes
- <anything in the diff not required by the task, or "none">

## Questions the reviewer should ask
1. <sharp question that a careful reviewer would raise>
2. ...
```

## Step 4 — PR body

When the user asks to open a PR, or runs `/merge-critique pr`:

1. Fill `.github/pull_request_template.md` from the report (keep the template's headings
   in order; the report has more detail than the PR needs, so condense). If the repo has no
   template, use the report's Summary, Key decisions, Risks, and Testing sections.
2. Save it as `.decisions/<branch-slug>-pr.md`.
3. Show the user the title and body, then ask before pushing or creating anything. On a yes:
   `git push -u origin <branch>` if the branch isn't pushed yet, then
   `gh pr create --base <baseBranch> --title "<title>" --body-file .decisions/<branch-slug>-pr.md`.
4. If a PR already exists for the branch (`gh pr view`), offer
   `gh pr edit --body-file ...` instead of creating a new one.
5. If `gh` isn't installed or authenticated, say so and tell the user to paste the file's
   contents into the PR on GitHub.

## Step 5 — Q&A mode

After the report, the reviewer may ask follow-ups ("why not put this in the controller?",
"is this safe under concurrent requests?"). Answer each one with the same evidence rule:

1. Answer directly in 1–3 sentences.
2. Cite the evidence (file:line, log entry, test, ticket).
3. If the honest answer is "that would have been better", say so and suggest the fix —
   don't defend the existing code by reflex.

## Tone

Direct, specific, no filler. Prefer "`LeaveService.approve` doesn't check the approver
is the manager — relies on the route guard" over "authorization is handled appropriately".
