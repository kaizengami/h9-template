---
description: Add Vitest unit tests and Playwright E2E tests for changed code. Mirrors the @test-writer subagent run from the Cursor primary.
---

Add tests for the target.

**Arguments:** $@

## Target resolution

- If $1 names a file or module path: test that target.
- If $@ contains "demo path" or "happy path": write a Playwright spec
  tagged `@demo` covering the demo happy path from `DEMO.md` (or
  `MISSION.md` if `DEMO.md` doesn't exist).
- If $@ is empty: run `git diff main...HEAD --name-only`, identify
  changed files, and add tests for any untested changes.

## Procedure

1. Read existing tests for the same module/flow to match conventions.
2. Place tests in:
   - `tests/unit/<module>.test.ts` for Vitest unit tests.
   - `tests/e2e/<flow>.spec.ts` for Playwright E2E.
3. Write **two** test cases minimum: one happy path, one realistic
   failure mode.
4. Run `pnpm test` (or `pnpm vitest run` / `pnpm playwright test`)
   and verify they pass.
5. If they fail, fix the test (not the product), unless you find a
   real bug — in which case stop and instruct the user to run
   `/bug-hunt` instead.
6. Stage the changes with `git add` and commit with
   `test(<scope>): add <coverage>`. Do **not** open a PR; the user
   does that manually back in Cursor (via `/ship` or the standard
   PR flow) when the rate limit clears or the parallel work
   completes.

## Rules

- **Two tests per change, not ten.** Prove it works once, prove it
  fails gracefully once.
- **Real assertions only.** No `expect(true).toBe(true)` placeholders.
- **No network.** Stub external APIs with `vi.spyOn` or msw.
- **Tag demo path tests.** Tests covering the demo happy path get the
  `@demo` tag so `/bug-hunt` can prioritize them.
