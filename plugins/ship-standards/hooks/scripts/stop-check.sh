#!/usr/bin/env bash
# Before Claude finishes: if source code changed on this branch, require (once) a decision log
# and a passing /verify proof newer than every changed file. Never loops: respects stop_hook_active.
input=$(cat)
printf '%s' "$input" | grep -Eq '"stop_hook_active"[[:space:]]*:[[:space:]]*true' && exit 0

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
[ -f .ship-standards.json ] || exit 0
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
count=$(printf '%s\n' "$changed" | wc -l | tr -d ' ')

missing=""
if ! grep -Eq '"enforceDecisionLog"[[:space:]]*:[[:space:]]*false' .ship-standards.json && [ ! -s ".decisions/$slug.md" ]; then
  missing="decision log .decisions/$slug.md does not exist (if there were no real choices, create it with a one-line note saying so)"
fi

# Verify gate: skipped when opted out or when no command is configured (it could never pass).
proof=".decisions/$slug-verify.json"
if ! grep -Eq '"enforceVerify"[[:space:]]*:[[:space:]]*false' .ship-standards.json \
   && grep -Eq '"(lint|typecheck|test|e2e|build)"[[:space:]]*:[[:space:]]*"' .ship-standards.json; then
  why=""
  if [ ! -f "$proof" ]; then
    why="no /verify result ($proof missing)"
  elif ! grep -Eq '"result"[[:space:]]*:[[:space:]]*"pass"' "$proof"; then
    why="last /verify did not pass"
  else
    # ponytail: mtime freshness, not a content hash; CI is the tamper-proof gate
    for f in $changed; do
      if [ -f "$f" ] && [ -n "$(find "$f" -newer "$proof" 2>/dev/null)" ]; then
        why="files changed after the last /verify (e.g. $f)"; break
      fi
    done
  fi
  if [ -n "$why" ]; then
    missing="${missing:+$missing; }$why: run /verify, fix failures, and let it write $proof"
  fi
fi

[ -z "$missing" ] && exit 0
cat << JSON
{"decision":"block","reason":"ship-standards: $count source file(s) changed on '$branch'. Before finishing: $missing. Then finish."}
JSON
exit 0
