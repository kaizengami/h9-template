---
name: explore-codebase
description: Research a topic in the codebase using Cursor's Task tool with subagent_type "explore" (a forked, read-only context). Use when you need to understand existing patterns before implementing, when investigating a bug, or when a question would require reading many files.
---

# Explore the codebase

Read-only research skill. Delegates to Cursor's built-in `explore`
subagent type via the `Task` tool, which runs in a **forked context**
so the main session stays clean. Returns a summary with `path:line`
citations.

This is the canonical entry point for "what's the existing pattern
for X" questions. Use it before implementing anything that touches
unfamiliar code.

## Invocation

Launch a `Task` with `subagent_type: "explore"` and the prompt
template below. The subagent operates in read-only mode.

```text
Research the following topic in this repository: <QUESTION>

Goals:
1. Find the most relevant files using Glob for path patterns and
   Grep for keyword searches. Prefer narrow searches over wide ones.
2. Read enough to understand the existing pattern, idiom, or
   architecture choice. Don't read entire large files; read the
   relevant sections.
3. Summarize findings with specific path:line citations. Every
   claim should be backed by a citation.
4. Note open questions explicitly. If something about intent is
   ambiguous, surface it rather than guessing.

Constraints:
- Do not edit any files. This is a read-only investigation.
- Do not propose code changes. Describe what exists; the calling
  session will decide what to do next.
- Do not invoke other subagents. Stay in this fork.
- Do not call any MCP tool that has side effects.

Output format:

## Topic
<one-line restatement of the question>

## Relevant files
- `path/to/file.ts:42-71` — <one-line summary>
- `path/to/other.tsx:120-145` — <one-line summary>

## Findings
1. <Claim with `path:line` citation>
2. <Claim with `path:line` citation>

## Open questions
- <Anything ambiguous about intent or pattern>

## Suggested next step
<One sentence. Never a full implementation plan.>

End your response with exactly one of:
- `READY: <brief next-step suggestion>`
- `NEEDS_DECISION: human must decide between <X> and <Y>`
- `INCOMPLETE: <what blocked the investigation>`
```

## Why a forked subagent

A forked `explore` subagent keeps the main session's token window
clean. Use this skill liberally — the cost of "look first" is small
in tokens, and the cost of "implement against a wrong mental model"
is large.

## When to use a direct search instead

- You already know the answer; just answer.
- A trivial single-file lookup; use `Read` or `Grep` directly.
- The question fits in a single grep — no need to fork.

## Don't

- Don't try to also implement the fix from inside the `explore`
  subagent — the whole point is separation between exploration and
  writing.
- Don't invoke `explore` recursively; one fork is enough for any
  one question.
