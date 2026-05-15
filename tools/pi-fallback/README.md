# hack9-pi-fallback — Pi pack

This is a **fallback** Pi pack. The team's primary harness is Claude Code
(see [/MATRIX.md](../../MATRIX.md)). Use this pack only when Claude Code
is unavailable — typically because the Anthropic API has rate-limited us
mid-event.

## When to use this pack

The Pi escape hatch is appropriate in two scenarios:

1. **Rate-limit recovery.** Claude Code returns rate-limit errors that
   the team estimates will take more than 5 minutes to clear. Switch
   to Pi to keep moving.
2. **Provider mismatch on event day.** The organizers issue tokens for
   a non-Anthropic provider that Cursor can't accept either. Pi
   supports 15+ providers and is the team's last fallback.

Do **not** use this pack as a primary surface. The team's subagent
ecosystem lives in [/.claude/agents/](../../.claude/agents/) and that's
where the highest-value capabilities are.

## Installation

From the repository root:

```bash
bash scripts/pi-rescue.sh
```

This installs the pack into the project's `.pi/settings.json` (local
path install, no files copied) and launches Pi. Equivalent manual flow:

```bash
pi install -l ./tools/pi-fallback
pi
```

## What's in the pack

```text
tools/pi-fallback/
├── package.json          # Pi pack manifest
├── README.md             # this file
├── APPEND_SYSTEM.md      # additions to Pi's system prompt
├── prompts/              # three slash commands
│   ├── review.md         # /review — mirrors @reviewer
│   ├── test.md           # /test — mirrors @test-writer
│   └── bug-hunt.md       # /bug-hunt — mirrors @bug-hunter
└── skills/
    └── playwright-e2e/   # on-demand Playwright skill
        └── SKILL.md
```

The three prompts are deliberately fewer than the nine subagents in
Claude Code. We picked the ones that are read-only / safest to run with
a non-Anthropic model. Planning, implementation, and UI design are
sensitive to model quality, so we keep those on Claude Code only.

## Provider selection

Pi reads `~/.pi/agent/models.json` for custom providers. The team should
have configured providers before the event per their issued token type.
Switch providers mid-session via `/model` or `Ctrl+L`.

## Don't

- Don't commit anything Pi writes outside this pack's directory. The
  primary harness owns the `main` branch.
- Don't run `/review` or `/test` from Pi against PRs that Claude Code
  has already produced reports for — duplicates confuse the team.
- Don't forget to announce the switch in team chat (per
  [AGENTS.md §6](../../AGENTS.md)).
