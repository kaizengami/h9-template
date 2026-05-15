# /demo-record — record the demo via Playwright + browser MCP

Use during Phase 4 (3:45–4:30 elapsed). P1 owns this command. Other
engineers should not run it unless P1 explicitly hands off.

This command produces a `demo.webm` (or `.mp4`) at the repo root and a
set of screenshots under `docs/screenshots/`.

## Pre-flight

Confirm before starting:

1. `MISSION.md` exists and the happy path works end-to-end on `main`.
2. `pnpm dev` is running locally on the demo machine.
3. The Playwright MCP server is reachable (it's declared in
   [.mcp.json](mdc:.mcp.json) at the repo root; Cursor inherits it).
4. The team's chat has been notified — no commits land while recording.

## Steps

1. Read [DEMO.md](mdc:DEMO.md) if it exists. If not, run
   [@demo-builder](mdc:.claude/agents/demo-builder.md) in Claude Code
   first to produce a narration script.
2. Walk through the narration with the browser MCP, taking
   screenshots at each `**[m:ss]**` marker in `DEMO.md`. Save to
   `docs/screenshots/NN-<descriptor>.png`.
3. Run a Playwright recording session:

   ```bash
   npx playwright test tests/e2e/demo.spec.ts --headed --workers=1
   ```

   The test should be tagged `@demo` and configured to produce a
   `video: 'on'` artifact. Move the generated video to `demo.webm` at
   the repo root.

4. Open `demo.webm` and verify:
   - The narration sync points are reachable visually
   - No console errors flashed across the screen
   - Resolution is at least 1280×800
   - The full recording is under 3:00

5. If the take is good: commit with
   `docs(demo): add demo recording, screenshots, narration`.
   If not: re-run from step 3, do not edit the video manually.

## Failover

If Playwright MCP is unavailable or recording fails twice:

- Fall back to QuickTime screen recording. Announce in chat.
- Record at 1080p, 30fps, with system audio.
- Save as `demo.mov`, then convert to `demo.mp4` via
  `ffmpeg -i demo.mov -c:v libx264 -crf 22 demo.mp4`.
- Update `DEMO.md` to reference `demo.mp4` instead of `demo.webm`.
