---
name: issue-triage
description: Pull a GitHub or GitLab issue and extract symptom, repro steps, environment, suspected files. Use when the challenge gives you issues to fix. Outputs a triage doc that feeds into /repro and /onboard.
---

# issue-triage

Input pipeline from GitHub/GitLab issues to actionable structured triage.
The hackathon may hand the team a list of issues to fix — this skill
turns each issue into the structured input that `/repro` and
`@bug-hunter` need, without the team manually reading and summarizing
each one.

Read-only. Never modifies issues, never posts comments, never assigns.

## When to use

- The challenge brief contains GitHub issue numbers or URLs.
- After `/onboard` lands ONBOARDING.md and the "Open issues" section
  shows triageable items.
- Before invoking `/repro` — triage decides whether the issue is even
  reproducible.

## How to invoke

```text
/issue-triage 42
```

```text
/issue-triage https://github.com/example/repo/issues/42
```

## Data to gather

Run this command first and feed the output into your reasoning:

```bash
bash scripts/vcs-helper.sh issue-view "<N or URL>"
```

If the CLI is not authenticated or the issue is private and inaccessible,
output `INCOMPLETE: VCS CLI not authenticated. Run login and
retry.` and stop.

## Your task

Read the issue data above. Produce a triage doc with this exact
shape:

```markdown
## Triage for issue #<N> — <title>

**Reporter:** <author> (<createdAt>)
**Labels:** <labels or "none">
**State:** <open/closed>

### Symptom
<One sentence: what does the user observe.>

### Repro steps
<Numbered list, extracted from the issue body. If the issue gives
"actual" + "expected" without explicit steps, infer the minimum
sequence. If steps are unclear, write "ambiguous — needs author
clarification" and stop.>

### Environment
- OS / Platform: <from issue body if mentioned, else "unspecified">
- Version / Branch: <from issue body, else "unspecified">
- Other: <relevant deps, env vars, etc.>

### Suspected files
<2-5 file paths, based on:
1. Stack traces in the body or comments (extract `path:line`).
2. Mentions of feature areas (auth, billing, etc.) cross-referenced
   against the repo's directory structure.
Cite each as `path:line` when you have a line number, just `path`
otherwise. Mark each with confidence:
  - HIGH: stack trace points here
  - MEDIUM: feature area match, no line citation
  - LOW: educated guess>

### Reproducibility assessment
<One of:
- DETERMINISTIC: clear steps, should reproduce on first try
- LIKELY: steps clear but environment-dependent
- FLAKY: timing/race/network-dependent
- UNCLEAR: needs author clarification>

### Linked PRs
<List from closingIssuesReferences, or "(none)">

### Recommended next step
<Exactly one of:
- `/repro <slug>` — if reproducibility is DETERMINISTIC or LIKELY
- `/onboard .` — if you need codebase context before reproducing
- "Ask author for clarification" — if UNCLEAR
- "Skip" — if FLAKY and not the highest priority>
```

End with one status line:

- `READY: <one-sentence next-step suggestion>`
- `NEEDS_DECISION: human must decide between <X> and <Y>`
- `INCOMPLETE: <what blocked the triage>`

## Rules

1. **Quote the issue, don't paraphrase symptoms.** A paraphrase loses
   nuance ("login fails" vs. "login fails after password reset using
   the same token twice").
2. **Cite stack traces verbatim.** If the issue has a stack trace,
   include it in the "Suspected files" section as a code block. The
   reproducer needs the exact error.
3. **Confidence labels are mandatory** in "Suspected files." Without
   them, the next agent will treat low-confidence guesses as facts.
4. **Stop on missing repro steps.** If the issue body is "it doesn't
   work," output `INCOMPLETE: needs author clarification`. Do not
   invent repro steps.
5. **Triage one issue per invocation.** For multi-issue triage, the
   user should call this skill in a loop.
6. **Read-only.** Never make modifying API calls from this skill.

## Failure modes

- **VCS CLI not authenticated.** Output `INCOMPLETE: VCS CLI not
  authenticated. Run login and retry.` and stop.
- **Issue from a private repo we don't have access to.** Same
  symptom; same response.
- **Issue is closed with a fix.** Note in the triage doc, suggest
  reading the closing PR/MR's diff instead of re-reproducing.

## Don't

- Don't assign or label. Read-only.
- Don't follow links to external bug trackers (Linear, Jira) — this
  skill is VCS-only (GitHub/GitLab). If the issue is cross-posted, note it and
  stop.
- Don't fetch the linked PR's diff here. That's for the next agent
  (`/repro` or `@bug-hunter`).
