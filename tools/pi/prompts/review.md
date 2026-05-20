---
description: Read-only review of a diff or PR against AGENTS.md Definition of Done. Mirrors the @reviewer subagent run from the Cursor primary.
---

Review the target diff and produce a structured report.

**Arguments:** $@

## Target resolution

- If $1 looks like a number (e.g. `42`): treat as PR `#42`. Run
  `gh pr diff $1` and `gh pr view $1`.
- If $1 looks like a branch name (matches `git branch --list $1`):
  treat as a branch. Run `git diff main...$1`.
- If $@ is empty: review the current working tree. Run `git diff` and
  `git diff --cached`. If both empty, fall back to
  `git diff main...HEAD`.

## What to read

1. `AGENTS.md` §5 (Definition of Done).
2. The full files of anything you intend to flag (not just diff hunks).
3. Recent commits via `git log --oneline -10` for context on
   what the team is doing now.

## Report format

```markdown
# Review — <branch or PR title>

## Bugs
- <one line per bug with `path:line` citation, or "none observed">

## Risks
- <production-grade concerns: race conditions, security, data loss, …>

## Missing tests
- <what's not covered that should be>

## Convention violations
- <violations of AGENTS.md §2 (stack) or §4 (workflow) with citations>

## Notes
- <noteworthy items that aren't blockers>

OK_TO_MERGE: <yes|no>
```

## Rules

- **Read-only.** Never edit. Never push, merge, or comment on the PR
  via `gh`. Output the report to stdout only.
- **Cite with `path:line`.** No vague findings.
- **Hackathon-mode bar.** Acceptable: deferred polish, small TODOs.
  Unacceptable: bugs that break the demo, exposed secrets, failing
  typecheck.
- **Refuse to review your own work.** If `git log` shows the current
  user as the sole author, decline.
