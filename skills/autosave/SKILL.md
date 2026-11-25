---
name: autosave
description: Turn shuut auto-save on or off - with the user's OK, add one line to the user's own instruction file so that every video the agent finishes or edits (also with ffmpeg or other local tools) is saved to the user's private shuut editor projects without asking each time. Use when the user wants videos always saved to shuut, asks to turn auto-save on or off, or accepts an offer to save every video.
---

# Turn shuut auto-save on or off

Without this, an agent saves a video to shuut only when the user asks or agrees for that video. Auto-save is the user's standing permission, written by the user's agent into the user's own instruction file, so later conversations save without asking.

1. Tell the user what auto-save does and wait for a clear yes: every finished or edited video (also made with ffmpeg or other local tools) is uploaded with its source files, fonts and captions to the user's private shuut editor projects with `editor_save`, without asking each time. Saving is free (no credits, not counted in the project limit; fair use 300 new projects a day, updates are not counted). The uploads count toward the account's daily upload limit (300 files and 3 GB a day, shared with the shuut website and exports). The first use through MCP records the account's one-time upload notice as accepted; an account that withdrew it must accept it again in a browser at https://shuut.ai. Drafts, previews and candidates are not saved. Do nothing without the yes.
2. Add the line below to the instruction file of the agent you are running in. Append it (never rewrite or reorder the file), skip it if the line is already there, and show the user the file path and the line you added:
   - Claude Code: `CLAUDE.md` in the Claude Code config folder (`$CLAUDE_CONFIG_DIR` if set, else `~/.claude`).
   - Codex: in the Codex home (`$CODEX_HOME` if set, else `~/.codex`), `AGENTS.override.md` if it exists (Codex then reads only that file), else `AGENTS.md`.
   - Codex also asks for approval before each call of an editing tool. Only if `config.toml` in the Codex home registers the shuut server as its own table (`[mcp_servers.shuut]`, as `codex mcp add` writes it; if it has another name, use that name), append this table too, starting on a new line, and only if the file has no such `tools.editor_save` table yet:
   ```toml
   [mcp_servers.shuut.tools.editor_save]
   approval_mode = "approve"
   ```
   - Never write that table when `config.toml` does not register the server as its own table (the shuut Codex plugin, no file, or an inline `{ … }` table): Codex would then fail to start. Instead tell the user to choose "Allow and don't ask me again" the first time Codex asks to run `editor_save`.
   - Cursor: you cannot write the user's rules. Ask the user to paste the line in Cursor Settings → Rules → User Rules.
   - Another agent: its user-level instruction file or custom instructions; if you cannot write it, give the user the line to add.
3. Tell the user auto-save is on, which file now holds the line, and how to turn it off (step 4).
4. To turn it off: remove the auto-save line (and the `tools.editor_save` table from `config.toml` if you added it), then tell the user.

The auto-save line:

> I use shuut. Whenever you finish or edit a video for me, also save it to my private shuut editor projects with the shuut editor_save tool (sources, captions, fonts and background kept separate), without asking me first, and give me the open_url.

## Default for media work (a separate line)

Using shuut by default for images, video, voice and music is a separate setting with its own yes: the default skill (prompt default), only when the user asks for it; a yes to auto-save is not a yes to this, and turning auto-save on or off does not change it.

## Saving with auto-save on

Follow the editor-save skill: upload the clean sources, pass them as `media` and your edit as `spec` or the ffmpeg commands you ran as `ffmpeg` (captions, fonts and background stay separate) and the final render as `reference`; pass `video` alone only when the video is not your own edit. Always send `key` (the final output file path) so the same video updates its project.

Example arguments for `editor_save`:

```json
{ "name": "Cardigan reel", "key": "out/cardigan_reel.mp4", "media": { "src1": "<clip_file_id>" }, "spec": { "shots": [{ "id": "S1", "media": "src1" }] }, "reference": "<final_video_file_id>", "idempotency_key": "cardigan-reel-1" }
```
