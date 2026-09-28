#!/usr/bin/env bash
# Runs stop-check.sh against a throwaway git repo and asserts when it blocks (spec 002, AC-2..AC-5).
set -u
hook="$(cd "$(dirname "$0")/.." && pwd)/plugins/ship-standards/hooks/scripts/stop-check.sh"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cd "$tmp" && git init -q -b main && git config core.autocrlf false && git config user.email t@t && git config user.name t
cfg() { printf '{"baseBranch":"main","commands":{"test":"true"}%s}\n' "${1:-}" > .ship-standards.json; }
cfg; git add -A && git commit -qm init && git checkout -qb feat/x
mkdir -p .decisions
fails=0
run() { printf '%s' "${2:-{\}}" | CLAUDE_PROJECT_DIR="$tmp" bash "$hook"; }
expect() { # name, want (block|pass), [stdin]
  out=$(run "$1" "${3:-}")
  got=pass; printf '%s' "$out" | grep -q '"decision":"block"' && got=block
  if [ "$got" = "$2" ]; then echo "ok   $1"; else echo "FAIL $1 (want $2, got $got: $out)"; fails=$((fails+1)); fi
}

expect "no source change"                pass
echo 'x' > a.ts
expect "AC-2 no decision log, no proof"  block
echo 'no real choices' > .decisions/feat-x.md
expect "AC-2 proof missing"              block
sleep 1; echo '{"result":"fail"}' > .decisions/feat-x-verify.json
expect "AC-3 proof failed"               block
echo '{"result":"pass"}' > .decisions/feat-x-verify.json
expect "AC-4 fresh passing proof"        pass
sleep 1; echo 'y' >> a.ts
expect "AC-3 edit after verify"          block
expect "AC-5 stop_hook_active"           pass '{"stop_hook_active": true}'
cfg ',"enforceVerify":false'
expect "AC-5 enforceVerify false"        pass
printf '{"baseBranch":"main","commands":{"test":null}}\n' > .ship-standards.json
expect "AC-5 no commands configured"     pass
cfg; rm .decisions/feat-x.md
out=$(run x); printf '%s' "$out" | grep -q 'decision log' && printf '%s' "$out" | grep -q '/verify' \
  && echo "ok   AC-5 one combined block" || { echo "FAIL AC-5 combined: $out"; fails=$((fails+1)); }
git checkout -q main 2>/dev/null || git checkout -qf main
expect "AC-5 base branch"                pass

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
