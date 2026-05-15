---
description: Produce the demo artifact — DEMO.md narration, Playwright recording, DEMO_SLIDES.md pitch. Delegates to @demo-builder. Use only in Phase 4 (3:45+).
argument-hint: "[blank for full demo, or 'rerecord <section>', or 'polish narration']"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(playwright:*), Bash(npx:*), Bash(pnpm:*)
---

Invoke `@demo-builder` to produce the demo artifact.

**Arguments:** $ARGUMENTS

Pre-flight checks before delegating:

1. Verify it is Phase 4 (elapsed time ≥ 3:45). If unsure, ask the user
   to confirm we are out of Phase 2 (build) and Phase 3 (polish). The
   feature freeze must be in effect. If not, refuse and tell the user
   to run `/demo` later.
2. Verify `MISSION.md` exists and the happy path works (`pnpm dev` then
   walk it manually). If broken, refuse and route to `@bug-hunter`.
3. Verify Playwright is installed: `npx playwright --version` succeeds.
   If not, run `npx playwright install chromium`.

Then delegate to `@demo-builder` with the arguments. The subagent
produces:

- `DEMO.md` — narration script
- `DEMO_SLIDES.md` — three-slide pitch
- `demo.webm` — Playwright recording at repo root
- `docs/screenshots/*.png` — key moments

Commit all artifacts on the current branch with message:

```
docs(demo): add demo recording, narration, and slides
```

Print the final checklist:

```
Demo ready. Verify before submission:
[ ] demo.webm plays with audio
[ ] DEMO.md narration matches recording
[ ] DEMO_SLIDES.md references MATRIX.md
[ ] README.md links to demo.webm
[ ] Happy path passes on a clean clone
```
