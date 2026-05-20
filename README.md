# h9 template

Configuration scaffold for a 3-engineer hackathon team running primarily
on **Cursor**, with **Pi** as a shared rate-limit / parallel-work
fallback. Subagent definitions live in
[.claude/agents/](.claude/agents/) because Cursor's `Task` tool reads
that directory natively — we kept the open subagent format even though
we don't use Claude Code as a runtime.

This is **Phase 1**: configuration only. There is no application
skeleton yet — that lands in Phase 2 after the team's prep dry-run
finalizes the stack choices.

## 60-second bootstrap

```bash
# 1. Verify prerequisites (all three engineers' laptops)
# Verify VCS CLI: either GitHub CLI (gh) OR GitLab CLI (glab)
gh auth status             # Logged in to github.com (OR glab auth status --hostname vcs.levi9.com)
tmux -V                    # tmux for parallel sessions
node --version             # Node 20+ for MCP servers via npx

# 2. Optional: pre-pull MCP servers so first invocation is instant
npx -y @playwright/mcp@latest --version

# 3. Open the workspace in Cursor
cursor .
```

That's the entire setup. Rules, slash commands, skills, and hooks are
auto-loaded from [.cursor/](.cursor/) the moment Cursor opens the
workspace. The Playwright + Context7 MCP servers declared in
[.cursor/mcp.json](.cursor/mcp.json) prompt for one-time approval the
first time they're used.

If Cursor rate-limits an engineer mid-event, any of P1/P2/P3 can switch
to Pi:

```bash
bash scripts/pi-rescue.sh
```

## Read these in order

For the team — before hackathon day:

1. [AGENTS.md](AGENTS.md) — the operating manual all three engineers
   read.
2. [PLAYBOOK.md](PLAYBOOK.md) — minute-by-minute day-of script.
3. [MATRIX.md](MATRIX.md) — why this configuration exists (also written
   for the hackathon judges).
4. [AUDIT.md](AUDIT.md) — gap analysis vs. Cursor's documented patterns
   and the conscious "decided not to" list.

For an AI judge inspecting the repo:

1. [AGENTS.md](AGENTS.md) and [MATRIX.md](MATRIX.md) explain intent.
2. [.cursor/](.cursor/) shows the orchestration surface — rules,
   commands, skills, hooks, MCP.
3. [.claude/agents/](.claude/agents/) shows the 9 role-owned subagent
   definitions (Cursor's `Task` tool reads them natively).
4. [tools/pi/](tools/pi/) shows the shared fallback pack mirroring the
   highest-value Cursor commands.

## Repo map

```text
.
├── AGENTS.md                       # operating manual (SSoT)
├── PLAYBOOK.md                     # day-of minute timeline x 3 roles
├── MATRIX.md                       # tooling rationale for judges
├── AUDIT.md                        # gap analysis vs Cursor docs
├── CHALLENGE.md                    # multi-repo / given-repo challenge template
├── .gitignore
│
├── .cursor/                        # PRIMARY: Cursor config (~85% of effort)
│   ├── rules/                      # 4 .mdc rules (core, TS, shadcn, demo)
│   ├── commands/                   # 12 slash commands (plan, spike, ship, ship, demo, …)
│   ├── skills/                     # 9 skills (explore, onboard-repo, repro, bisect, …)
│   ├── hooks/                      # session-start.sh + post-edit-typecheck.sh
│   ├── hooks.json                  # wires sessionStart + afterFileEdit
│   └── mcp.json                    # Playwright + Context7 MCP servers
│
├── .claude/agents/                 # SUBAGENTS: 9 role definitions (Cursor Task reads natively)
│
├── tools/pi/                       # FALLBACK: shared rate-limit / parallel-work pack
│   ├── package.json                # Pi pack manifest
│   ├── APPEND_SYSTEM.md            # adds to Pi system prompt
│   ├── prompts/                    # /review, /test, /bug-hunt, /onboard, /repro
│   └── skills/playwright-e2e/      # Playwright E2E skill
│
└── scripts/
    ├── spike.sh                    # git worktree + new Cursor session in tmux
    └── pi-rescue.sh                # activate the Pi pack and switch to Pi
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
