# MATRIX.md — tooling rationale

> This document explains **why** the team's AI workflow is configured the way
> it is. The audience is the hackathon judge (human and AI) who will inspect
> this repository to evaluate "how efficiently and optimally the workflow
> configuration is set up". The team operating manual is in
> [AGENTS.md](AGENTS.md); the day-of script is in [PLAYBOOK.md](PLAYBOOK.md).

---

## Thesis

The challenge theme is **Code less, AI more**. We optimized our setup to
make that thesis literal: three engineers all work primarily through one
shared harness — **Cursor** — with role-owned subagents, shared slash
commands, shared rules, shared skills, and shared hooks. Anything one
engineer improves immediately benefits the other two because every
artifact lives in the repository under [.cursor/](.cursor/) and
[.claude/agents/](.claude/agents/). The judge-visible configuration is
the deliverable.

**Pi is positioned as a shared rate-limit fallback**, not anyone's
primary. Any of P1/P2/P3 can switch to Pi when Cursor rate-limits, or
when they want to scan a large context cheaply. One command activates it:
`bash scripts/pi-rescue.sh`.

We considered (and explicitly rejected) two alternative configurations:

1. **One harness per engineer (3-way diversity).** This gives a "breadth"
   narrative but no compounding. Configuration written by one engineer is
   useless to the others. The team pays a context-switching tax every
   time they pair-debug.
2. **Two co-equal primaries (e.g. Cursor + Claude Code).** Sounds
   resilient, but in a 4-hour event maintaining two parallel sets of
   commands/skills/hooks is overhead nobody pays off. Concentrating on
   one harness lets us tune it deeper.

---

## Configuration at a glance

| Surface     | Role                             | Primary artifacts                                                              | Investment |
| ----------- | -------------------------------- | ------------------------------------------------------------------------------ | ---------- |
| **Cursor**  | shared primary loop (all three)  | [.cursor/](.cursor/) — 4 rules, 12 commands, 9 skills, hooks, MCP              | ~85%       |
| **Pi**      | shared rate-limit fallback       | [tools/pi/](tools/pi/) — 5 prompts, 1 skill, system prompt overlay             | ~10%       |
| Cross-cutting | shared SSoT + subagent specs   | [AGENTS.md](AGENTS.md), [.claude/agents/](.claude/agents/) (9 role subagents)  | ~5%        |

---

## Why Cursor as the single primary

1. **One enterprise license pool, three engineers.** Cursor Enterprise
   pools the team's tokens. Concentrating activity on Cursor means we
   spend the licensed budget on one tool that everyone is set up for,
   instead of splintering across providers.

2. **Configuration is in the repo, not in editor preferences.**
   [.cursor/rules/](.cursor/rules/) (always-apply + glob-scoped),
   [.cursor/commands/](.cursor/commands/) (slash commands),
   [.cursor/skills/](.cursor/skills/) (declarative workflows),
   [.cursor/hooks.json](.cursor/hooks.json) (session + post-edit
   automation), and [.cursor/mcp.json](.cursor/mcp.json) (Playwright +
   Context7 MCP servers) are all checked in. A judge can clone the
   repo, open it in Cursor, and reproduce our exact workflow.

3. **Subagent definitions live in [.claude/agents/](.claude/agents/).**
   Cursor's `Task` tool reads that directory natively, so we get
   file-based subagents (with explicit ownership, tool allowlist, and
   model choice) without writing Cursor-specific code. A judge can
   `head -1 .claude/agents/*.md` and read the ownership table directly.
   This is the only `.claude/` artifact we kept — everything else
   collapsed into `.cursor/`.

4. **Slash commands compound across the team.** When P2 improves the
   `/ship` command in
   [.cursor/commands/ship.md](.cursor/commands/ship.md), P1 and P3
   immediately pick that up the next time they invoke it. There is no
   "syncing"; the repo is the sync.

5. **Hooks enforce discipline uniformly.** The
   [post-edit-typecheck](.cursor/hooks/post-edit-typecheck.sh) hook fires
   on `afterFileEdit` for any engineer in any session; the
   [session-start](.cursor/hooks/session-start.sh) hook prints branch,
   open PRs, and `PLAN.md` count to stderr the moment a new chat opens.
   The team's quality bar and shared state visibility are encoded in
   one place.

6. **Worktrees for parallel work.** Two engineers can run independent
   spikes simultaneously via
   [scripts/spike.sh](scripts/spike.sh) — a fresh worktree on a
   `spike/<name>` branch, opened in a new Cursor window via tmux. No
   conflict; everyone's `.cursor/` is identical because it's in the
   repo.

7. **Workspace-level MCP.** [.cursor/mcp.json](.cursor/mcp.json) declares
   Playwright (for demo recording) and Context7 (for up-to-date library
   docs). Cursor picks them up the moment the workspace opens — no per-
   engineer setup, no manual server-start.

---

## Why `.claude/agents/` stays

Cursor's `Task` tool reads agent definitions from `.claude/agents/*.md`
natively. The 9 role subagents (`architect`, `bug-hunter`,
`demo-builder`, `implementer`, `planner`, `refactorer`, `reviewer`,
`test-writer`, `ui-designer`) work in Cursor with zero modification. We
deliberately preserved that directory while deleting the rest of the
`.claude/` tree:

- `.claude/commands/` → ported to [.cursor/commands/](.cursor/commands/)
- `.claude/skills/` → ported to [.cursor/skills/](.cursor/skills/)
- `.claude/hooks/` + `.claude/settings.json` → ported to
  [.cursor/hooks/](.cursor/hooks/) + [.cursor/hooks.json](.cursor/hooks.json)
- `.mcp.json` → ported to [.cursor/mcp.json](.cursor/mcp.json)
- `CLAUDE.md` → deleted (AGENTS.md is the canonical operating manual)

Keeping `.claude/agents/` is judge-legible signal: we use the open
subagent-definition format because it's portable, not because we run
Claude Code.

---

## Why Pi as shared fallback (not anyone's secondary)

Pi is excellent at:

- Mid-session model switching across 15+ providers (`/model`, `Ctrl+L`).
- Tree-structured session history (`/tree`) for forking exploratory work.
- Cross-provider routing — if the Cursor token pool tightens, Pi can run
  on Groq, OpenAI, or local models without changing the prompts.
- Large-context scans where Cursor's per-message cost would add up.

We do **not** assign Pi to any one engineer because:

- Hardcoding Pi to "P3 only" creates an artificial bottleneck: P1 and P2
  can't burst into Pi when they need it. By making it a shared resource
  with mirrored prompts in [tools/pi/prompts/](tools/pi/prompts/), any
  engineer can switch in under a minute.
- Pi explicitly skips Cursor's `Task` subagent surface and MCP wiring.
  These are core to our orchestration model. Pi can carry equivalent
  prompts but the configuration discipline lives in `.cursor/`.

The Pi pack is committed (not on-demand), so the activation is just
`bash scripts/pi-rescue.sh`. Five prompts mirror the five highest-value
Cursor commands: `/review`, `/test`, `/bug-hunt`, `/onboard`, `/repro`.

---

## Token routing assumptions and fallbacks

The hackathon organizers will issue licensed token quotas. We don't know
in advance which provider. Our setup degrades gracefully across the
plausible scenarios:

| Provider scenario              | Primary harness         | Fallback action                                      | Estimated switch time |
| ------------------------------ | ----------------------- | ---------------------------------------------------- | --------------------- |
| Cursor Enterprise pool         | Cursor (default)        | none — this is the design center                     | 0 min                 |
| Cursor pool tight / rate-limit | Cursor + Pi parallel    | affected engineer: `bash scripts/pi-rescue.sh`       | ~1 min                |
| Cursor unavailable             | Pi for everyone         | all three switch via pi-rescue; copy `.cursor/rules/` text into Pi system prompt | ~15 min |
| Mixed gateway / OpenRouter     | Pi (15+ providers)      | Pi routes through whichever provider is up           | ~5 min                |

In all scenarios, the [AGENTS.md](AGENTS.md) operating manual is
unchanged. The team's workflow contract — branching, PRs, DoD — is the
same regardless of which surface the engineer is using.

---

## What "optimally configured workflow" looks like, concretely

We took the judging criterion seriously. The configuration in this
repository is designed to demonstrate:

- **Explicit ownership.** Every subagent has a named owner (P1/P2/P3).
  A judge can identify who is responsible for each capability without
  asking.
- **Separation of concerns.** Subagent system prompts are tightly
  scoped; their failure modes are documented in
  [PLAYBOOK.md](PLAYBOOK.md) "Recovery patterns".
- **Layered configuration.** Rules apply by glob, commands by slash,
  skills by name or by ambient context, hooks by event, MCP by
  workspace open. Each layer is in the right place — no monolithic
  config file.
- **Security by design.** Hooks are exit-0 advisory, never blocking.
  Sensitive paths (`.env`, `secrets/`) are excluded from PR diffs by
  the `/pr-merge` gate; no agent autopilots a secret-leaking change.
- **Reproducibility.** The setup is a repository. Anyone can clone it
  and recreate the team's workflow exactly. No personal `~/.cursor/`
  state is required for the configured behavior; per-engineer
  overrides live in `.cursor/settings.local.json` (gitignored).
- **Graceful degradation.** Multiple documented fallback paths
  (Cursor rate-limit → Pi rescue, Cursor down → Pi for everyone,
  GitHub down → local bare-repo sync). Each has a known activation
  command and an expected recovery time.
- **Cross-tool standards.** [AGENTS.md](AGENTS.md) follows the open
  AGENTS.md specification. Subagent definitions in
  [.claude/agents/](.claude/agents/) follow the open subagent format
  that multiple harnesses read. We did not invent a private
  convention.

---

## What we deliberately did **not** do

For honesty: here are configuration choices we considered and rejected.

- **No Cursor Background Agents.** Tempting for parallel work, but
  setup risk inside a 4-hour event is too high. Local worktrees +
  tmux give us the same parallelism with zero remote-execution
  dependencies. Documented in [AUDIT.md](AUDIT.md) as a deliberate
  "do not act on" decision.
- **No Bugbot.** Not relevant unless we're set up as a PR bot; we
  don't have the lead time to wire it in.
- **No two-primary harness setup.** We previously prototyped a
  Claude-Code-primary configuration. The current `.cursor/` tree is
  the simplified, single-primary version. Subagent definitions
  carried over verbatim because they were already format-portable.
- **No CI workflows yet.** Phase 1 of this template is configuration
  only. CI is added in Phase 2 with the Next.js skeleton, when there
  is real code to lint and test.
- **No "best of N" attempt orchestration.** Tempting, but it eats
  tokens fast. The team has 5 hours, not unlimited budget.
- **No agent-written `AGENTS.md`.** Auto-generated AGENTS.md files
  underperform human-written ones by a measurable margin. This file
  and AGENTS.md were written by humans, and will be tuned by humans
  during the prep week.
