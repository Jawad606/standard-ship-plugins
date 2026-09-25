# Decision log format

The coding agent appends to `.decisions/<branch-name>.md` (slashes replaced by dashes, e.g. `feat/leave` → `feat-leave.md`) **while coding**, whenever it
chooses between real alternatives. This is what lets merge-critique give true reasons
instead of reconstructed ones. Log only real choices — not every line.

Add this instruction to the repo's `AGENTS.md` so the coding agent does it:

> When you choose between two or more reasonable approaches (library, file placement,
> data model, algorithm, pattern), append an entry to `.decisions/<branch>.md` using the
> format in the merge-critique skill. Keep entries short. Record the real reason,
> including "first thing that worked" if that's the truth.

## Entry template

```markdown
## <short title> — <YYYY-MM-DD HH:MM>
- **Context:** <what problem you were solving at this point>
- **Options:** <A>, <B>, <C>
- **Chose:** <A>
- **Why:** <real reason>
- **Evidence:** <file:line / ticket / doc / error / measurement / none>
- **Confidence:** high | medium | low
- **Revisit if:** <condition that would make this wrong>
```

## Example

```markdown
## Leave balance calculation location — 2026-09-25 14:10
- **Context:** Need balance for approve + dashboard endpoints
- **Options:** compute in controller, new LeaveBalanceService, SQL view
- **Chose:** LeaveBalanceService
- **Why:** Two callers already; services are where domain logic lives in this repo
- **Evidence:** repo-pattern `src/modules/payroll/payroll.service.ts`
- **Confidence:** high
- **Revisit if:** dashboard needs balances for 1000+ employees at once (N+1 risk)
```
