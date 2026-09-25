#!/usr/bin/env bash
# Adds short workflow context at session start. Plain stdout becomes context for Claude.
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

if [ ! -f .ship-standards.json ]; then
  # Only nudge in repos that look like real projects
  if [ -f package.json ] || [ -f pyproject.toml ] || [ -f requirements.txt ]; then
    echo "ship-standards: this repo is not initialised. If the user starts feature work, suggest running /init-standards once (it adapts to existing conventions)."
  fi
  exit 0
fi

branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
slug=$(printf '%s' "$branch" | tr '/' '-')
echo "ship-standards is active in this repo (config: .ship-standards.json). Follow the workflow block in AGENTS.md (CLAUDE.md imports it)."
echo "Current branch: $branch. Decision log for this branch: .decisions/$slug.md"

# Specs that are approved but not done = likely active work
active=$(grep -l -E '^\*\*Status:\*\* *approved' specs/*.md 2>/dev/null | head -5)
if [ -n "$active" ]; then
  echo "Approved specs not yet done:"
  printf '  - %s\n' $active
fi
[ -f graphify-out/GRAPH_REPORT.md ] && echo "Codebase graph available: read graphify-out/GRAPH_REPORT.md before architecture questions."
exit 0
