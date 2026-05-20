---
name: playwright-recording
description: Record the demo happy-path as a Playwright video with screenshots. Use when producing the demo artifact in Phase 4, when capturing screenshots for a PR, or when re-recording a demo segment after a fix.
---

# Playwright recording

Procedural skill for capturing demo videos and screenshots using
Playwright. Bundled with a `scripts/record.sh` wrapper that runs the
recording with the hackathon team's standard flags.

## When to use

- **Phase 4 demo prep** (3:45–4:30 elapsed per
  [PLAYBOOK.md](../../../PLAYBOOK.md)). P1 owns the recording session.
- **PR screenshots** for UI changes. Per
  [AGENTS.md §5](../../../AGENTS.md) Definition of Done, every UI PR
  needs a screenshot.
- **Re-recording a segment** after a bug fix during demo prep.

## Prerequisites (one-time, on each laptop)

```bash
pnpm add -D @playwright/test
npx playwright install chromium
```

A minimal [playwright.config.ts](../../../playwright.config.ts) must
exist at the repo root. If not, create it:

```ts
import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests/e2e",
  use: {
    baseURL: process.env.E2E_BASE_URL || "http://localhost:3000",
    trace: "on-first-retry",
    video: "on",
    screenshot: "only-on-failure",
  },
  reporter: "line",
});
```

## How to tag a test for recording

Tests tagged `@demo` are picked up by the bundled script.

```ts
import { test, expect } from "@playwright/test";

test.describe("happy path @demo", () => {
  test("user uploads a CSV and sees a summary", async ({ page }) => {
    await page.goto("/");
    await page.getByRole("button", { name: /upload/i }).click();
    await page.setInputFiles('input[type="file"]', "tests/fixtures/sample.csv");
    await expect(page.getByText(/summary/i)).toBeVisible();
    await page.screenshot({ path: "docs/screenshots/02-summary.png" });
  });
});
```

## Running the recording

```bash
bash .cursor/skills/playwright-recording/scripts/record.sh
```

The bundled script:

1. Ensures `pnpm dev` is reachable on `http://localhost:3000` (waits
   up to 30 seconds).
2. Runs `npx playwright test --grep @demo --headed --workers=1
   --reporter=line` so the take is reproducible.
3. Moves the resulting `test-results/<spec>/video.webm` to
   `demo.webm` at the repo root.
4. Copies any screenshots taken during the run from `docs/screenshots/`
   into a verification report path.

## After recording

- Open `demo.webm` in a media player. Verify:
  - The full happy path is captured end to end.
  - No console errors flashed (check `test-results/<spec>/trace.zip`
    if uncertain).
  - Resolution is at least 1280×800.
  - Total duration is under 3 minutes.
- Commit with: `docs(demo): add demo recording and screenshots`.
- Reference `demo.webm` in [DEMO.md](../../../DEMO.md) and the repo
  [README.md](../../../README.md).

## Failover

If Playwright recording fails twice (e.g. headed mode unavailable on
a sandboxed machine):

1. Switch to QuickTime screen recording. Announce in team chat.
2. Record at 1080p, 30fps, system audio on.
3. Save as `demo.mov`, then convert:
   ```bash
   ffmpeg -i demo.mov -c:v libx264 -crf 22 demo.mp4
   ```
4. Update [DEMO.md](../../../DEMO.md) to reference `demo.mp4` instead
   of `demo.webm`.

## Don't

- Don't record manually with QuickTime as the first take — Playwright
  produces more consistent results and lets you re-run on a fix.
- Don't add the `--debug` flag during demo recording — it pauses on
  every step.
- Don't commit `test-results/` — it's gitignored. Only commit the
  final `demo.webm` and the `docs/screenshots/*.png` you want in the
  PR.
