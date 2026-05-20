---
name: reproduce-bug
description: Write a minimal failing test that reproduces a reported bug. Run it, confirm it fails, then hand off to @bug-hunter. Use when given a bug to fix in any repo. Supports TypeScript (vitest, jest, playwright) and Python (pytest).
---

# reproduce-bug

Repro-first methodology, codified. A confirmed-failing test is the
cheapest way to know when the bug is fixed. This skill writes that
test before anyone touches the production code.

The deliverable is a single failing test on a `repro/<bug-slug>`
branch, plus a clean handoff to `@bug-hunter` for the actual
investigation.

## When to use

- Right after `/onboard` lands ONBOARDING.md for a given repo.
- When `@bug-hunter` is requested and no failing test exists.
- When a GitHub issue contains a stack trace or "expected vs. actual"
  description.

## When NOT to use

- The bug is purely visual ("the button is teal, should be navy") —
  go straight to `@implementer`. Visual regressions need a screenshot
  diff, not a test.
- The bug repro requires manual user interaction that can't be
  scripted (rare; Playwright covers most cases).
- You don't have read access to the source — say so and stop.

## How to invoke

```text
/repro user can't log in after password reset
```

```text
/repro #42
```

```text
/repro TypeError: Cannot read property 'foo' of undefined at line 47 of auth.ts
```

## Procedure

1. **Read ONBOARDING.md** at the repo root. If absent, refuse with
   "run `/onboard .` first" — without it you don't know which test
   runner to use.
2. **Resolve the bug source.**
   - If `$ARGUMENTS` looks like an issue number (`#N` or just `N`),
     fetch with `gh issue view N --json title,body,comments`.
   - If it's a stack trace, parse the file:line.
   - Otherwise treat `$ARGUMENTS` as a free-form description.
3. **Identify the test runner** from ONBOARDING.md "Suggested
   commands" section. Cross-check by listing existing tests:
   - TypeScript: `Glob` for `**/*.test.ts`, `**/*.spec.ts`,
     `tests/**/*.ts`
   - Python: `Glob` for `tests/**/*.py`, `**/test_*.py`,
     `**/*_test.py`
4. **Find the most relevant existing test** that touches the same
   module. Read it to copy the team's testing style (imports,
   fixtures, naming). Cite as `path:line` in the new test.
5. **Create a `repro/<slug>` branch** with `git checkout -b
   repro/<slug>`. Slug is a kebab-case summary, e.g.
   `repro/login-after-password-reset` or `repro/issue-42`.
6. **Write the failing test** in the project's existing test
   directory. Conventions:
   - Name the test exactly after the bug, e.g.
     `it("rejects login when password reset token is reused", ...)`.
   - Test ONLY the failing behavior. No incidental setup, no extra
     assertions. Minimum reproducer.
   - Add a header comment linking to the bug source:
     `// repro for #42 — written by /repro on 2026-05-22`.
7. **Run the test** and **confirm it fails**.
   - If it passes: the repro is wrong. Iterate up to two times. If
     still passing after two attempts, output `INCOMPLETE: cannot
     reproduce — the bug as described does not manifest in our
     environment.` Do not commit.
   - If it errors at compile/import time: that's still a failure
     mode; capture the error output.
8. **Capture the failure trace** (first 30 lines of test output).
9. **Commit on the `repro/<slug>` branch** with this exact message
   format:
   ```
   test(repro): failing test for <one-line bug summary>

   repro for: <bug source — issue#, stack trace summary, or description>
   verify: <test runner command> — failing as expected

   <first 10 lines of failure output>
   ```
10. **Hand off** with this exact format:
    ```
    Repro committed on branch `repro/<slug>` (test in <path>).
    Verified failing: <one-line failure summary>

    Now invoke `@bug-hunter` to investigate. The fix should:
    - Make the new test pass
    - Not break any existing tests in <related test path>
    ```

## Test framework conventions

### TypeScript / vitest
```ts
import { describe, it, expect } from "vitest";
import { resetPassword, login } from "@/lib/auth"; // adjust import

describe("repro for #42 — login after password reset", () => {
  it("rejects login when reset token is reused", async () => {
    const token = await resetPassword("user@example.com");
    await login("user@example.com", "newpw", token);
    // second use should fail:
    await expect(login("user@example.com", "newpw", token))
      .rejects.toThrow(/token already used/);
  });
});
```

### TypeScript / jest
Same shape, but `import { describe, it, expect } from "@jest/globals"`
or rely on Jest's globals.

### TypeScript / Playwright
```ts
import { test, expect } from "@playwright/test";

test("repro #42: login after password reset", async ({ page }) => {
  await page.goto("/login");
  await page.fill('[name=email]', "user@example.com");
  // ...minimum interaction that reproduces the bug
  await expect(page.getByText(/error/i)).toBeVisible();
});
```

### Python / pytest
```python
"""repro for #42 — login after password reset"""
import pytest
from app.auth import reset_password, login


def test_login_rejects_reused_reset_token():
    token = reset_password("user@example.com")
    login("user@example.com", "newpw", token)
    with pytest.raises(ValueError, match="token already used"):
        login("user@example.com", "newpw", token)
```

## Rules

1. **One test per invocation.** Don't bundle multiple bugs into one
   `/repro` call. Multiple bugs = multiple branches.
2. **Never modify production code from this skill.** That's
   `@implementer`'s job after `@bug-hunter` produces a hypothesis.
3. **Never skip step 7 (confirm failure).** A "looks like it should
   fail" test is worse than no test — it gives false confidence to
   the fixer.
4. **Cite the failure trace.** The first 10 lines of output go in the
   commit body. This is the verification trace per
   [implementer.md](../../../.claude/agents/implementer.md) rule G1.
5. **If you can't repro, stop honestly.** `INCOMPLETE: cannot
   reproduce` is a useful answer; a fake-passing test is not.

## Don't

- Don't propose fixes. That's a separate session.
- Don't cleanup unrelated test code while you're in there. Stay
  surgical.
- Don't run the full test suite — only the new test. Full-suite runs
  in a 4-hour event waste 30+ seconds per call.
