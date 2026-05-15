---
description: Update PLAN.md from the challenge brief or current progress. Delegates to @planner. Use at start of work and after each major merge.
argument-hint: "[task description, or challenge brief, or blank to refresh]"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git log:*), Bash(gh pr list:*)
---

Invoke `@planner` with the arguments below. If no arguments are given, treat
this as a refresh: re-read `PLAN.md`, check `gh pr list --state open`, move
merged items to Done, and re-prioritize Next.

**Arguments:** $ARGUMENTS

Read [AGENTS.md](../../AGENTS.md) §1–§3 first to understand the team's
current Mission, stack, and role assignments. Then produce or update
`PLAN.md` per the format defined in
[.claude/agents/planner.md](.claude/agents/planner.md).

After updating, print a one-line summary to chat:

```
PLAN updated: N in flight, M queued, K done.
```

Do not open a PR for plan changes — `PLAN.md` is updated on the working
branch and committed alongside whatever task drove the update.
