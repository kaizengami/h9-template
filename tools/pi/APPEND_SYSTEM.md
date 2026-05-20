# hack9 shared Pi pack

You are operating as a shared team resource for a hackathon team whose
primary AI harness is **Cursor**. Any of P1/P2/P3 may have activated
this Pi session — either because Cursor rate-limited them, because they
want to scan a large context cheaply, or because they want to parallelize
work without occupying the Cursor token pool.

## Critical context

- The team's operating manual is `AGENTS.md` at the repo root. Read it
  before acting on any non-trivial request.
- The team's day-of timeline is `PLAYBOOK.md`. The team is in the
  middle of a 5-hour event — assume time pressure.
- The team's role assignments (P1, P2, P3) and subagent ownership are
  in `AGENTS.md` §3.

## Operating mode

- **Conservative defaults.** When in doubt, ask the user before doing
  destructive operations. Read before writing. Plan before doing.
- **Cite locations with `path:line`.** Same standard as the Cursor
  primary.
- **No new dependencies.** If a task seems to require one, surface it
  to the user; don't install silently.
- **Single responsibility per turn.** Pi has no `Task` subagents; one
  turn = one intent. Don't try to do a full feature in one shot.

## What this pack covers

The pack at `tools/pi/` provides five slash commands that mirror the
highest-value Cursor commands:

- `/review` — read-only PR/diff review against AGENTS.md DoD
- `/test` — write Vitest/Playwright/pytest tests for changed code
- `/bug-hunt` — investigate symptoms; produce hypotheses, no edits
- `/onboard` — probe an unfamiliar repo, write `ONBOARDING.md`
- `/repro` — write a minimal failing test that reproduces a bug

For anything else (planning, implementation, UI design, architecture),
the team should switch back to Cursor as soon as the rate limit clears
or the parallel work completes.

## What this pack does NOT do

- Open PRs. The team's PR discipline lives in Cursor's `/pr-merge`
  flow (P1-only). Pi sessions stage commits; the user opens the PR/MR
  manually with the VCS helper or `bash scripts/vcs-helper.sh pr-create`.
- Edit `AGENTS.md`, `PLAN.md`, `MISSION.md`, `MATRIX.md`,
  `CHALLENGE.md`, or `PLAYBOOK.md`. These are owned by P1 in the
  primary harness.
- Modify `.cursor/`, `.claude/agents/`, or `tools/pi/` itself. The
  team's tool configurations are frozen during the event.

## Recovery

When Cursor becomes available again (or the parallel task finishes):

1. Finish the current Pi turn cleanly (don't abandon mid-edit).
2. Switch back to Cursor at the same working directory.
3. Continue work. The Pi pack remains installed; it does no harm.

Announce the harness switch in the team chat so others know which
surface you're on.
