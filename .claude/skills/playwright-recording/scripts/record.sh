#!/usr/bin/env bash
# .claude/skills/playwright-recording/scripts/record.sh
# Wrapper that runs the demo-tagged Playwright tests with the team's
# standard recording flags and moves the resulting video to the repo root.
#
# Invoked from the playwright-recording skill via
#   bash ${CLAUDE_SKILL_DIR}/scripts/record.sh
# but also works standalone:
#   bash .claude/skills/playwright-recording/scripts/record.sh

set -euo pipefail

# --- locate the project root ---------------------------------------------

project_dir="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
if [ -z "$project_dir" ]; then
  echo >&2 "error: not inside a git repo and CLAUDE_PROJECT_DIR is unset"
  exit 66
fi
cd "$project_dir"

# --- preconditions -------------------------------------------------------

if [ ! -f "playwright.config.ts" ] && [ ! -f "playwright.config.js" ]; then
  cat >&2 <<'EOF'
error: no playwright.config.{ts,js} at the repo root.
Create one per the SKILL.md template, then re-run.
EOF
  exit 67
fi

if ! command -v npx >/dev/null 2>&1; then
  echo >&2 "error: npx not found in PATH"
  exit 127
fi

# --- wait for dev server (best-effort) -----------------------------------

base_url="${E2E_BASE_URL:-http://localhost:3000}"
echo >&2 "Waiting for dev server at $base_url (up to 30s)…"
for i in $(seq 1 30); do
  if curl -s -o /dev/null -w '%{http_code}' --max-time 1 "$base_url" 2>/dev/null | grep -qE '^[2-3]'; then
    echo >&2 "  dev server is reachable."
    break
  fi
  sleep 1
  if [ "$i" = "30" ]; then
    echo >&2 "  timed out; continuing anyway (recording may fail)."
  fi
done

# --- run the recording ---------------------------------------------------

mkdir -p docs/screenshots test-results

set +e
npx playwright test \
  --grep @demo \
  --headed \
  --workers=1 \
  --reporter=line
playwright_exit=$?
set -e

# --- promote the most recent video to demo.webm --------------------------
#
# Playwright writes videos to test-results/<spec-folder>/video.webm. Pick the
# most recently modified one and move it to the repo root.

latest_video=$(find test-results -type f -name 'video.webm' -print0 2>/dev/null \
  | xargs -0 ls -t 2>/dev/null \
  | head -1 || true)

if [ -n "$latest_video" ]; then
  mv "$latest_video" "demo.webm"
  echo >&2 "Recording saved to: demo.webm"
else
  echo >&2 "warning: no video.webm found under test-results/."
fi

# --- summary -------------------------------------------------------------

echo >&2 ""
echo >&2 "────────────────────────────────────────"
if [ "$playwright_exit" = "0" ]; then
  echo >&2 " Playwright tests passed."
else
  echo >&2 " Playwright tests FAILED (exit $playwright_exit)."
  echo >&2 " The video (if any) is still saved; check test-results/ for traces."
fi
echo >&2 ""
echo >&2 " Next steps:"
echo >&2 "   1. Open demo.webm and verify the happy path."
echo >&2 "   2. Commit: docs(demo): add demo recording and screenshots"
echo >&2 "   3. Reference demo.webm in DEMO.md."
echo >&2 "────────────────────────────────────────"

exit "$playwright_exit"
