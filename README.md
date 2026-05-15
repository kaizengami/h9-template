# hack9 hackathon template

Configuration scaffold for a 3-engineer hackathon team running primarily on
**Claude Code**, with Cursor as a secondary surface for demo polish and Pi
as a documented rate-limit fallback.

This is **Phase 1**: configuration only. There is no application skeleton
yet — that lands in Phase 2 after the team's prep dry-run finalizes the
stack choices.

## 60-second bootstrap

```bash
# 1. Verify prerequisites (all three engineers' laptops)
claude --version           # Anthropic Claude Code CLI
gh auth status             # GitHub CLI logged in
tmux -V                    # tmux for parallel sessions
node --version             # Node 20+ for MCP servers via npx

# 2. Optional: pre-pull MCP servers so first invocation is instant
npx -y @playwright/mcp@latest --version

# 3. Start a Claude Code session at the repo root
claude
```

That's the entire setup. Subagents, slash commands, and hooks are
auto-loaded from [.claude/](.claude/) on first start. MCP servers
declared in [.mcp.json](.mcp.json) prompt for one-time approval the
first time they're used.

If Anthropic rate-limits the team mid-event, escape to Pi:

```bash
bash scripts/pi-rescue.sh
```

## Read these in order

For the team — before hackathon day:

1. [AGENTS.md](AGENTS.md) — the operating manual all three engineers
   and all three AI harnesses read.
2. [PLAYBOOK.md](PLAYBOOK.md) — minute-by-minute day-of script.
3. [MATRIX.md](MATRIX.md) — why this configuration exists (also written
   for the hackathon judges).

For an AI judge inspecting the repo:

1. [AGENTS.md](AGENTS.md) and [MATRIX.md](MATRIX.md) explain intent.
2. [.claude/agents/](.claude/agents/) and
   [.claude/commands/](.claude/commands/) show the orchestration
   surface.
3. [.claude/settings.json](.claude/settings.json) shows the security
   posture (explicit permissions, deny rules for secrets).

## Repo map

```text
.
├── AGENTS.md                       # operating manual (SSoT for all harnesses)
├── CLAUDE.md                       # Claude Code-specific overrides; @-imports AGENTS.md
├── PLAYBOOK.md                     # day-of minute timeline x 3 roles
├── MATRIX.md                       # tooling rationale for judges
├── .mcp.json                       # Claude Code project MCP servers
├── .gitignore
│
├── .claude/                        # PRIMARY: Claude Code config (~80% of effort)
│   ├── settings.json               # permissions, hooks, model, attribution
│   ├── agents/                     # 9 role-owned subagents (3 per engineer)
│   ├── commands/                   # 8 slash commands (plan, spike, ship, ...)
│   └── hooks/                      # post-edit-typecheck.sh (advisory)
│
├── .cursor/                        # SECONDARY: demo polish, visual review
│   ├── rules/                      # 4 .mdc rules (core, TS, shadcn, demo)
│   └── commands/                   # 2 commands (demo-record, visual-pr-review)
│
├── tools/pi-fallback/              # FALLBACK: rate-limit escape hatch
│   ├── package.json                # Pi pack manifest
│   ├── APPEND_SYSTEM.md            # adds to Pi system prompt
│   ├── prompts/                    # /review, /test, /bug-hunt for Pi
│   └── skills/playwright-e2e/      # Playwright E2E skill
│
└── scripts/
    ├── spike.sh                    # git worktree + new claude session in tmux
    └── pi-rescue.sh                # install Pi pack and switch to Pi
```

## Phase 2 — what's next

After the team's prep-week dry-run (planned for ~5 days before the event),
Phase 2 adds:

- Next.js 15 App Router skeleton with shadcn/ui, Tailwind, Drizzle+libSQL.
- `package.json` with `typecheck`, `lint`, `test`, `dev` scripts.
- `.github/workflows/ci.yml` for type/lint/test on push.
- A `DEMO.md` template that `@demo-builder` fills in on event day.

## License

This template is intentionally unlicensed in Phase 1. The team will pick a
license alongside the application skeleton in Phase 2.
