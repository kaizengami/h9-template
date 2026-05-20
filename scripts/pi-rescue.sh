#!/usr/bin/env bash
# scripts/pi-rescue.sh — activate the shared Pi pack and launch Pi.
#
# Use this when Cursor rate-limits you mid-session, when you want to
# scan a large context cheaply, or when you want to parallelize work
# without occupying the Cursor token pool.
#
# Installs tools/pi/ as a local Pi package and starts Pi in the
# project root. See tools/pi/README.md for context.

set -euo pipefail

# --- preconditions -------------------------------------------------------

if ! git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo >&2 "error: not inside a git repository"
  exit 66
fi
cd "$git_root"

if [ ! -d "tools/pi" ]; then
  echo >&2 "error: tools/pi/ not found at $git_root"
  exit 67
fi

if ! command -v pi >/dev/null 2>&1; then
  echo >&2 "error: 'pi' CLI not found in PATH"
  echo >&2 "install with: npm install -g @earendil-works/pi-coding-agent"
  echo >&2 "or see https://pi.dev/docs/latest for current install instructions"
  exit 127
fi

# --- announce ------------------------------------------------------------

cat <<'EOF'
╭─────────────────────────────────────────────────────────────────────╮
│ Pi pack — shared team resource                                       │
│                                                                      │
│ This launches Pi with the team's shared prompt pack. Use it when     │
│ Cursor rate-limits you, when you want a cheap large-context scan,   │
│ or when you want to parallelize work without occupying the          │
│ Cursor pool.                                                         │
│                                                                      │
│ Announce the switch in team chat per AGENTS.md §6 before continuing. │
╰─────────────────────────────────────────────────────────────────────╯
EOF

# --- install the local pack ----------------------------------------------
#
# 'pi install -l <path>' writes to project-scoped .pi/settings.json
# and adds the local path to the package list. No files copied.

echo "Installing tools/pi/ into .pi/settings.json (local path install)…"
pi install -l ./tools/pi

# --- launch Pi -----------------------------------------------------------

cat <<'EOF'

Pi pack installed. Launching Pi…

Available prompts:
  /review      — read-only PR/diff review
  /test        — add Vitest + Playwright + pytest tests
  /bug-hunt    — investigate a symptom, produce hypotheses
  /onboard     — probe an unfamiliar repo, write ONBOARDING.md
  /repro       — write a minimal failing test on a repro/ branch

For anything else (planning, implementation, UI design, PR merge),
return to Cursor when the rate limit clears or the parallel task
completes. See AGENTS.md §6 and the pack README at tools/pi/README.md.
EOF

exec pi
