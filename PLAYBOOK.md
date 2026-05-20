# PLAYBOOK.md — hackathon day timeline

This is the minute-level script for the three engineers on May 22. Print it,
keep it on a second monitor, or pin a tmux pane to it. Times are wall-clock
elapsed from the start of the building window.

The plan is built around five phases. Each phase has explicit deliverables
and a stop-condition: if a phase's deliverable is not done by its end time,
the team rolls forward anyway. The 4-hour cap is sacred; the demo is what
gets judged.

---

## Pre-event checklist (the morning of)

Done by 30 minutes before kickoff:

- [ ] Cursor installed, signed into Cursor Enterprise on all three laptops.
- [ ] Pi installed on at least one laptop (any of P1/P2/P3) so the
      fallback is ready when any engineer needs it.
- [ ] `gh auth status` returns `Logged in to github.com`.
- [ ] `tmux -V` prints a version (we use tmux for parallel sessions).
- [ ] `npx playwright install chromium` has been run at least once
      (browsers cached locally).
- [ ] Each engineer has cloned a fresh copy of this template into a new
      empty directory; the team agrees in advance which laptop is the
      "main" laptop that owns `main` branch pushes.
- [ ] The team's GitHub repo for the hackathon exists (create empty repo,
      add it as `origin` on P1's laptop).
- [ ] Whatever credentials the organizers issue (Cursor enterprise pool,
      Pi token, etc.) are configured in each engineer's environment.
- [ ] The Pi pack lives under [tools/pi/](tools/pi/) and is committed —
      any engineer can activate it via `bash scripts/pi-rescue.sh` when
      Cursor rate-limits or when they want to scan a large context cheaply.

---

## Phase 1 — Brief & Plan (0:00–0:20)

**Goal:** turn the challenge brief into a one-page `MISSION.md` and a
priority-ordered `PLAN.md`. Nothing else.

### Fork on challenge type (decide in the first 60 seconds)

The first thing P1 does after reading the brief is decide which kind
of challenge this is. The rest of Phase 1 branches on this:

- **Build from spec** (we own the codebase, build a feature): use
  [MISSION.md](MISSION.md) as canonical, ignore
  [CHALLENGE.md](CHALLENGE.md), continue with `/plan` per the per-role
  steps below. This is the default path.
- **Fix problems in 1–6 given repos:** fill out
  [CHALLENGE.md](CHALLENGE.md) instead of MISSION.md. Then for each
  given repo, run `/onboard <path>` (in parallel via worktrees if you
  have 3+ repos). For each problem sourced from a GitHub issue,
  invoke the [issue-triage](.cursor/skills/issue-triage/SKILL.md) skill
  with the issue number. THEN run `/plan` against the consolidated
  picture in CHALLENGE.md.
- **Hybrid** (one repo to extend + side tasks): both files apply.
  CHALLENGE.md tracks the side tasks; MISSION.md captures the headline
  goal.

The Phase 1 stop condition (below) accepts whichever document(s) the
fork required.

### P1 — Planner / Architect / Demo

1. Read the challenge brief end to end without taking notes.
2. Open the repo in Cursor (the workspace auto-loads `.cursor/`).
3. Run `/plan "<paste the challenge brief verbatim>"`. Cursor's `Task`
   tool delegates to the `@planner` subagent (defined in
   [.claude/agents/planner.md](.claude/agents/planner.md)) and produces
   a draft `PLAN.md`.
4. Manually rewrite the four bullets in [AGENTS.md §1](AGENTS.md). Commit
   `MISSION.md`, `AGENTS.md` update, and the draft `PLAN.md` on `main`.
   This is the only direct push to `main` allowed all day.
5. Push to GitHub. Announce on team chat: "MISSION up, start your spikes."

### P2 — Implementer

1. Read the brief.
2. Wait for P1's announcement (do not start coding).
3. Once `MISSION.md` is up, pull, read `PLAN.md`, and pick the highest-
   priority item in your column.
4. Run `/spike <name> "<one-line objective>"` to open a worktree for the
   first feature.

### P3 — Reviewer / Tester

1. Read the brief.
2. While waiting on P1, run `npx playwright install chromium` if not done.
3. Open a tmux session named `qa` with two panes: one for `@test-writer`,
   one for `@bug-hunter`.
4. When `PLAN.md` lands, read it and identify the riskiest module — that's
   where your first tests go.

**Stop condition at 0:20:** `PLAN.md` plus the brief-document
appropriate to the fork (`MISSION.md`, `CHALLENGE.md`, or both for
hybrid) are committed to `main`. If the fork was "given repos," each
repo also has an `ONBOARDING.md` from `/onboard`. If not, P1 announces
a 10-minute extension. No further extensions allowed.

---

## Phase 2 — Build (0:20–3:00)

**Goal:** ship the happy path of the demo win condition. Quality goes in
during Phase 3.

### Pattern of the day: Writer/Reviewer with fresh context

This phase runs an explicit **Writer/Reviewer split** — a high-leverage
quality pattern (separate session, no prior implementation bias) that
we'll articulate to the judges as the reason for the dual-agent role
split.

- **P2 is the Writer.** P2 holds the implementation context, runs
  `@implementer`, opens PRs.
- **P3 is the Reviewer with fresh context.** P3 reads each PR in a
  separate Cursor window or fresh chat (no prior implementation
  context), runs `@reviewer`, and emits `OK_TO_MERGE: yes/no`. A
  second pair of eyes that wasn't biased by the act of writing the
  code.
- **P1 merges.** Only P1 merges, and only after P3's `OK_TO_MERGE:
  yes` is the most recent reviewer comment. P1 may run
  `/pr-checklist <num>` as a cheap deterministic gate before merging.

This is the same pattern as a small-team code-review culture, but
codified into the harness — explicit subagents, explicit slash
commands, explicit verdict format. Easy to pitch.

### P1 — Planner / Architect / Demo

- Watch the PR queue. Review and merge anything from P2 or P3 that has an
  `@reviewer` `OK_TO_MERGE: yes` on it.
- Every 30 minutes, update `PLAN.md` with current status: what's merged,
  what's in flight, what's deferred to `TODO.md`.
- If P2 or P3 are blocked, spawn a `/spike` of your own to unblock them.
- At 2:00 mark, do a "soft demo rehearsal" inside `main` for yourself.
  Identify the three things most likely to break and warn the team.

### P2 — Implementer

- Use `/ship <feature>` for clearly-scoped features. This runs
  `@planner → @implementer → @test-writer → @reviewer → gh pr create`
  sequentially in your session.
- For exploratory features, use `/spike` first, then promote the spike
  branch to a `feat/` PR once viable.
- Never have more than one un-merged PR open from your laptop at a time.
  If a review is taking longer than 10 minutes, ping P1 and switch to
  the next task in a worktree.

### P3 — Reviewer / Tester

- React to every PR within 5 minutes: run `/review`, post the
  `@reviewer` report as a comment, mark `OK_TO_MERGE: yes` or `no`.
- Between reviews, run `@test-writer` on the highest-risk module
  identified in Phase 1.
- At 2:30, run `@bug-hunter` against the staged-but-unmerged code.
  Surface anything that would embarrass the team in the demo.

**Stop condition at 3:00:** the demo win condition runs end-to-end on
`main` in `pnpm dev`. If it doesn't, declare it now, scope it down, and
update `MISSION.md` accordingly.

---

## Phase 3 — Polish (3:00–3:45)

**Goal:** make the happy path look intentional. No new features.

### P1 — Planner / Architect / Demo

- Apply the `100-demo-polish` rule from
  [.cursor/rules/100-demo-polish.mdc](.cursor/rules/100-demo-polish.mdc):
  audit happy-path interactions for missing loading/empty/error states.
- Run `/demo-record` to capture the first take of the Playwright video.
  The browser MCP declared in [.cursor/mcp.json](.cursor/mcp.json) walks
  the happy path; the bundled
  [playwright-recording](.cursor/skills/playwright-recording/SKILL.md)
  skill captures the video and screenshots.

### P2 — Implementer

- Address only blocking bugs P3 surfaces in this phase. Anything
  cosmetic goes to `TODO.md`, not into a PR.
- If asked to leave the code alone, do so. Stand by for demo-recording
  assistance.

### P3 — Reviewer / Tester

- Run a final pass with `@bug-hunter` on the full `main` branch.
- Verify the happy path on a clean clone (use `git worktree add ../verify`
  and run from there) to make sure the demo isn't relying on local-only
  state.

**Stop condition at 3:45:** Playwright recording has at least one
complete take of the happy path. If not, switch to live screen recording
as a fallback (announce in chat).

---

## Phase 4 — Demo prep (3:45–4:30)

**Goal:** ship the demo artifact. Slides, video, README — in that order
of importance.

### P1 — Planner / Architect / Demo

- Run `/demo` to invoke `@demo-builder`. It writes a `DEMO.md` with the
  narration, embeds the recording link, and produces a 3-slide pitch
  outline in `DEMO_SLIDES.md`.
- Rehearse the narration aloud once. Time it. Aim for &lt; 3 minutes.

### P2 — Implementer

- Update repo `README.md` with: one-paragraph description, screenshot,
  how to run locally, what's in the demo video.
- Stand by to fix any tiny copy issue P1 surfaces during rehearsal.

### P3 — Reviewer / Tester

- Open the demo video in a clean browser. Verify audio and resolution.
- Verify `README.md` instructions work on the clean worktree.
- Be ready to swap to a second-take recording if needed.

**Stop condition at 4:30:** `DEMO.md`, `DEMO_SLIDES.md`, README, and the
video are all committed and pushed to `main`.

---

## Phase 5 — Buffer & submit (4:30–5:00)

**Goal:** submission survives all reasonable adversarial conditions.

- Verify `main` is green: clone fresh, `pnpm install`, `pnpm dev`, walk
  the happy path manually. If anything is broken, revert the offending
  commit; do not try to fix.
- Push final tag `v1.0-demo` to lock the submitted state.
- Submit per organizers' instructions. Save submission confirmation.
- Stand down. Watch other teams. Be gracious.

---

## Recovery patterns

### "Cursor rate-limits us mid-session"

1. Affected engineer runs `bash scripts/pi-rescue.sh` from repo root.
2. Pi launches in the same directory; the fallback pack at
   [tools/pi/](tools/pi/) is loaded.
3. Announce in chat: "P2 on Pi for rate-limit." Continue work using the
   prompts in [tools/pi/prompts/](tools/pi/prompts/).
4. Switch back to Cursor when the rate limit clears. The Pi pack stays
   on disk; it does no harm.

### "Hooks are blocking edits"

1. Temporarily move `.cursor/hooks.json` aside (`mv .cursor/hooks.json
   .cursor/hooks.json.off`). Cursor watches the file and disables hooks
   when it's missing.
2. Investigate the hook in [.cursor/hooks/](.cursor/hooks/) after the
   event. Do not fight the hook during the event.

### "Cursor tokens turn out to not be sufficient"

1. The whole team moves to Pi as primary for the remainder of the
   session. The Pi prompts in [tools/pi/prompts/](tools/pi/prompts/)
   mirror the Cursor commands one-for-one.
2. The `.cursor/rules/` content is human-readable and copy-pasteable
   into Pi's system prompt if needed. Total switch time: ~15 minutes.
3. Announce the switch in chat and update `MATRIX.md` to reflect it
   (for the judges — the configuration evolved during the event is
   itself an interesting artifact).

### "GitHub is down"

1. Continue committing locally. Replace `gh pr create` with branch
   pushes to a local bare-repo clone (`git clone --bare main.git
   ../sync.git`) that the team uses as a temporary `origin`.
2. Push to GitHub when it recovers, before submission.

### "P1 gets pulled into a meeting / leaves the room"

1. P2 becomes acting P1 for the duration. Acting P1 has merge authority
   for that period only. Note the handoff in PR comments
   (`@<actual-p1>` ack required when they're back).

---

## Closing reminders

- The hackathon judges look at the **repo** at least as much as the
  **demo**. `AGENTS.md`, `MATRIX.md`, `.cursor/*`, `.claude/agents/*`,
  and PR bodies are all judge-visible artifacts. Treat them like
  product surface.
- The 4-hour cap is sacred. We do not chase perfection past 3:00.
- We win by orchestrating AI, not by writing more code than the next
  team. If you find yourself typing code instead of typing prompts,
  pause and ask why.
