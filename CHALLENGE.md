# CHALLENGE.md

> Filled in by P1 during Phase 1 (0:00–0:20) when the challenge involves
> existing repositories rather than building from spec. Replaces (or
> complements) [MISSION.md](MISSION.md). Keep it short and live — this
> is the team's shared situation board for the day.
>
> If the challenge is "build from spec," ignore this file and use
> MISSION.md instead. See [PLAYBOOK.md](PLAYBOOK.md) Phase 1 for the fork.

## Challenge type

- [ ] Build from spec → use MISSION.md instead
- [ ] Fix problems in 1–6 given repos → continue here
- [ ] Hybrid (one repo to extend + sub-tasks) → continue here, note hybrid

## Repos given to us

| Slug | URL or path | Language | What it does (one line) | Onboarded? |
| --- | --- | --- | --- | --- |
| repo-a | https://github.com/org/a | TS / Next.js | … | [ ] |
| repo-b | https://github.com/org/b | Python / FastAPI | … | [ ] |

For each repo, run `/onboard <path>` to populate the
`<repo>/ONBOARDING.md` brief, then check the box above.

## Problems to solve (1–6)

| # | Repo | Symptom | Source | Owner | Status |
| --- | --- | --- | --- | --- | --- |
| 1 | repo-a | "<one-line user-visible symptom>" | issue#42 | P2 | not started |
| 2 | repo-a | "<…>" | failing test `t/foo.test.ts:23` | P3 | not started |
| 3 | repo-b | "<…>" | spec section 4.2 | P2 | not started |

**Status values:** `not started`, `triaged`, `repro on <branch>`,
`bug-hunter on it`, `fix in PR#N`, `merged`, `blocked: <reason>`,
`deferred`.

## Constraints

- **Time per problem:** ~<minutes> on average. Hard cap at <minutes>;
  beyond that, escalate or defer.
- **Read-only paths:** any file or directory the challenge says we
  must not modify (e.g. test fixtures, generated code, vendor dirs).
- **Must-keep tests:** any pre-existing test that must remain green
  after our changes. List exact paths.
- **Forbidden changes:** package versions? framework upgrades?
  changes outside `src/`? List explicitly so the team doesn't trip.
- **Submission format:** PRs against `main`? A patch file? A
  single commit? Whatever the organizers asked for.

## Order of attack

Ranked by `(team value) / (estimated time)`. Highest ratio first.

1. **#<N> in <repo>** — fastest win, sets up momentum
2. **#<N> in <repo>** — high judge-visible impact
3. **#<N> in <repo>** — needed for the demo path
4. **#<N> in <repo>** — defensive (avoids embarrassment)
5. (deferred items go below or to TODO.md)

## Definition of done (per problem)

For each problem, "done" means **all** of:

- [ ] A failing test exists that reproduced the bug (committed on
      `repro/<slug>`)
- [ ] The fix makes that test pass
- [ ] No previously-passing test now fails
- [ ] PR is open with: one-sentence "what + why", the verification
      trace from [implementer.md](.claude/agents/implementer.md) Rule
      G1, and `OK_TO_MERGE: yes` from `@reviewer`
- [ ] PR is merged into the target repo's `main` (or whatever the
      challenge's submission format requires)

If a problem completes without a failing test (e.g. a feature add,
not a bug), substitute "a Playwright/Vitest/pytest test that asserts
the new behavior" for the first checkbox.

## Live status board

Updated by P1 every 30 minutes. Free-form notes here, not a table —
the table above is the canonical state.

```
T+0:30
- repo-a: P2 onboarded, repro for #42 written, failing as expected
- repo-b: P3 onboarded, issue-triage for #17 produced ambiguous repro;
  P3 asking author for clarification; meanwhile starting #18.
```

## Risks and unknowns

- **Risk:** the challenge submission format wasn't fully clear from
  the brief. P1 to clarify with organizers in the first 10 minutes.
- **Unknown:** which repo has the demo-worthy problem. Soft-decide by
  T+1:00 so P1 can start drafting `DEMO.md` early.

## Notes for the demo

If the challenge has 1-6 problems, the team can't demo all of them.
Pick the **two** with the strongest narrative for `DEMO.md`:

- One that shows clear before/after (a bug fix with a screenshot or
  test diff).
- One that shows the team's process (PR with verification trace +
  reviewer approval — judge-visible artifact).

Reference the rest in `DEMO_SLIDES.md` as "we also fixed N more
problems, see PRs #X #Y #Z."
