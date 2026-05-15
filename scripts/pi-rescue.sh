#!/usr/bin/env bash
# scripts/pi-rescue.sh — install the Pi fallback pack and launch Pi.
#
# Use this when Claude Code is rate-limited or otherwise unavailable.
# Installs tools/pi-fallback/ as a local Pi package and starts Pi in the
# project root. See tools/pi-fallback/README.md for context.

set -euo pipefail

# --- preconditions -------------------------------------------------------

if ! git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo >&2 "error: not inside a git repository"
  exit 66
fi
cd "$git_root"

if [ ! -d "tools/pi-fallback" ]; then
  echo >&2 "error: tools/pi-fallback/ not found at $git_root"
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
│ Pi rescue mode                                                       │
│                                                                      │
│ This switches your active harness from Claude Code to Pi. Use only   │
│ when Claude Code is unavailable (rate limit, provider mismatch).     │
│                                                                      │
│ Announce the switch in team chat per AGENTS.md §6 before continuing. │
╰─────────────────────────────────────────────────────────────────────╯
EOF

# --- install the local pack ----------------------------------------------
#
# 'pi install -l <path>' writes to project-scoped .pi/settings.json
# and adds the local path to the package list. No files copied.

echo "Installing tools/pi-fallback/ into .pi/settings.json (local path install)…"
pi install -l ./tools/pi-fallback

# --- launch Pi -----------------------------------------------------------

cat <<'EOF'

Pi pack installed. Launching Pi…

Available prompts in fallback mode:
  /review      — read-only PR/diff review
  /test        — add Vitest + Playwright tests
  /bug-hunt    — investigate a symptom, produce hypotheses

For anything else (planning, implementation, UI design), wait for
Claude Code to recover and switch back. See AGENTS.md §6 and the
fallback pack README at tools/pi-fallback/README.md.
EOF

exec pi
