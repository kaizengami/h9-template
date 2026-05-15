---
description: Investigate a symptom and produce ranked hypotheses with evidence. Read-only — no fixes. Mirrors the @bug-hunter subagent in Claude Code.
---

Investigate the reported symptom.

**Arguments:** $@

## Establish the symptom

Before investigating, confirm:

- Expected behavior: <what should happen>
- Observed behavior: <what's happening>
- Reproducible: yes or no (with steps if yes)
- First noticed: <commit, time, or moment>

If the user is vague, ask **one** clarifying question and stop until
answered. Do not investigate phantoms.

## Investigate

1. Reproduce the symptom locally. Use `pnpm dev` and walk the failing
   flow manually, or run a specific failing test
   (`pnpm test <pattern>`).
2. Bisect using `git log --since='30 minutes ago' --oneline` —
   most hackathon bugs were introduced in the last few commits.
3. Read the suspect code in full (not just diff hunks).
4. Run targeted commands as evidence: `pnpm test <module>`,
   `node -e '<one-liner>'`, `grep -rn <pattern>`.

## Report format

```markdown
# Investigation — <symptom>

## Symptom
- Expected: <…>
- Observed: <…>
- Reproducible: yes/no (steps if yes)
- First noticed: <commit or moment>

## Hypotheses (ranked by likelihood)

### H1 (likely) — <one-line title>
- Evidence: <…> at `path:line`
- Counter-evidence: <…>
- Proposed fix: <one line — for the human to execute>

### H2 (possible) — <…>
- Evidence: <…>

### H3 (unlikely but worth a check) — <…>
- <…>

## Recommended next step
<one sentence directing the next person to act>
```

## Rules

- **No edits.** You investigate only. If you have an obvious fix,
  hand it to the user via the "Proposed fix" field.
- **Evidence per hypothesis.** Every hypothesis cites at least one
  `path:line` location. Speculation without evidence goes in
  "Notes" if at all.
- **Rank honestly.** "Likely" = >60% confidence. "Possible" = 20–60%.
  "Unlikely" = <20%. Don't pad the list.
- **Stop after 15 minutes.** If no hypothesis with evidence emerges,
  surface what you have, name the blocker, hand back to the user.
