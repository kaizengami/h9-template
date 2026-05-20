---
description: Full plan-implement-test-review-PR cycle for a single small feature. Sequential because subagents cannot spawn subagents. Use for features estimated <= 30 minutes.
argument-hint: "<feature description, one sentence>"
---

Execute the full ship cycle for one small feature.

**Feature:** $ARGUMENTS

Run these five steps in order. Pause for a one-word user confirmation
between steps 2 and 3, and between steps 4 and 5. The user types
"continue" to proceed, "stop" to abort, or "fix: <…>" to redirect.

### Step 1 — Plan

Invoke `@planner`: add this feature to `PLAN.md` as a "Now" entry with
the current branch as the destination. If the current branch is `main`,
create `feat/<slug>` first.

### Step 2 — Confirmation gate (user types continue/stop/fix)

Print the planned change summary and ask:

```
Plan ready. Continue with implementation? (continue / stop / fix: <…>)
```

### Step 3 — Implement

Invoke `@implementer` with the planned feature. The subagent edits,
runs typecheck, and commits. Do **not** open a PR yet.

### Step 4 — Test

Invoke `@test-writer` to add tests for the change. The subagent commits
on the same branch.

### Step 5 — Confirmation gate (user types continue/stop/fix)

Run `@reviewer` on the staged work (no PR yet). Print the report.

If the report is `OK_TO_MERGE: no`, stop here and ask the user:

```
Reviewer found issues. continue (open PR anyway) / stop / fix: <…>
```

If `OK_TO_MERGE: yes`, ask:

```
Review clean. Open PR? (continue / stop)
```

### Step 6 — Open PR

Run `gh pr create` with:

- Title: derived from the feature description
- Body: includes the one-sentence feature description, the
  reviewer report, and the Definition of Done checklist from
  [AGENTS.md §5](../../AGENTS.md).

Print the PR URL.

## Notes

Subagents cannot spawn other subagents (Cursor's Task tool, like Claude
Code's, is one level deep). This command runs in the main thread,
invoking each subagent in sequence via `@<name>` mentions. If a
subagent needs to delegate further, it must return to this command,
which delegates the next step.
