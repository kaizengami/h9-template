---
description: Squash-merge a PR after verifying all merge gates. P1-only operation. Other engineers should ask P1 to run this rather than running it themselves.
argument-hint: "<PR number>"
---

Merge a PR to `main` after verifying all gates.

**Arguments:** $ARGUMENTS

This command is P1-only per [AGENTS.md §4.3](../../AGENTS.md). If you
are not P1, stop here and ask P1 to merge.

### Pre-merge gates

Run these checks in order. Any failure aborts the merge.

1. PR exists and is open:
   ```bash
   gh pr view $1 --json state,mergeable,reviewDecision
   ```
   Require: `state == "OPEN"`, `mergeable == "MERGEABLE"`.

2. Reviewer report attached and clean. Search the PR comments for the
   most recent `OK_TO_MERGE:` line. Require `OK_TO_MERGE: yes`.

3. CI is green if `.github/workflows/` exists. Run:
   ```bash
   gh pr checks $1
   ```
   Require: all checks `pass` or absent (Phase 1 has no CI, so this is
   allowed to return nothing).

4. PR body contains the Definition of Done checklist
   ([AGENTS.md §5](../../AGENTS.md)). Require all boxes checked.

5. No new files under `.env`, `secrets/`, or other secret paths. Run:
   ```bash
   gh pr diff $1 --name-only | grep -E '^\.env|^secrets/'
   ```
   Require: no output.

### Merge

If all gates pass:

```bash
gh pr merge $1 --squash --delete-branch
```

Then:

```bash
git switch main
git pull --ff-only
```

### Post-merge

1. Update `PLAN.md`: move the corresponding "Now" item to "Done" with
   the merge commit SHA. Commit on `main` with message
   `chore(plan): mark #$1 as merged`.
2. Print:
   ```
   Merged #$1 to main. PLAN.md updated.
   ```

### If any gate fails

Print exactly what failed and refuse to merge. Do not "force" anything.
The PR author addresses the gate failure and re-runs `@reviewer` to
re-issue `OK_TO_MERGE: yes`.
