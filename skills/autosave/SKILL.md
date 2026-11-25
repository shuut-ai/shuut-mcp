---
name: autosave
description: Turn shuut auto-save off or back on. Auto-save is a setting of the user's shuut account, on by default and changed at https://shuut.ai/mcp; while it is on, every finished or edited video the agent hands over (also made with ffmpeg or other local tools) is saved to the user's shuut editor projects. Optionally, with the user's OK, add one line to the user's own instruction file on this computer. Use when the user wants videos no longer (or again) saved to shuut, or asks whether videos are saved automatically.
---

# Turn shuut auto-save off or back on

Auto-save is a setting of the user's shuut account: "Auto-save work from AI apps" at https://shuut.ai/mcp (signed in), on by default. While it is on, after an agent hands over a finished or edited video (also made with ffmpeg or other local tools), it saves it with `editor_save` as an editable project in the user's shuut editor, with its source files, fonts and captions, and gives the link once per project. While it is off, `editor_save` refuses an unrequested save with autosave_off, and the agent asks the user once per video. The setting applies to every app connected to the account. New projects go to the user's personal space; team, brand or client work goes to the team's folder for it. Saving is free (no credits, not counted in the project limit; fair use 300 new projects a day, updates are not counted). The uploads count toward the account's daily upload limit (300 files and 3 GB a day, shared with the shuut website and exports). The first use through MCP records the account's one-time upload notice as accepted; an account that withdrew it must accept it again in a browser at https://shuut.ai. Drafts, previews and candidates are not saved.

How to change it:
- For every app: the user flips the switch at https://shuut.ai/mcp. You cannot change it for them; give them the link.
- One video or one conversation: the user says so ("don't save this to shuut"). Nothing is written, and it comes first whatever the setting.
- Optional, for this computer only: a line in the user's own instruction file (steps 1-4 below), for example to keep this agent from saving even while the account setting is on.
- The plugin's save note after ffmpeg and similar tools (Claude Code and Codex): `SHUUT_SAVE_REMINDER=off` or `SHUUT_AUTOSAVE=off` (the same thing) removes the note on this computer only. It does not change the account setting; the server and the editor-save skill still follow it.

1. Give the user the https://shuut.ai/mcp link first. If they also want a line in their instruction file: to stop saving, add the off line right away; to add the on line, tell the user it lets this agent save every final video and wait for a clear yes. Do nothing without the yes.
2. Add the line to the instruction file of the agent you are running in. Append it (never rewrite or reorder the file), skip it if the line is already there, remove the other line (off or on) if it is there, and show the user the file path and the line you added:
   - Claude Code: `CLAUDE.md` in the Claude Code config folder (`$CLAUDE_CONFIG_DIR` if set, else `~/.claude`).
   - Codex: in the Codex home (`$CODEX_HOME` if set, else `~/.codex`), `AGENTS.override.md` if it exists (Codex then reads only that file), else `AGENTS.md`.
   - Codex asks for approval before each call of an editing tool. When turning auto-save on, only if `config.toml` in the Codex home registers the shuut server as its own table (`[mcp_servers.shuut]`, as `codex mcp add` writes it; if it has another name, use that name), append this table too, starting on a new line, and only if the file has no such `tools.editor_save` table yet:
   ```toml
   [mcp_servers.shuut.tools.editor_save]
   approval_mode = "approve"
   ```
   - Never write that table when `config.toml` does not register the server as its own table (the shuut Codex plugin, no file, or an inline `{ … }` table): Codex would then fail to start. Instead tell the user to choose "Allow and don't ask me again" the first time Codex asks to run `editor_save`.
   - Cursor: you cannot write the user's rules. Ask the user to paste the line in Cursor Settings → Rules → User Rules.
   - Another agent: its user-level instruction file or custom instructions; if you cannot write it, give the user the line to add.
3. Tell the user what the account setting is for (https://shuut.ai/mcp), which file holds the line, and how to undo it (step 4).
4. To undo: remove that line (and the `tools.editor_save` table from `config.toml` if you added it), then tell the user.

The off line:

> I use shuut. Do not auto-save my videos to shuut; save a video to my shuut editor projects only when I ask.

The on line (only with the user's yes; the account setting at https://shuut.ai/mcp still decides whether `editor_save` saves):

> I use shuut. Whenever you finish or edit a video for me, also save it to my shuut editor projects with the shuut editor_save tool (sources, captions, fonts and background kept separate; team, brand or client work in the team folder for it), without asking me first, and give me the open_url.

## Default for media work (a separate line)

Using shuut by default for images, video, voice and music is a separate setting with its own yes: the default skill (prompt default), only when the user asks for it; a yes to auto-save is not a yes to this, and turning auto-save on or off does not change it.

## Saving while auto-save is on

Follow the editor-save skill: upload the clean sources, pass them as `media` and your edit as `spec` or the ffmpeg commands you ran as `ffmpeg` (captions, fonts and background stay separate) and the final render as `reference`; pass `video` alone only when the video is not your own edit. Always send `key` (the final output file path) so the same video updates its project. Team, brand or client work: list the team folders with `editor_folders` and pass the matching folder's name exactly as listed as `folder`, with `space` "team".

Example arguments for `editor_save`:

```json
{ "name": "Cardigan reel", "key": "out/cardigan_reel.mp4", "media": { "src1": "<clip_file_id>" }, "spec": { "shots": [{ "id": "S1", "media": "src1" }] }, "reference": "<final_video_file_id>", "idempotency_key": "cardigan-reel-1" }
```
