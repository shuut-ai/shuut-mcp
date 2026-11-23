---
name: auto-update
description: Keep the shuut plugin up to date - with the user's OK, turn on automatic updates for the shuut-mcp marketplace in Claude Code or GitHub Copilot CLI (one setting in the user's own settings file), or tell the user how their app updates the plugin. Use when the user wants shuut to stay current, asks how to update the shuut plugin or its skills, or wants plugin auto-update on or off.
---

# Keep the shuut plugin up to date

shuut's tools come from the shuut server and are always current. The plugin's files (skills, subagents, hooks) are a copy on the user's computer that changes only when the app updates its plugins. Some apps do that by themselves; Claude Code and GitHub Copilot CLI do it only for a marketplace whose auto-update the user turned on.

1. Find how shuut is installed in the app you are running in:
   - Claude Code: run `claude plugin list --json`. If an entry has the id `shuut@shuut-mcp`, the settings file is `settings.json` in the Claude Code config folder (`$CLAUDE_CONFIG_DIR` if set, else `~/.claude`): go on with step 2. If the id is `shuut@synced`, the copy comes from claude.ai: follow the claude.ai item below. The user can also turn it on in `/plugin` → Marketplaces → shuut-mcp → Enable auto-update.
   - GitHub Copilot CLI: run `copilot plugin list --json`. If a row has the name `shuut` and the marketplace `shuut-mcp`, the settings file is `settings.json` in the Copilot home (`$COPILOT_HOME` if set, else `~/.copilot`): go on with step 2.
   - Codex: nothing to turn on: each start refreshes the shuut-mcp marketplace and reinstalls shuut when it changed. To update now: `codex plugin marketplace upgrade shuut-mcp`. Subagent files copied to `~/.codex/agents` do not update: copy them again (README "Subagents").
   - Gemini CLI: an extension installed with `--auto-update` updates when Gemini CLI starts (when a new version changes the skills, Gemini asks the user to confirm). Otherwise run `gemini extensions update shuut`.
   - VS Code: plugins update with extensions when `extensions.autoUpdate` is on; to update now run **Chat: Update Plugins**.
   - Cursor: a team marketplace updates with Refresh in the Cursor dashboard (Auto Refresh needs the Cursor GitHub App on the repository); a local copy updates with `git pull` in its folder.
   - claude.ai, Claude Desktop or Cowork (in Claude Code, a copy synced from claude.ai shows the id `shuut@synced`): for a marketplace added in Customize → Plugins, Check for updates gets the newest version now; Sync automatically can be turned on too. For an uploaded `shuut-plugin.zip`, upload the newest one from github.com/shuut-ai/shuut-mcp/releases again.
   - Skills installed with the skills CLI: run `npx skills update`, and `npx skills add shuut-ai/shuut-mcp` again for new skills; with the GitHub CLI: `gh skill update` (no automatic updates).
   - Any other case (shuut added only as an MCP server, or installed from another marketplace or folder): change no settings. Tell the user that shuut's tools are always current, and how that install updates if you know.
2. Tell the user what the setting does and wait for a clear yes: whenever a session starts, the app checks github.com/shuut-ai/shuut-mcp and installs new versions of the shuut plugin by itself, which replace its skills, subagents and hook scripts (the hooks run after shell commands), with no prompt for each new version. Do nothing without the yes.
3. Copy the settings file first. Then, under `extraKnownMarketplaces`, set `"autoUpdate": true` in the `shuut-mcp` entry (adding the marketplace wrote that entry). Change only that value in place, never rewrite the whole file, and keep everything else as it is (Copilot's file may have comments). Then read the setting back (Copilot CLI: run `copilot config extraKnownMarketplaces`; Claude Code: read the file, which must stay plain JSON): if it no longer loads or the value is not `true`, put the copy back, show the user the `/plugin` step or the setting to add, and stop. Claude Code may ask for permission before its settings change; if the edit is refused or the entry is not there, show the user the `/plugin` step or the setting to add, and stop.
4. Tell the user that auto-update is on, when it applies, and what still stops it: Claude Code checks in the background up to ten minutes after the first message of a session (then `/reload-plugins`, or it applies at the next start), and not at all while `DISABLE_UPDATES`, `DISABLE_AUTOUPDATER` or `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` is set, unless `FORCE_AUTOUPDATE_PLUGINS=1`. Copilot CLI checks when a session starts in a folder the user trusts, unless its own `autoUpdate` setting is false (the default in CI) or `COPILOT_AUTO_UPDATE=false` is set. To turn it off, set `"autoUpdate": false` (Claude Code: or turn it off in `/plugin`).
5. To update right away: Claude Code `claude plugin marketplace update shuut-mcp`, then `claude plugin update shuut@shuut-mcp` and `/reload-plugins`; Copilot CLI `copilot plugin marketplace update shuut-mcp`, then `copilot plugin update shuut@shuut-mcp`.

## After an update

Start a new session (Claude Code: or run `/reload-plugins`), then check that shuut answers, for example by showing the user's credit balance (free).

Example arguments for `balance`:

```json
{}
```
