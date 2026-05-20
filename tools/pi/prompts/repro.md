---
description: Write a minimal failing test that reproduces a bug, run it, confirm it fails, then commit on a repro/ branch. Mirrors the reproduce-bug skill in the Cursor primary.
---

Write a single minimal failing test that reproduces the bug.

**Arguments:** $@ (bug description, GitHub issue #N, or stack trace)

## Procedure

1. **Read `ONBOARDING.md`** at the repo root to identify the test
   runner. If absent, refuse with "run `/onboard .` first."

2. **Resolve the bug source:**
   - If `$@` looks like an issue number (`#N` or just `N`), fetch
     with `bash scripts/vcs-helper.sh issue-view N`.
   - If `$@` is a stack trace, parse the file:line.
   - Otherwise treat `$@` as a free-form description.

3. **Identify the test runner** from `ONBOARDING.md`. Cross-check by
   listing existing tests:
   - TypeScript: search for `**/*.test.ts`, `**/*.spec.ts`,
     `tests/**/*.ts`
   - Python: search for `tests/**/*.py`, `**/test_*.py`,
     `**/*_test.py`

4. **Find the most relevant existing test** touching the same module.
   Read it to copy the team's testing style (imports, fixtures,
   naming). Cite as `path:line` in the new test.

5. **Create a `repro/<slug>` branch** with `git checkout -b
   repro/<slug>`. Slug is a kebab-case summary, e.g.
   `repro/login-after-password-reset` or `repro/issue-42`.

6. **Write the failing test** in the project's existing test
   directory:
   - Name the test exactly after the bug.
   - Test ONLY the failing behavior. Minimum reproducer, no extras.
   - Header comment linking to the bug source.

7. **Run the test** and confirm it fails.
   - If it passes: the repro is wrong. Iterate up to two times. If
     still passing, output `INCOMPLETE: cannot reproduce` and do
     NOT commit.

8. **Capture the first 30 lines of the failure trace.**

9. **Commit on the `repro/<slug>` branch** with this exact format:

```
test(repro): failing test for <one-line bug summary>

repro for: <bug source>
verify: <test runner command> — failing as expected

<first 10 lines of failure output>
```

10. **Print the handoff line:**

```
Repro committed on branch `repro/<slug>` (test in <path>).
Verified failing: <one-line failure summary>

Now switch back to Cursor and invoke `@bug-hunter` to investigate.
```

## Test framework conventions

### TypeScript / vitest
```ts
import { describe, it, expect } from "vitest";

describe("repro for #42", () => {
  it("rejects login when reset token is reused", async () => {
    // minimum reproducer
  });
});
```

### Python / pytest
```python
"""repro for #42"""
import pytest

def test_login_rejects_reused_reset_token():
    with pytest.raises(ValueError, match="token already used"):
        # minimum reproducer
        ...
```

## Rules

- **One test per invocation.** Multiple bugs = multiple branches.
- **Never modify production code from this prompt.** That's for
  `@bug-hunter` / `@implementer` after this repro lands.
- **Never skip step 7 (confirm failure).** A "looks like it should
  fail" test is worse than no test.
- **If you can't repro, stop honestly.** `INCOMPLETE: cannot
  reproduce` is a useful answer; a fake-passing test is not.
- **Don't run the full test suite — only the new test.** Save tokens
  and clock time.
