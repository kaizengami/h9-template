---
name: explore-codebase
description: Research a topic in the codebase using the Explore subagent in a forked context. Use when you need to understand existing patterns before implementing, when investigating a bug, or when a question would require reading many files.
context: fork
agent: Explore
---

# Explore the codebase

Read-only research skill. Runs in a **forked context** in the
built-in `Explore` subagent so the main session stays clean. Returns
a summary with `path:line` citations.

This is the canonical entry point for "what's the existing pattern
for X" questions. Use it before implementing anything that touches
unfamiliar code.

## Usage

```text
/explore-codebase How does the auth middleware decide which routes are public?
```

or

```text
/explore-codebase the data fetching pattern for the dashboard route
```

## Task

Research the following topic in this repository: $ARGUMENTS

### Goals

1. **Find the most relevant files** using `Glob` for path patterns
   and `Grep` for keyword searches. Prefer narrow searches over wide
   ones.
2. **Read enough to understand** the existing pattern, idiom, or
   architecture choice. Don't read entire large files; read the
   relevant sections.
3. **Summarize findings** with specific `path:line` citations. Every
   claim should be backed by a citation.
4. **Note open questions** explicitly. If something about intent is
   ambiguous, surface it rather than guessing.

### Constraints

- **Do not edit any files.** This is a read-only investigation.
- **Do not propose code changes.** Describe what exists; the calling
  session will decide what to do next.
- **Do not invoke other subagents.** Stay in this fork.
- **Do not call any MCP tool that has side effects** (writing,
  network calls outside the repo, etc.).

### Output format

Return a Markdown document with:

```markdown
## Topic
<one-line restatement of the question>

## Relevant files
- `path/to/file.ts:42-71` — <one-line summary of what this section does>
- `path/to/other.tsx:120-145` — <one-line summary>

## Findings
1. <Claim with `path:line` citation>
2. <Claim with `path:line` citation>
3. <…>

## Open questions
- <Anything ambiguous about intent or pattern — leave for the
  calling session to decide.>

## Suggested next step
<One sentence. Never a full implementation plan.>
```

End your response with **exactly one** of these status lines:

- `READY: <brief next-step suggestion for the calling session>`
- `NEEDS_DECISION: human must decide between <X> and <Y>`
- `INCOMPLETE: <what blocked the investigation>`

## Why a forked context

A forked-context Explore subagent keeps the main session's token
window clean. Use this skill liberally — the cost of "look first" is
small in tokens, and the cost of "implement against a wrong mental
model" is large.

## Don't

- Don't use this skill when you already know the answer; just answer.
- Don't use this skill for trivial single-file lookups; `Read` or
  `Grep` directly.
- Don't try to also implement the fix from inside this skill — the
  whole point is separation between exploration and writing.
