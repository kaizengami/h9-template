# hack9-pi — shared Pi pack

This is the team's **shared Pi pack**. The primary harness is Cursor
(see [/MATRIX.md](../../MATRIX.md)). Pi is positioned as a shared
team resource — any of P1/P2/P3 may activate it without prior approval.

## When to use this pack

The Pi pack is appropriate in three scenarios:

1. **Rate-limit recovery.** Cursor returns rate-limit errors that the
   team estimates will take more than a minute to clear. Switch to Pi
   to keep moving without occupying the Cursor token pool.
2. **Parallel work without occupying the Cursor pool.** One engineer
   wants to run a large-context scan (e.g. issue triage across 100
   open issues) while the other two stay on Cursor for the main
   build path.
3. **Provider mismatch on event day.** The organizers issue tokens
   for a non-Anthropic / non-OpenAI provider that Cursor can't
   accept directly. Pi supports 15+ providers and is the team's last
   fallback.

Do **not** use this pack as a permanent primary surface — the team's
configuration discipline lives in [/.cursor/](../../.cursor/) and
[/.claude/agents/](../../.claude/agents/), and Pi doesn't read those
two trees directly. It mirrors the highest-value commands as
self-contained prompts.

## Activation

From the repository root:

```bash
bash scripts/pi-rescue.sh
```

This installs the pack into the project's `.pi/settings.json` (local
path install, no files copied) and launches Pi. Equivalent manual flow:

```bash
pi install -l ./tools/pi
pi
```

## What's in the pack

```text
tools/pi/
├── package.json          # Pi pack manifest
├── README.md             # this file
├── APPEND_SYSTEM.md      # additions to Pi's system prompt
├── prompts/              # five slash commands
│   ├── review.md         # /review — mirrors @reviewer
│   ├── test.md           # /test — mirrors @test-writer
│   ├── bug-hunt.md       # /bug-hunt — mirrors @bug-hunter
│   ├── onboard.md        # /onboard — mirrors the onboard-repo skill
│   └── repro.md          # /repro — mirrors the reproduce-bug skill
└── skills/
    └── playwright-e2e/   # on-demand Playwright skill
        └── SKILL.md
```

The five prompts are a curated subset, not a full mirror. We picked
the highest-value flows: read-only review/test/bug-hunt, plus the two
given-repo entry points (`/onboard`, `/repro`) that are most likely to
be needed if the challenge gives the team an unfamiliar repo. Planning,
implementation, UI design, demo recording, and PR merging stay on
Cursor where the orchestration tools (subagents, MCP, hooks) are wired.

## Provider selection

Pi reads `~/.pi/agent/models.json` for custom providers. The team
should have configured providers before the event per their issued
token type. Switch providers mid-session via `/model` or `Ctrl+L`.

## Don't

- Don't commit anything Pi writes outside this pack's directory. The
  team's PR discipline owns the `main` branch via Cursor's `/pr-merge`.
- Don't run `/review` or `/test` from Pi against PRs that the Cursor
  primary has already produced reports for — duplicate reports
  confuse the team. Use Pi for fresh work.
- Don't forget to announce the switch in team chat (per
  [AGENTS.md §6](../../AGENTS.md)).
