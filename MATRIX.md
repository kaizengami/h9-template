# MATRIX.md — tooling rationale

> This document explains **why** the team's AI workflow is configured the way
> it is. The audience is the hackathon judge (human and AI) who will inspect
> this repository to evaluate "how efficiently and optimally the workflow
> configuration is set up". The team operating manual is in
> [AGENTS.md](AGENTS.md); the day-of script is in [PLAYBOOK.md](PLAYBOOK.md).

---

## Thesis

The challenge theme is **Code less, AI more**. We optimized our setup to make
that thesis literal: three engineers all work primarily through Claude Code's
terminal-first agent loop, with role-owned subagents, shared slash commands,
and shared hooks. Each engineer drives 3 subagents they own. The slash
commands, hooks, and `AGENTS.md` are shared so that anything one engineer
improves immediately benefits the other two.

Cursor and Pi are present as **documented secondary surfaces**, not as
co-equal harnesses. Cursor's role is demo polish and visual PR review during
the last hour. Pi's role is rate-limit recovery only — installable in under
30 seconds via [scripts/pi-rescue.sh](scripts/pi-rescue.sh).

We considered (and explicitly rejected) two alternative configurations:

1. **One harness per engineer (3-way diversity).** This gives a "breadth"
   narrative but no compounding. Subagents written by one engineer are
   useless to the others. The team pays a context-switching tax every time
   they pair-debug.
2. **Cursor for everyone.** Cursor is excellent inside an IDE, but its
   subagent surface is SDK-level rather than file-level. For a multi-
   engineer team, file-based subagents
   ([.claude/agents/](.claude/agents/)) make ownership and review legible
   in the repo. SDK-driven subagents would not show up in a `tree` listing.

---

## Configuration at a glance

| Surface          | Role              | Primary artifacts                                         | Investment |
| ---------------- | ----------------- | --------------------------------------------------------- | ---------- |
| **Claude Code**  | primary loop      | [.claude/](.claude/) — 9 subagents, 8 commands, hooks    | ~80%       |
| **Cursor**       | secondary polish  | [.cursor/](.cursor/) — 4 rules, 2 commands                | ~10%       |
| **Pi**           | rate-limit hedge  | [tools/pi-fallback/](tools/pi-fallback/) — 3 prompts, 1 skill | ~5%   |
| Cross-cutting    | shared SSoT       | [AGENTS.md](AGENTS.md), [.mcp.json](.mcp.json)            | ~5%        |

---

## Why Claude Code as the primary

1. **Subagents as files.** Each subagent under
   [.claude/agents/](.claude/agents/) is a markdown file with explicit
   ownership, tool allowlist, and model choice. This makes the team's
   division of labor a property of the repository, not a property of any
   individual's editor configuration. A judge can `head -1
   .claude/agents/*.md` and read the ownership table directly.

2. **Slash commands are shared.** When P2 improves the `/ship` command
   in [.claude/commands/ship.md](.claude/commands/ship.md), P1 and P3
   immediately pick that up the next time they invoke it. There is no
   "syncing"; the repo is the sync.

3. **Hooks enforce discipline uniformly.** The
   [post-edit-typecheck](.claude/hooks/post-edit-typecheck.sh) hook fires
   for any engineer in any session. The team's quality bar is encoded in
   one place.

4. **Headless mode is a real building block.**
   [scripts/spike.sh](scripts/spike.sh) uses `claude -p` to start a fresh
   non-interactive session inside a worktree. We can fan out parallel
   spikes from a single command.

5. **Permissions are explicit and auditable.**
   [.claude/settings.json](.claude/settings.json) declares the team's
   tool allowlist and denylist. Secrets paths are explicitly denied at
   the harness level; no agent can read `.env` even if it tries.

---

## Why Cursor as secondary

Cursor's IDE surface is best-in-class for two specific moments:

- **Visual PR review** during build, using `cursor-ide-browser` MCP to
  load the dev server and verify UI changes match expectations
  ([.cursor/commands/visual-pr-review.md](.cursor/commands/visual-pr-review.md)).
- **Demo recording** in the last hour, where the
  [`100-demo-polish` rule](.cursor/rules/100-demo-polish.mdc) is "applied
  intelligently" by Cursor to audit happy-path interactions.

These are about visual judgment, not code authorship. Using Cursor here
plays to its IDE strengths without diluting our terminal-first agent loop
during build.

We also keep [.cursor/rules/](.cursor/rules/) populated because any
engineer can open Cursor at any time (e.g. if Claude Code is rate-limited
**and** Pi is also problematic), and the rules will apply automatically.
This is a 15-minute fallback path; the configurations exist precisely to
make that fallback cheap.

---

## Why Pi as fallback only

Pi is excellent at:

- Mid-session model switching across 15+ providers (`/model`, `Ctrl+L`).
- Tree-structured session history (`/tree`) for forking exploratory work.
- Cross-provider routing — if Anthropic rate-limits us, Pi can run on
  Groq, OpenAI, or local models without changing the prompts.

We do **not** use Pi as a primary because:

- Pi explicitly skips subagents, plan mode, sub-agent spawning, and MCP.
  These are core to our orchestration model in Claude Code.
- Pi packs are powerful but require team-wide buy-in to maintain in
  parallel. For a 5-hour event, we cannot maintain two parallel agent
  ecosystems.

So we install Pi on demand only, with
[tools/pi-fallback/](tools/pi-fallback/) providing the three highest-
value prompts (`/review`, `/test`, `/bug-hunt`) as mirrors of the
corresponding subagents. One command installs the pack and points Pi at
it: `bash scripts/pi-rescue.sh`.

---

## Token routing assumptions and fallbacks

The hackathon organizers will issue licensed token quotas. We do not know
in advance which provider. Our setup degrades gracefully across the
plausible scenarios:

| Provider scenario          | Primary harness        | Fallback action                            | Estimated switch time |
| -------------------------- | ---------------------- | ------------------------------------------ | --------------------- |
| Anthropic API              | Claude Code (default)  | none — this is the design center           | 0 min                 |
| OpenAI / Bedrock / Vertex  | Cursor (multi-provider)| `.cursor/rules/` apply; subagent share drops | ~15 min            |
| Mixed gateway / OpenRouter | Pi (15+ providers)     | `pi install -l ./tools/pi-fallback`; reduced subagent fidelity | ~5 min |

In all three scenarios, the [AGENTS.md](AGENTS.md) operating manual is
unchanged. The team's workflow contract — branching, PRs, DoD — is the
same regardless of which surface the engineer is using.

---

## What "optimally configured workflow" looks like, concretely

We took the judging criterion seriously. The configuration in this
repository is designed to demonstrate:

- **Explicit ownership.** Every subagent has a named owner. A judge can
  identify who is responsible for each capability without asking.
- **Separation of concerns.** Subagent system prompts are tightly
  scoped; their tool allowlists are minimal; their failure modes are
  documented in [PLAYBOOK.md](PLAYBOOK.md) "Recovery patterns".
- **Security by design.** Secrets paths are denied in
  [.claude/settings.json](.claude/settings.json) at the harness level.
  Curl is denied. The hook script is exit-0 advisory, never blocking.
- **Reproducibility.** The setup is a repository. Anyone can clone it
  and recreate the team's workflow exactly. No personal `~/.claude/`
  state is required for the configured behavior; per-engineer overrides
  live in `.claude/settings.local.json` (gitignored).
- **Graceful degradation.** Three documented fallback paths
  (Cursor switch, Pi rescue, GitHub-down). Each has a known activation
  command and an expected recovery time.
- **Cross-tool standards.** [AGENTS.md](AGENTS.md) follows the open
  AGENTS.md specification, which all three of our harnesses can read.
  We did not invent a private convention.

---

## What we deliberately did **not** do

For honesty: here are configuration choices we considered and rejected.

- **No Cursor `.cursor/mcp.json` in the repo.** The team's user-level
  Cursor MCP setup is already rich. Re-declaring the same MCP servers at
  project scope adds noise without benefit. If the team needs a project-
  specific MCP, it goes here; otherwise, the global setup is the right
  layer.
- **No CI workflows yet.** Phase 1 of this template is configuration
  only. CI is added in Phase 2 with the Next.js skeleton, when there is
  real code to lint and test.
- **No Cursor SDK parallel spike script.** This would require the team
  to have Cursor Cloud Agents available on event day, which depends on
  the licensed token plan the organizers issue. We do not want a
  hard dependency. The local `scripts/spike.sh` covers the same need.
- **No "best of N" attempt orchestration.** Tempting, but it eats tokens
  fast. The team has 5 hours, not unlimited budget.
- **No agent-written `AGENTS.md`.** Published research showed auto-
  generated `AGENTS.md` files underperform human-written ones by a
  measurable margin (Princeton, 2025). This file and AGENTS.md were
  written by humans, and will be tuned by humans during the prep week.
