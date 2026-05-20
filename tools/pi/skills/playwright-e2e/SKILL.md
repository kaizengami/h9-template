---
name: playwright-e2e
description: Generate Playwright end-to-end tests for the hack9 app. Use when adding or fixing tests/e2e/*.spec.ts files, recording demo videos, or verifying user flows in a headed browser. Reads the existing tests/e2e/ patterns before writing new specs.
---

# Playwright E2E

This skill generates Playwright specs that match the team's
conventions. It is loaded on demand when a Pi session needs to write
or fix end-to-end tests.

## Setup (one time per machine)

```bash
pnpm add -D @playwright/test
npx playwright install chromium
```

Verify `playwright.config.ts` exists at the repo root. If not, scaffold
the minimal version:

```ts
import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./tests/e2e",
  use: {
    baseURL: process.env.E2E_BASE_URL || "http://localhost:3000",
    trace: "on-first-retry",
    video: "retain-on-failure",
  },
});
```

## Conventions

- Test files end in `.spec.ts` (not `.test.ts` — that's reserved for
  Vitest).
- Each spec covers one user-visible flow. Name files after the flow,
  not the page: `tests/e2e/upload-csv.spec.ts`, not
  `tests/e2e/page.spec.ts`.
- Tests tagged `@demo` cover the demo happy path. Run them in
  isolation with `npx playwright test --grep @demo`.

## Spec template

```ts
import { test, expect } from "@playwright/test";

test.describe("upload CSV @demo", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/");
  });

  test("happy path: user uploads a valid CSV and sees a summary", async ({ page }) => {
    await page.getByRole("button", { name: /upload csv/i }).click();
    await page.setInputFiles('input[type="file"]', "tests/fixtures/sample.csv");
    await expect(page.getByText(/summary/i)).toBeVisible();
  });

  test("error path: invalid CSV shows inline error", async ({ page }) => {
    await page.getByRole("button", { name: /upload csv/i }).click();
    await page.setInputFiles('input[type="file"]', "tests/fixtures/invalid.csv");
    await expect(page.getByText(/could not parse/i)).toBeVisible();
  });
});
```

## Selectors

- Prefer `getByRole`, `getByLabel`, `getByText` — accessibility-first.
- Avoid CSS selectors except for file inputs and other unlabelable
  controls.
- Never use `nth-child` or absolute selectors — they break on UI
  polish.

## Demo recording

To record the demo happy path:

```bash
npx playwright test --grep @demo --headed --workers=1
```

The video lands in `test-results/<spec>/video.webm`. Move it to the
repo root as `demo.webm` and reference it in `DEMO.md`.

## Don't

- Don't add visual regression tests in Phase 1. They're flaky and
  slow.
- Don't depend on test ordering. Each spec is independent.
- Don't reach into the database directly to set up state. Use the
  app's own seed scripts or fixture files.
