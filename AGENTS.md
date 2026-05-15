# AGENTS.md — operating manual for hack9

> This file is the single source of truth for all three engineers and all three
> AI coding harnesses on the team. Cursor reads it natively; Claude Code
> imports it via `@AGENTS.md` from [CLAUDE.md](CLAUDE.md); Pi walks it up
> from cwd. Keep it short, concrete, and human-written — judges and agents
> will both read it from end to end.

---

## 1. Mission

<!-- FILL THIS IN AT 0:00–0:20 ON HACKATHON DAY. KEEP TO 5 LINES MAX. -->

- **Problem we are solving:** _TBD on hackathon day._
- **Primary user:** _TBD._
- **Demo win condition:** _TBD — what one workflow we will showcase live._
- **Out of scope:** _TBD — explicit deferrals to keep us on time._

The first commit on hackathon day must be a `MISSION.md` written by P1 that
expands the four bullets above into one short paragraph each. Until that is
committed, nobody opens an implementation PR.

**Alternative for given-repo challenges:** if the challenge gives the
team 1–6 existing repositories to fix or extend rather than a
build-from-spec brief, fill out [CHALLENGE.md](CHALLENGE.md) instead
of (or in addition to) MISSION.md. Run `/onboard <path>` for each
given repo before any implementation PR opens.
[PLAYBOOK.md](PLAYBOOK.md) Phase 1 has the explicit decision fork.

---

## 2. Tech stack (locked-in defaults)

These are the defaults that the team has rehearsed. Deviations are allowed
only if the challenge brief makes them clearly wrong; in that case P1 amends
this section in the same commit as the deviation.

- **Language**: TypeScript (strict). No JavaScript files except generated.
- **App framework**: Next.js 15 (App Router) — chosen for "one process, one
  port" simplicity. Server actions or thin route handlers; no separate API
  app unless the challenge demands it.
- **UI**: Tailwind + shadcn/ui (copy-in components, not a dependency).
- **DB**: Drizzle ORM over libSQL/SQLite — single file, zero infra, agents
  generate schemas confidently.
- **AI features (if needed)**: Vercel AI SDK (`ai`, `@ai-sdk/anthropic`).
- **Validation**: Zod everywhere user input crosses a boundary.
- **Tests**: Vitest (unit), Playwright (E2E + demo recording).
- **Tooling**: pnpm, ESLint (`next/core-web-vitals`), Prettier.
- **Demo capture**: Playwright `--video=on` + `page.screenshot()`.

Phase-1 of this template ships configuration only; the Next.js skeleton is
introduced in Phase 2 when we finalize the layout on the prep dry-run.

---

## 3. Roles and ownership

Three engineers, all driving Claude Code as the primary harness. Each
engineer **owns** three subagents under [.claude/agents/](.claude/agents/):
they author them, tune their descriptions, and are the named escalation
point if those subagents misbehave during the event.

| Person | Role                       | Owns subagents                                       | Secondary tool      |
| ------ | -------------------------- | ---------------------------------------------------- | ------------------- |
| **P1** | Planner / Architect / Demo | `architect`, `planner`, `demo-builder`               | Cursor (last hour)  |
| **P2** | Implementer                | `implementer`, `ui-designer`, `refactorer`           | none                |
| **P3** | Reviewer / Tester / QA     | `reviewer`, `test-writer`, `bug-hunter`              | Pi (rate-limit only)|

Subagent files carry a `# Owner: PN` comment on line 1 of the body so that
`head -1 .claude/agents/*.md` shows the ownership table directly. See
[.claude/agents/reviewer.md](.claude/agents/reviewer.md) for the canonical
example.

---

## 4. Workflow contract

Every change goes through this loop. No exceptions. The shape is what makes
parallel work by three humans + nine subagents possible without merge chaos.

### 4.1 Branching

- `main` is always green and demo-able. Nobody pushes to `main` directly.
- Feature branches: `feat/<short-kebab>` (e.g. `feat/csv-upload`).
- Spike branches: `spike/<short-kebab>` for time-boxed exploratory work.
- Fixes: `fix/<short-kebab>`.

### 4.2 Worktrees for parallel work

When P1, P2, or P3 wants to explore in parallel without blocking the main
branch, run [/spike](.claude/commands/spike.md) (or `bash scripts/spike.sh
<name>`). This creates a sibling git worktree at `../hack9-<name>/` on a
fresh branch and opens a new tmux pane with Claude Code rooted there. Two
engineers can run independent spikes simultaneously without stepping on
each other's working tree.

### 4.3 Pull requests

- All PRs opened via `gh pr create` from inside the agent (do not rely on a
  human navigating GitHub).
- PR body must include the checklist from
  [.claude/commands/pr-merge.md](.claude/commands/pr-merge.md) Definition of
  Done section.
- UI PRs require a screenshot or Playwright recording in the PR body. The
  `@demo-builder` subagent attaches it.
- P1 is the **only** person who merges PRs to `main`. P2 and P3 review and
  approve; P1 squashes-and-merges.

### 4.4 Conflicts

If a PR has merge conflicts: do **not** resolve them in the agent. Instead,
the PR author writes a one-paragraph `RESOLVE.md` in the PR comments
describing what they intended, and P1 resolves on the merge.

### 4.5 Commits

- Conventional Commits style: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`,
  `chore:`.
- Keep messages one line. Detail goes in the PR body, not the commit.
- Claude Code's [`attribution.commit: "co-author"`](.claude/settings.json)
  setting adds an automatic trailer; do not add a second one by hand.

---

## 5. Definition of Done (per PR)

A PR is mergeable when **all** of these hold:

1. `pnpm typecheck` is clean (once Phase 2 lands; until then this line is
   advisory and the hook is a no-op).
2. `pnpm test` passes for any changed module.
3. For UI changes: a screenshot is attached to the PR body.
4. `@reviewer` subagent's report (in PR body or comment) marks
   `OK_TO_MERGE: yes`.
5. No new secrets or credentials in tracked files.
6. The change is described in one sentence at the top of the PR body
   ("what" and "why", not "how").

A PR is **not** required to be perfect. We are at a 5-hour hackathon. Defer
non-essential polish to `TODO.md` in the repo root, and ship.

---

## 6. Coordination protocol

How three humans and nine subagents stay out of each other's way:

- **`MISSION.md`** is owned by P1 and updated only by P1.
- **`PLAN.md`** is owned by P1 and is the authoritative todo list for the
  day. P2 and P3 propose changes by amending PLAN.md inside their feature
  branches; P1 merges.
- **Each engineer claims a directory** in PLAN.md before starting work.
  Example: P2 claims `app/`, P3 claims `tests/` and `lib/validation/`.
  Cross-cutting changes require a PLAN.md update first.
- **Subagent invocations are free of coordination cost** — each engineer
  uses their own subagents inside their own session. Subagents do not edit
  shared files (PLAN.md, AGENTS.md, MISSION.md) without explicit human
  approval.
- **Rate-limit recovery**: if the Anthropic API rate-limits Claude Code,
  the affected engineer runs `bash scripts/pi-rescue.sh` and continues in
  Pi with the equivalent prompts from
  [tools/pi-fallback/prompts/](tools/pi-fallback/prompts/). They announce
  the switch in the team chat so others know which surface they're on.

---

## 7. Demo flow (last 90 minutes)

Documented in [PLAYBOOK.md](PLAYBOOK.md) §5. Three rules during demo prep:

1. No new features after the 3:00 mark. Polish only.
2. P1 owns the recording session. P2 fixes only blocking bugs found during
   recording. P3 verifies happy-path on a clean checkout.
3. The submitted demo is a Playwright-recorded video, not a live screen
   share. Live demos lose to bad WiFi.

---

## 8. Why this configuration exists

See [MATRIX.md](MATRIX.md) for the full pitch — that file is written for
the AI judge, not for the team. The short version: we standardized on
Claude Code because subagents + shared slash commands + hooks compound
across three engineers, and a terminal-first agent loop is the highest-
leverage realization of "Code less, AI more".
