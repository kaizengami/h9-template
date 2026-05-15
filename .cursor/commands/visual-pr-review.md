# /visual-pr-review — visually verify a UI PR via browser MCP

Use during Phase 2 (build) for any PR that changes UI. Cursor's
`cursor-ide-browser` MCP loads the dev server, navigates the changed
flow, and verifies visual expectations. This is a complement to
[`@reviewer`](mdc:.claude/agents/reviewer.md) in Claude Code, not a
replacement.

## Pre-flight

1. The PR is open and the branch is checked out locally (or available
   as a worktree).
2. `pnpm dev` is running on the local machine.
3. The browser MCP is reachable (it's the built-in Cursor browser).

## Steps

1. Read the PR description and the diff. Identify the UI surface
   changed (route path, component name, or flow description).
2. Open the browser MCP and navigate to the affected route.
3. Walk the happy path of the changed flow:
   - Click through to the changed component
   - Take a screenshot at each meaningful state
   - Toggle viewport between `sm`, `md`, `lg` if the change is
     responsive
4. Compare against the
   [020-shadcn-ui rule](mdc:.cursor/rules/020-shadcn-ui.mdc) checklist:
   - Loading, empty, error, success states all present?
   - Focus rings visible on interactive elements?
   - No console errors during interaction?
   - Layout stable on data load (no shift)?

5. Post screenshots to the PR via:

   ```bash
   gh pr comment <PR#> --body "<screenshots and findings>"
   ```

6. Decide:
   - All good: post `Visual review OK` as a comment. Approve the PR
     for merge.
   - Issues found: list each with a screenshot and a one-line ask.
     Do not block on cosmetic items per the
     [hackathon-mode rule](mdc:.cursor/rules/000-core.mdc); defer
     those to `TODO.md`.

## Don't

- Don't run `@reviewer` from here — that's a Claude Code subagent.
  This command is the visual complement to a reviewer report.
- Don't edit the code from this command. If a tiny fix is obvious,
  add a one-line PR comment with the suggestion; the PR author
  applies it.
