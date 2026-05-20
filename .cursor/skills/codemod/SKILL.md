---
name: codemod
description: Apply a structural code change across many files using ast-grep (TS/JS/Python). Use for behavior-preserving migrations like API surface changes, renaming, or framework upgrades. Always dry-runs first. Manual invocation only.
disable-model-invocation: true
---

# codemod

Mass structural refactor using [ast-grep](https://ast-grep.github.io)
— a syntax-aware search-and-replace that beats `sed`/`rg` for any
change that needs to respect parentheses, scopes, or trailing
commas. Works on TypeScript, JavaScript, and Python.

This skill is **manual invocation only** (`disable-model-invocation:
true`) because mass rewrites are easy to get wrong, and a wrong
codemod is a multi-PR mess. Always dry-runs first; the user must
approve before any file changes.

## When to use

- Renaming an exported symbol used in 30+ places.
- Migrating from `import { foo } from "old"` to
  `import { foo } from "new"` across the codebase.
- Adding a required argument to every call site of a function.
- Wrapping every `await fetch(...)` with a retry helper.
- Converting `class X extends React.Component` to function components
  (with caveats — codemods can't always preserve runtime behavior).

## When NOT to use

- The change is fewer than ~5 occurrences. `Edit` directly, faster.
- The change requires reasoning about types, semantics, or business
  logic. Codemods are syntactic only. Use `@refactorer` instead.
- The repo doesn't have a working test suite — you can't verify the
  rewrite. Stop and write tests first.

## How to invoke

```text
/codemod 'logger.warn($ARG)' 'logger.warning($ARG)' 'src/**/*.ts'
```

Three arguments:
1. **Pattern**: ast-grep pattern. Use `$ARG`, `$$$ARGS` for
   captures (see [ast-grep pattern syntax](https://ast-grep.github.io/guide/pattern-syntax.html)).
2. **Replacement**: ast-grep rewrite template using the same captures.
3. **Glob** (optional): which files to touch. Defaults to "all source
   files in repo." Always narrow this when possible.

## Procedure

1. **Read ONBOARDING.md** to confirm the language. ast-grep needs
   `--lang` (`ts`, `tsx`, `js`, `jsx`, `python`). Refuse if the repo
   isn't one of these.
2. **Confirm clean working tree.** `git status --porcelain | head -1`
   must be empty. If dirty, refuse: "stash or commit first — codemod
   will write to many files and you need a clean rollback point."
3. **Create a `chore/codemod-<slug>` branch** so the change is
   isolated from any in-flight work.
4. **Dry-run first**:
   ```bash
   npx --yes @ast-grep/cli run \
     --lang <ts|js|tsx|python> \
     --pattern "<PATTERN>" \
     --rewrite "<REPLACEMENT>" \
     --glob "<GLOB>"
   ```
   (No `--update-all` flag — this prints the diff without writing.)
5. **Save the dry-run output** to `codemod-plan.md` at the repo root:
   ```markdown
   # Codemod plan

   Generated: <ISO>
   Branch: chore/codemod-<slug>

   ## Pattern
   <PATTERN>

   ## Replacement
   <REPLACEMENT>

   ## Glob
   <GLOB>

   ## Files affected
   <count> files

   ## Diff preview
   ```diff
   <first 100 lines of dry-run output>
   ```

   ## Verification plan
   After applying, the following must still pass:
   - <test runner command from ONBOARDING.md>
   - Typecheck/lint (if applicable)
   ```
6. **Stop and request approval.** Output to the user:
   ```
   Dry-run complete. <N> files would change. Plan written to
   codemod-plan.md. Review the diff, then reply "apply" to commit,
   or "abort" to discard and `git checkout main`.
   ```
7. **On "apply" only**, run again with `--update-all`:
   ```bash
   npx --yes @ast-grep/cli run \
     --lang <ts|js|tsx|python> \
     --pattern "<PATTERN>" \
     --rewrite "<REPLACEMENT>" \
     --glob "<GLOB>" \
     --update-all
   ```
8. **Run verification** (test command from ONBOARDING.md). If it
   fails, do NOT commit — output the failure and let the user decide
   to revert (`git checkout .`) or fix forward.
9. **Commit only if verification passes:**
   ```bash
   git add -A
   git commit -m "chore(codemod): <one-line description>

   pattern: <PATTERN>
   replacement: <REPLACEMENT>
   files changed: <count>
   verify: <test command> — clean
   "
   ```
10. **Report back** with the PR plan: branch name, file count, link
    to `codemod-plan.md`. Do NOT auto-create the PR — that's a
    decision for the calling session.

## Pattern examples

### TypeScript: rename a function call site
```text
Pattern:     logger.warn($MSG)
Replacement: logger.warning($MSG)
Glob:        src/**/*.{ts,tsx}
```

### TypeScript: change import source
```text
Pattern:     import { $$$NAMES } from "@old/lib"
Replacement: import { $$$NAMES } from "@new/lib"
Glob:        **/*.{ts,tsx}
```

### Python: convert print to logger.info
```text
Pattern:     print($MSG)
Replacement: logger.info($MSG)
Glob:        src/**/*.py
```

### TypeScript: add second arg to every call
```text
Pattern:     fetch($URL)
Replacement: fetch($URL, { signal })
Glob:        src/**/*.ts
```
(Then add the `signal` import + binding manually — codemod is for
the call sites, not the surrounding scaffolding.)

## Rules

1. **Dry-run is mandatory.** Never run with `--update-all` on the
   first pass. Verify before declaring done — that applies doubly to
   mass rewrites.
2. **Always on a `chore/codemod-*` branch.** Mixing codemod commits
   with feature commits makes the diff unreadable.
3. **Glob narrowly.** A pattern that matches `**/*` will hit
   `node_modules/`, `.next/`, generated code, fixtures. ast-grep
   respects `.gitignore` but be explicit.
4. **One pattern per invocation.** Multiple rewrites = multiple
   commits = reviewable.
5. **Never codemod tests** unless that's the explicit goal. Tests
   are the verification surface; if they get rewritten, you've
   destroyed the verification.
6. **Always commit `codemod-plan.md` as part of the codemod commit**
   so the diff is reviewable later.

## Failure modes

- **Pattern matches too broadly.** Dry-run will show it. Tighten the
  pattern with more captures or a narrower glob.
- **Pattern matches too narrowly (zero hits).** Pattern syntax is
  wrong. Test with a simpler version first; consult [ast-grep
  playground](https://ast-grep.github.io/playground.html).
- **Tests fail after apply.** Most likely the codemod was syntactic
  but not semantic. Revert with `git checkout .` or `git reset
  --hard HEAD`. Investigate, refine pattern, retry.
- **`npx --yes @ast-grep/cli` not available offline.** ast-grep
  requires network for first install. Document this in
  PLAYBOOK Phase 0 (pre-event installs).

## Don't

- Don't use codemod for one-off fixes. `Edit` is faster.
- Don't chain multiple codemods in a single commit. Each one is its
  own diff to review.
- Don't codemod across language boundaries (ast-grep is per-language).
- Don't codemod and then `@refactorer` in the same session — the
  refactorer assumes stable inputs.
