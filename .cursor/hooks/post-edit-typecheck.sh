#!/usr/bin/env bash
# .cursor/hooks/post-edit-typecheck.sh
# afterFileEdit hook for Write / Edit / TabWrite.
# Runs typecheck and lint on the changed TypeScript file. Tolerant of missing
# package.json and missing scripts — Phase 1 of this template ships no
# Next.js skeleton, so this hook is a no-op until Phase 2.
#
# Hook contract (Cursor, May 2026):
#   stdin:  JSON payload describing the edit (field names vary by event)
#   stdout: free-form text; appended to the assistant's context
#   exit code 0: success / advisory
#   exit code 2: blocking error (we never want this; failures are advisory)

set -uo pipefail

# Read the entire stdin payload.
input="$(cat 2>/dev/null || true)"

# Best-effort extraction of the edited file path. Cursor's afterFileEdit
# event may surface the path as `file_path`, `path`, or nested under
# `tool_input` in older shapes. Try all of them.
file=""
if command -v jq >/dev/null 2>&1; then
  file="$(printf '%s' "$input" | jq -r '
    .file_path
    // .path
    // .tool_input.file_path
    // .tool_input.path
    // empty
  ' 2>/dev/null || true)"
fi
if [ -z "$file" ]; then
  file="$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' || true)"
fi

# Not a TypeScript file? Silently succeed.
case "$file" in
  *.ts|*.tsx) ;;
  *) exit 0 ;;
esac

# Determine project root. CURSOR_PROJECT_DIR is set by Cursor; fall back to
# CLAUDE_PROJECT_DIR (for compatibility with shared scripts) and finally pwd.
project_dir="${CURSOR_PROJECT_DIR:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"

# No package.json yet (Phase 1 of this template) → no-op success.
if [ ! -f "$project_dir/package.json" ]; then
  exit 0
fi

cd "$project_dir" || exit 0

# Pick a package manager.
pm=""
if [ -f "pnpm-lock.yaml" ] && command -v pnpm >/dev/null 2>&1; then
  pm="pnpm"
elif [ -f "package-lock.json" ] && command -v npm >/dev/null 2>&1; then
  pm="npm"
elif command -v pnpm >/dev/null 2>&1; then
  pm="pnpm"
elif command -v npm >/dev/null 2>&1; then
  pm="npm"
else
  exit 0
fi

# Check the typecheck script exists. We do not invent one.
has_script() {
  grep -q "\"$1\"[[:space:]]*:" package.json 2>/dev/null
}

if has_script "typecheck"; then
  if ! out="$("$pm" -s run typecheck 2>&1)"; then
    printf 'typecheck failed for %s:\n%s\n' "$file" "$(printf '%s' "$out" | tail -20)"
    exit 0  # advisory, not blocking
  fi
fi

if has_script "lint"; then
  if ! out="$("$pm" -s run lint --silent -- --max-warnings=999 2>&1)"; then
    printf 'lint failed for %s:\n%s\n' "$file" "$(printf '%s' "$out" | tail -10)"
    exit 0
  fi
fi

# Quiet success: print nothing.
exit 0
