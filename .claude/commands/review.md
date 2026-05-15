---
description: Review a diff against AGENTS.md Definition of Done. Delegates to @reviewer, who produces a read-only OK_TO_MERGE report. Use before opening any PR and on every PR you didn't author.
argument-hint: "[PR number, branch name, or blank for current diff]"
allowed-tools: Read, Glob, Grep, Bash(git:*), Bash(gh:*), Bash(rg:*)
---

Invoke `@reviewer` on the target.

**Arguments:** $ARGUMENTS

Target resolution:

- If `$ARGUMENTS` is a number (e.g. `42`): treat as PR `#42`. Run
  `gh pr diff 42` to get the diff and `gh pr view 42` to read the title
  and description.
- If `$ARGUMENTS` is a string matching a branch (`git branch --list
  "$ARGUMENTS"`): treat as a branch. Run `git diff main...$ARGUMENTS`.
- If `$ARGUMENTS` is blank: review the current working diff. Run both
  `git diff` and `git diff --cached`. If both are empty, fall back to
  `git diff main...HEAD` for the current branch.

After the diff is gathered, hand control to `@reviewer`.

When the reviewer returns:

1. If reviewing a PR: post the report as a PR comment via
   `gh pr comment $PR_NUM --body-file <(echo "$REPORT")`.
2. If reviewing a branch or working diff: print the report inline.
3. In either case, print the verdict on a single line at the end:

   ```
   OK_TO_MERGE: yes
   ```

   or

   ```
   OK_TO_MERGE: no — see report.
   ```
