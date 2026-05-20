#!/usr/bin/env bash
# scripts/spike.sh — create a git worktree for a parallel attempt.
#
# Usage:
#   bash scripts/spike.sh <name> [one-line objective…]
#
# Examples:
#   bash scripts/spike.sh csv-upload "validate the parser handles malformed input"
#   bash scripts/spike.sh auth-spike
#
# Creates a sibling worktree at ../hack9-<name> on branch spike/<name>,
# writes a SPIKE.md file in the worktree, and prints the command to open
# a new Cursor window rooted at that worktree (via tmux).

set -euo pipefail

# --- arg parsing ---------------------------------------------------------

if [ $# -lt 1 ]; then
  cat >&2 <<'EOF'
Usage: bash scripts/spike.sh <name> [one-line objective...]

  <name>       short kebab-case slug (a-z, 0-9, hyphens; must not start with a digit)
  [objective]  optional; goes into SPIKE.md "Objective" field
EOF
  exit 64
fi

name="$1"
shift
objective="${*:-(no objective provided)}"

# Validate name.
if ! printf '%s' "$name" | grep -qE '^[a-z][a-z0-9-]{0,40}$'; then
  echo >&2 "error: name must be kebab-case (a-z, 0-9, -), start with a letter, ≤ 41 chars; got: $name"
  exit 65
fi

# --- preconditions -------------------------------------------------------

# Must run from a git repo root.
if ! git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo >&2 "error: not inside a git repository"
  exit 66
fi
cd "$git_root"

worktree_path="../hack9-$name"
branch="spike/$name"

# Refuse to overwrite an existing worktree.
if git worktree list | grep -q "$worktree_path"; then
  echo >&2 "error: worktree already exists at $worktree_path"
  echo >&2 "to remove it: git worktree remove $worktree_path"
  exit 67
fi

# Refuse to overwrite an existing branch.
if git show-ref --verify --quiet "refs/heads/$branch"; then
  echo >&2 "error: branch $branch already exists locally"
  exit 68
fi

# --- create worktree -----------------------------------------------------

git worktree add "$worktree_path" -b "$branch" >&2

# --- write SPIKE.md ------------------------------------------------------

iso_now="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
cat > "$worktree_path/SPIKE.md" <<EOF
# Spike — $name

**Created:** $iso_now
**Branch:** $branch
**Worktree:** $worktree_path
**Owner:** _set on first commit (P1, P2, or P3)_
**Objective:** $objective

## What we're trying to learn

_Expand the objective into 2–3 sentences. What signal will tell us this
direction is worth pursuing vs. discarding?_

## Time box

**Default:** 45 minutes. Stop and write findings if exceeded.

## Findings

_Add evidence as you go. Each finding cites \`path:line\`._

- _…_

## Decision

_After the time box: promote to a \`feat/\` branch, or discard with notes._

- [ ] Promote to \`feat/$name\` (open PR per [AGENTS.md §4.3](../hack9-template/AGENTS.md))
- [ ] Discard — notes: _…_
EOF

# --- print next-step instructions ---------------------------------------

cat <<EOF
Spike ready.

  Worktree:  $worktree_path
  Branch:    $branch
  SPIKE.md:  $worktree_path/SPIKE.md

Open in a new tmux pane (split horizontally, opens Cursor in the worktree):

    tmux split-window -h -c "$worktree_path" "cursor ."

Or open in a new tmux window:

    tmux new-window -c "$worktree_path" "cursor ."

Or attach manually:

    cd "$worktree_path" && cursor .

When the spike is done, either promote it:

    cd "$worktree_path"
    git switch -c feat/$name
    # Open PR/MR using the VCS helper (e.g. bash scripts/vcs-helper.sh pr-create "feat/$name" "feat/$name" body_file):
    bash scripts/vcs-helper.sh pr-create "feat/$name" "feat/$name" body.md

Or discard:

    git worktree remove "$worktree_path"
    git branch -D "$branch"
EOF
