#!/usr/bin/env bash
# Before Claude finishes: if source code changed on this branch but no decision log exists,
# ask Claude (once) to record decisions and run /verify. Never loops: respects stop_hook_active.
input=$(cat)
printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
[ -f .ship-standards.json ] || exit 0
grep -Eq '"enforceDecisionLog"[[:space:]]*:[[:space:]]*false' .ship-standards.json && exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

base=$(grep -Eo '"baseBranch"[[:space:]]*:[[:space:]]*"[^"]+"' .ship-standards.json | sed -E 's/.*"([^"]+)"$/\1/')
base=${base:-main}
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
[ "$branch" = "$base" ] && exit 0   # don't nag on the base branch itself
slug=$(printf '%s' "$branch" | tr '/' '-')

# Source files changed: committed on branch + uncommitted, excluding docs/specs/decisions
changed=$( { git diff --name-only "$base"...HEAD 2>/dev/null; git status --porcelain -uall | awk '{print $NF}'; } \
  | sort -u | grep -Ev '^(\.decisions/|specs/|graphify-out/)|\.md$' | grep -E '\.(ts|tsx|js|jsx|py|sql|prisma)$')
[ -z "$changed" ] && exit 0
[ -s ".decisions/$slug.md" ] && exit 0

count=$(printf '%s\n' "$changed" | wc -l | tr -d ' ')
cat << JSON
{"decision":"block","reason":"ship-standards: $count source file(s) changed on '$branch' but .decisions/$slug.md does not exist. If this task involved real choices between alternatives, append decision-log entries (format in the merge-critique skill), and run /verify if you haven't this session. If there were no real decisions, create the file with a one-line note saying so. Then finish."}
JSON
exit 0
