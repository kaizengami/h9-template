---
description: Review a diff against AGENTS.md Definition of Done. Delegates to @reviewer, who produces a read-only OK_TO_MERGE report. Use before opening any PR and on every PR you didn't author.
argument-hint: "[PR number, branch name, or blank for current diff]"
---

Invoke `@reviewer` on the target.

**Arguments:** $ARGUMENTS

Target resolution:

- If `$ARGUMENTS` is a number (e.g. `42`): treat as PR/MR `#42`. Run
  `bash scripts/vcs-helper.sh pr-diff 42` to get the diff and `bash scripts/vcs-helper.sh pr-view 42` to read the title
  and description.
- If `$ARGUMENTS` is a string matching a branch (`git branch --list
  "$ARGUMENTS"`): treat as a branch. Run `git diff main...$ARGUMENTS`.
- If `$ARGUMENTS` is blank: review the current working diff. Run both
  `git diff` and `git diff --cached`. If both are empty, fall back to
  `git diff main...HEAD` for the current branch.

After the diff is gathered, hand control to `@reviewer`.

When the reviewer returns:

1. If reviewing a PR/MR: post the report as a comment via
   `bash scripts/vcs-helper.sh pr-comment $PR_NUM <report-file>`.
2. If reviewing a branch or working diff: print the report inline.
3. In either case, print the verdict on a single line at the end:

   ```
   OK_TO_MERGE: yes
   ```

   or

   ```
   OK_TO_MERGE: no — see report.
   ```
