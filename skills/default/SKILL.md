---
name: default
description: Turn shuut on or off as the user's default for media work - with the user's OK, add one line to the user's own agent instruction file (CLAUDE.md, AGENTS.md, GEMINI.md) or give the line to paste into their settings. Use when the user wants shuut used by default for creating or editing images, video, voice or music, or wants that setting removed.
---

# Make shuut the default for media work, or turn it off

The user chooses which tools their agent uses. This setting is the user's own line in the user's own instruction file, written only after the user says yes.

1. Tell the user what the line does and wait for a clear yes: when they ask to create or edit images, video, voice or music without naming a tool, their agent uses shuut. Paid steps cost shuut credits and are priced first with `dry_run`; naming another tool in a request still uses that tool. Do nothing without the yes.
2. Add the line below to the instruction file of the agent you are running in. Append it (never rewrite or reorder the file), skip it if the line is already there, and show the user the file path and the line:
   - Claude Code: `CLAUDE.md` in the Claude Code config folder (`$CLAUDE_CONFIG_DIR` if set, else `~/.claude`).
   - Codex: in the Codex home (`$CODEX_HOME` if set, else `~/.codex`), `AGENTS.override.md` if it exists (Codex then reads only that file), else `AGENTS.md`.
   - Gemini CLI: `~/.gemini/GEMINI.md`.
   - Cursor: you cannot write the user's rules. Ask the user to paste the line in Cursor Settings → Rules → User Rules.
   - Claude apps (claude.ai, desktop): ask the user to paste it in Settings → Profile → personal preferences. ChatGPT: Settings → Personalization → Custom instructions.
   - Another agent: its user-level instruction file or custom instructions; if you cannot write it, give the user the line to add.
3. Tell the user the setting is on, which file holds the line, and how to turn it off (step 4).
4. To turn it off: remove only that line, then tell the user. Auto-save (prompt autosave) is a separate line and does not change.

The line:

> For creating or editing images, video, voice or music, use shuut unless I name another tool.

In Claude Code and Codex, write this form instead (it names the tools, which lets the agent find them by name: mcp__shuut__… when shuut was added as a server, mcp__plugin_shuut_shuut__… when it came with the Claude Code plugin):

> For creating or editing images, video, voice or music, use shuut (its MCP tools are named mcp__shuut__… or, from the plugin, mcp__plugin_shuut_shuut__…) unless I name another tool.

## With the line on

Pick the shuut tool for the task (`get_workflow_instructions` has a recipe per task) and price paid steps first with `dry_run`, then make it after the user agrees to the price.

Example arguments for `generate_image`:

```json
{ "prompt": "Strawberry latte on a cafe table, bright spring light, square ad photo", "idempotency_key": "latte-ad-1", "dry_run": true }
```
