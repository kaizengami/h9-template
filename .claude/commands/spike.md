---
description: Create a parallel attempt in a git worktree. Use when exploring a risky direction without blocking main work, or to enable two engineers to work on different features simultaneously without merge conflicts.
argument-hint: "<spike-name> <one-line-objective>"
allowed-tools: Bash(git:*), Bash(mkdir:*), Bash(tmux:*), Bash(echo:*), Write, Read
---

Create a git worktree for a parallel attempt.

**Arguments:** $ARGUMENTS

Steps:

1. Parse `$1` as the spike name (must be a short kebab-case slug).
   Reject names containing slashes, spaces, or starting with a digit.
   The rest of `$ARGUMENTS` (everything after `$1`) is the objective.
2. Verify the worktree doesn't already exist:
   `git worktree list | grep -q "hack9-$1"` — if it does, stop and
   print "worktree already exists" with the path.
3. Create the worktree:
   ```bash
   git worktree add "../hack9-$1" -b "spike/$1"
   ```
4. Write `../hack9-$1/SPIKE.md` with this content:

   ```markdown
   # Spike — $1

   **Created:** <ISO timestamp>
   **Owner:** <ask the user which engineer owns this spike>
   **Objective:** <the rest of $ARGUMENTS after $1>

   ## What we're trying to learn
   <expand objective into 2–3 sentences>

   ## Time box
   <default: 45 minutes. Stop and write findings if exceeded.>

   ## Findings (fill in as you go)
   - …

   ## Decision
   <after the time box: promote to feat/ branch, or discard with notes>
   ```

5. Print the next command for the user to run, exactly:

   ```
   Spike ready at ../hack9-$1.
   Open in a new tmux pane:

       tmux split-window -h -c "../hack9-$1" "claude"

   Or attach manually:

       cd ../hack9-$1 && claude
   ```

Do **not** start the new Claude Code session yourself. The user runs the
tmux command so they keep control of pane layout.

Do not commit anything in the new worktree from the current session.
