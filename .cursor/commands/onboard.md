---
description: Probe an unfamiliar repo and produce ONBOARDING.md. Run FIRST when the challenge gives you an existing repo to fix or extend. Delegates to the onboard-repo skill.
argument-hint: "<repo path or .>"
---

Invoke the [onboard-repo](../skills/onboard-repo/SKILL.md) skill on
the path below.

**Arguments:** $ARGUMENTS (defaults to `.` if empty)

The skill will:
1. Run the bundled `scripts/probe.sh` to detect language, framework,
   package manager, test runner, and hot files.
2. Read any existing `AGENTS.md`/`CLAUDE.md`/README.
3. Synthesize a brief at `<repo-root>/ONBOARDING.md` (under 80 lines).

After the skill completes, read the resulting `ONBOARDING.md` and
print a 5-line summary to chat:

```
Onboarded: <repo-name>
Language: <…>
Test command: <…>
Hot file #1: <path>
Suggested next: <…>
```

If `ONBOARDING.md` already exists, the skill will overwrite it after
asking for confirmation. If the user declines, append a "## Re-probe
findings <ISO>" section instead of replacing.

Do not commit `ONBOARDING.md` from this command — it's the calling
session's decision whether onboarding output goes into the repo or
stays local. (Hint: if the repo is the team's own working repo,
commit it. If the repo belongs to the challenge organizers and
should stay clean, gitignore `ONBOARDING.md` first.)
