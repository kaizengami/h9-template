---
description: Write a minimal failing test that reproduces a bug. Run it, confirm it fails, then hand off to @bug-hunter. Delegates to the reproduce-bug skill.
argument-hint: "<bug description, issue#, or stack trace>"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(pnpm:*), Bash(npm:*), Bash(npx:*), Bash(pytest:*), Bash(python:*), Bash(python3:*), Bash(uv:*), Bash(poetry:*), Bash(git:*), Bash(gh:*)
---

Invoke the [reproduce-bug](../skills/reproduce-bug/SKILL.md) skill on
the bug below.

**Arguments:** $ARGUMENTS

The skill will:
1. Read `ONBOARDING.md` to identify the test runner (run `/onboard
   .` first if it doesn't exist).
2. Resolve the bug source — issue number (`gh issue view`), stack
   trace, or free-form description.
3. Create a `repro/<slug>` branch.
4. Write a single minimal failing test in the project's existing test
   directory.
5. Run the test and confirm it fails (the verification trace per
   [implementer.md](../agents/implementer.md) Rule G1).
6. Commit on the `repro/<slug>` branch with the failure trace in the
   commit body.

After the skill completes, print this exact handoff line to chat:

```
Repro on `repro/<slug>` — failing test in <path>. Now invoke `@bug-hunter`.
```

If the bug cannot be reproduced after two attempts, the skill will
return `INCOMPLETE`. In that case, do NOT commit; print the
investigation summary and let the user decide whether to:
- Re-read the bug source for missing context, or
- Switch to `@bug-hunter` with the original symptom (no repro), or
- Skip the bug and document it in `CHALLENGE.md` as "blocked: cannot
  reproduce".

Do not invoke `@bug-hunter` directly from this command — the human
decides whether to proceed based on the repro outcome.
