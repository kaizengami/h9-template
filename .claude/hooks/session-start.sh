#!/usr/bin/env bash
# .claude/hooks/session-start.sh
# SessionStart hook. Prints a short state summary to stderr (NOT injected
# into the model context) so anyone joining a session sees:
#   - current branch + ahead/behind
#   - open PRs
#   - count of open items in PLAN.md
#
# Wired up in .claude/settings.json under hooks.SessionStart. Must exit 0
# even when individual checks fail; this is informational only.

set -u

project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$project_dir" 2>/dev/null || exit 0

{
  echo "─── hack9 session state ───"

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "(detached)")
    echo "branch: $branch"

    if [ -n "$branch" ] && git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
      ahead=$(git rev-list --count "origin/$branch..$branch" 2>/dev/null || echo 0)
      behind=$(git rev-list --count "$branch..origin/$branch" 2>/dev/null || echo 0)
      echo "vs origin: ${ahead} ahead, ${behind} behind"
    else
      echo "vs origin: no upstream"
    fi

    dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    echo "working tree: ${dirty} changed file(s)"
  else
    echo "(not in a git repo)"
  fi

  if command -v gh >/dev/null 2>&1; then
    if command -v jq >/dev/null 2>&1; then
      open_prs=$(gh pr list --limit 10 --json number,title 2>/dev/null \
        | jq -r 'if length==0 then "open PRs: (none)" else "open PRs: " + ([.[] | "#\(.number) \(.title)"] | join(", ")) end' 2>/dev/null \
        || echo "open PRs: (gh unavailable)")
      echo "$open_prs"
    else
      echo "open PRs: $(gh pr list --limit 10 2>/dev/null | head -10 | wc -l | tr -d ' ') (install jq for titles)"
    fi
  else
    echo "open PRs: (gh CLI not installed)"
  fi

  if [ -f PLAN.md ]; then
    open_items=$(grep -c '^- \[ \]' PLAN.md 2>/dev/null || echo 0)
    echo "PLAN.md: ${open_items} open item(s)"
  fi

  echo "─── (informational only; not injected into model context) ───"
} >&2

exit 0
