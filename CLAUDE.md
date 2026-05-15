@AGENTS.md

## Claude Code specifics

The team operating manual is in [AGENTS.md](AGENTS.md), imported above. The
notes below apply only when Claude Code is the active harness.

### When to switch modes

- Default to **plan mode** (Shift+Tab twice) for any change touching
  `app/`, `lib/db/`, or anything that crosses a module boundary.
- Stay in normal mode for surface-level edits inside a file you already
  understand.
- Never run a hook-blocking command without confirming the hook is intended
  to fire (see [.claude/hooks/](.claude/hooks/)).

### Subagent picker shortcuts

Use `@<name>` to explicitly delegate. Auto-delegation is fine, but for the
load-bearing decisions, name the agent so it shows up in the transcript.

- `@architect` — system-design tradeoffs, ADR-worthy choices
- `@planner` — break a feature into PR-sized chunks; update `PLAN.md`
- `@implementer` — write a clearly-scoped feature from a plan
- `@ui-designer` — shadcn-based component scaffolding
- `@refactorer` — safe restructuring (no behavior change)
- `@reviewer` — read-only PR review, produces `OK_TO_MERGE: yes/no`
- `@test-writer` — Vitest unit + Playwright E2E generation
- `@bug-hunter` — investigation only, surfaces hypotheses with evidence
- `@demo-builder` — demo script, Playwright recording, screenshot capture

### Slash commands you will use most

- `/plan <task>` — invokes `@planner`, writes into `PLAN.md`
- `/spike <name> <objective>` — creates a sibling worktree and tmux pane
- `/ship <feature>` — sequential plan → implement → test → PR
- `/review` — `@reviewer` on the current diff against `main`
- `/pr-merge <num>` — P1-only; squashes and merges a PR after checks

The full set lives in [.claude/commands/](.claude/commands/).

### Worktrees over branches

Always start a new line of work with `/spike` rather than `git checkout -b`.
The worktree gives each parallel attempt its own filesystem; you can run
two `pnpm dev` servers in two worktrees without port collisions if you set
`PORT` per worktree.

### PR discipline

- Open every PR with `gh pr create`. Never push to `main` directly; the
  rule in [AGENTS.md §4.3](AGENTS.md) applies.
- The commit attribution trailer is set by
  [.claude/settings.json](.claude/settings.json); do not add a second one
  by hand.
- If the post-edit hook prints typecheck errors, address them before
  opening the PR. Hook failures are advisory in Phase 1, not blocking.

### Token economy

- Use `sonnet` (the project default in `settings.json`) for normal work.
- Switch to `haiku` via `/model` for repetitive mechanical tasks (e.g.
  renaming, batch test scaffolding).
- Reserve `opus` for `@architect` decisions where reasoning depth matters.
- If you hit a rate limit: run `bash scripts/pi-rescue.sh` and continue in
  Pi. Announce the switch in the team chat per
  [AGENTS.md §6](AGENTS.md).

### Context discipline

Context window hygiene is a quality lever, not a nicety. Three habits
to apply during the event:

- **`/clear` between unrelated tasks.** After finishing a feature,
  `/clear` before starting the next one. Also use it after two
  corrections on the same issue — that's a signal the context is
  poisoned and a fresh start with a better prompt beats more turns.
- **`/btw` for off-topic side questions.** Quick lookups ("how do I
  spell that CLI flag?") via `/btw` keep the answer out of the main
  conversation history. Don't pollute the working context with
  ephemeral facts.
- **`--permission-mode auto` is an advanced lever.** Useful for
  repetitive batch work (mass-renaming, scaffolding) where you'd
  otherwise click approve dozens of times. **Not** for general work
  during this event — one bad bash invocation could break the repo,
  and the team's default remains the standard permission mode. If
  you do flip to auto, narrow the scope, announce it in the team
  chat, and revert immediately after.

These habits compound: clean context + scoped permissions + named
subagents is what makes the workflow legible to both the team and
the judges.

### Read these on first session

Before any non-trivial change, read these in order: [AGENTS.md](AGENTS.md),
the section of [PLAYBOOK.md](PLAYBOOK.md) that matches the current event
phase, and the `PLAN.md` produced on day-of. If `PLAN.md` does not exist
yet, the right first action is to run `/plan` against the challenge brief.
