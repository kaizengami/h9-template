---
description: Add Vitest and Playwright tests for new or changed code. Delegates to @test-writer. Use after every non-trivial @implementer run.
argument-hint: "[file path, feature name, or blank to scan current diff]"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(pnpm:*), Bash(npx:*), Bash(vitest:*), Bash(playwright:*), Bash(git:*)
---

Invoke `@test-writer` to add tests.

**Arguments:** $ARGUMENTS

Target resolution:

- If `$ARGUMENTS` names a file or module path: test that target.
- If `$ARGUMENTS` is "demo path" or "happy path": test the demo flow
  with a Playwright spec tagged `@demo`.
- If `$ARGUMENTS` is blank: run `git diff main...HEAD --name-only`,
  identify changed files, and add tests for any untested changes.

`@test-writer` will write tests, run them, and commit on the current
branch.

After completion, print:

```
Tests added: <list of new test files>
Status: <all passing | N failing — see output above>
```

If tests are failing and `@test-writer` could not identify why, escalate
to `@bug-hunter` with a one-line note.
