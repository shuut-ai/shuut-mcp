<p align="center">
  <a href="https://shuut.ai/mcp"><img src=".github/assets/banner.jpg" alt="shuut MCP: make and edit images, videos and audio from your AI assistant" width="100%"></a>
</p>

<p align="center">
  <a href="https://registry.modelcontextprotocol.io/?q=ai.shuut%2Fshuut"><img alt="MCP Registry: ai.shuut/shuut" src="https://img.shields.io/badge/MCP_Registry-ai.shuut%2Fshuut-d7ff3a?labelColor=0b0b0c"></a>
  <a href="https://cursor.directory/plugins/shuut"><img alt="cursor.directory" src="https://img.shields.io/badge/cursor.directory-shuut-d7ff3a?labelColor=0b0b0c"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-d7ff3a?labelColor=0b0b0c"></a>
</p>

<p align="center">
  <a href="https://shuut.ai">shuut.ai</a> · <a href="https://shuut.ai/mcp">Setup guide</a> · <a href="#install">Install</a> · <a href="#versions-and-updates">Updates</a> · <a href="#example-one-video-start-to-finish">Example</a> · <a href="#skills">Skills</a> · <a href="#subagents">Subagents</a>
</p>

Image generation, video generation and image/video editing with GPT Image, Nano Banana, Seedream image generation, Seedance video generation, Kling and Veo: product shots, ads and avatars. Also voice, music and captions. Billed to your shuut credits. 1 credit = 1 US cent, same prices as the shuut app. Paid tools run at once; with `dry_run: true` they return the exact price without spending, and `max_spend_credits` caps a call.

**Reverse Video**: hand it one video (a file, or a TikTok, Instagram, YouTube or X link) and get it back as an editable shuut project. Change the layers, the text, the colors. Free to run, with a daily limit.

> Rebuild this video as an editable project: `<link>`

- **Server**: `https://shuut.ai/mcp` (Streamable HTTP, OAuth sign-in with your shuut account; the MCP server takes no API keys)
- **Billing**: credits come from one-time credit packs or a monthly plan (Starter, Plus or Ultra); each plan includes a monthly credit balance. Current prices are on shuut.ai
- **Developer API**: for your own code there is also a REST API with API keys — docs at https://shuut.ai/developers, OpenAPI at https://shuut.ai/v1/openapi.json. It uses the same balance and prices as the MCP server
- **Skills**: 15 step-by-step workflows (`skills/`), also served by the server itself
- **Subagents**: 2 helpers (Ad director, Variant runner) for Claude Code, GitHub Copilot CLI, VS Code, Cursor and Codex; the ones that spend make the job right away, or quote with `dry_run` first and create only after you approve the price when you ask to see it or set a budget
- **One folder for every host**: this repository's root is the plugin (Claude Code, GitHub Copilot CLI, VS Code agent plugins, Cursor, Gemini CLI, Codex)
- This repository is generated from the shuut source; edits here are overwritten.

## Install

Pick one way per agent. A plugin brings the server, the skills and (where the host supports them) the subagents in one install; sign in with your shuut account when your app asks (most apps ask the first time a shuut tool runs; GitHub Copilot CLI asks when a session starts).

**One click** (server only)

<a href="https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=shuut&connectorUrl=https%3A%2F%2Fshuut.ai%2Fmcp"><img alt="Add to Claude" src="https://img.shields.io/badge/Add_to_Claude-0b0b0c?style=for-the-badge&logo=claude&logoColor=d7ff3a"></a>
<a href="https://cursor.com/install-mcp?name=shuut&config=eyJ1cmwiOiJodHRwczovL3NodXV0LmFpL21jcCJ9"><img alt="Add to Cursor" src="https://img.shields.io/badge/Add_to_Cursor-0b0b0c?style=for-the-badge&logo=cursor&logoColor=d7ff3a"></a>
<a href="https://vscode.dev/redirect/mcp/install?name=shuut&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Fshuut.ai%2Fmcp%22%7D"><img alt="Install in VS Code" src="https://img.shields.io/badge/Install_in_VS_Code-0b0b0c?style=for-the-badge"></a>

### Claude Code

```sh
claude plugin marketplace add shuut-ai/shuut-mcp
claude plugin install shuut@shuut-mcp
```

Or inside Claude Code: `/plugin marketplace add shuut-ai/shuut-mcp` then `/plugin install shuut@shuut-mcp`. Skills run as `/shuut:<skill>`. Claude Code updates plugins from a marketplace you add only after you turn on its auto-update once: run `/plugin` in Claude Code's terminal UI, open **Marketplaces** → **shuut-mcp** and choose **Enable auto-update**, or ask Claude to keep shuut up to date (`/shuut:auto-update`).

Sign in once: run `/mcp` in Claude Code and authenticate `plugin:shuut:shuut`, or run `claude mcp login plugin:shuut:shuut` in a terminal (the plugin registers the server under that name).

### GitHub Copilot CLI

```sh
copilot plugin marketplace add shuut-ai/shuut-mcp
copilot plugin install shuut@shuut-mcp
```

Start a new session; `/skills list` shows the shuut skills. Copilot CLI updates plugins from a marketplace you add only after you turn on its auto-update: ask Copilot to keep shuut up to date (the `auto-update` skill), or see [Versions and updates](#versions-and-updates).

### VS Code (agent plugins)

Turn on agent plugins in VS Code settings, add `shuut-ai/shuut-mcp` as a plugin marketplace (Extensions view, search `@agentPlugins`), then install **shuut**.

### Cursor

- **Team marketplace** (Teams and Enterprise plans): Dashboard → Plugins & MCPs → Team Marketplaces → Add Marketplace → Import from Repo → `https://github.com/shuut-ai/shuut-mcp`, then install **shuut**.
- **Local plugin**: put this repository in `~/.cursor/plugins/local/shuut` (for example `git clone https://github.com/shuut-ai/shuut-mcp ~/.cursor/plugins/local/shuut`) and reload Cursor. Your organization's policy may turn local plugins off.

### Gemini CLI

```sh
gemini extensions install https://github.com/shuut-ai/shuut-mcp --auto-update
```

Restart Gemini CLI and run `/mcp auth shuut` to sign in. The extension adds the shuut server, the skills in `skills/` and a short `GEMINI.md` note.

### Codex and ChatGPT desktop

```sh
codex plugin marketplace add shuut-ai/shuut-mcp
codex plugin add shuut@shuut-mcp
```

Or install **shuut** from the Plugins Directory in Codex or the ChatGPT desktop app after adding the marketplace. Sign in with `codex mcp login shuut` if Codex does not ask.

### OpenCode and other agents

Install the skills with the skills CLI, then add the server `https://shuut.ai/mcp` (Streamable HTTP, OAuth) in that agent's MCP settings:

```sh
npx skills add shuut-ai/shuut-mcp
gh skill install shuut-ai/shuut-mcp --all   # GitHub CLI 2.94+
```

### claude.ai, Claude Desktop, Cowork and ChatGPT

- **claude.ai / Claude Desktop / Cowork**: Customize → Plugins → Add marketplace → `shuut-ai/shuut-mcp`, install **shuut**, then connect shuut on the plugin's Connectors tab. You can also upload `shuut-plugin.zip` from the [latest release](https://github.com/shuut-ai/shuut-mcp/releases) (Customize → Plugins → Upload plugin).
- **ChatGPT**: follow the ChatGPT tab of the [setup guide](https://shuut.ai/mcp?tab=chatgpt).

### Any MCP client

Add the server `https://shuut.ai/mcp`; the same skills are served by the server itself (prompts, `skill://shuut/<name>/SKILL.md` resources, and the `get_workflow_instructions` tool). From a terminal:

```sh
claude mcp add --transport http --scope user shuut https://shuut.ai/mcp
codex mcp add shuut --url https://shuut.ai/mcp
gemini mcp add --transport http --scope user shuut https://shuut.ai/mcp
```

### Notes

**Codex**

- Uploading a local file runs `curl` from the shell. Codex's default `workspace-write` sandbox has no network, so that curl fails with `Could not resolve host`: approve running it outside the sandbox when Codex asks, or turn network on in `~/.codex/config.toml`:

  ```toml
  [sandbox_workspace_write]
  network_access = true
  ```

- Codex shortens a tool's input schema above 5,000 bytes by dropping its field descriptions. To keep them, raise the limit for shuut in the same file (under the `[mcp_servers.shuut]` table that `codex mcp add` wrote):

  ```toml
  [mcp_servers.shuut]
  tool_input_schema_max_bytes = 8000
  ```

**VS Code and Cursor**: shuut has up to 82 tools. If the app says a request has too many tools (VS Code allows 128 per request), turn off the shuut tools you do not use in its tool picker (VS Code: Configure Tools).

## Make shuut your default (optional)

You choose which tools your agent uses. To have it use shuut whenever you ask for images, video, voice or music without naming a tool, add this line to your own instructions:

> For creating or editing images, video, voice or music, use shuut unless I name another tool.

In Claude Code and Codex the agent writes it as:

> For creating or editing images, video, voice or music, use shuut (its MCP tools are named mcp__shuut__… or, from the plugin, mcp__plugin_shuut_shuut__…) unless I name another tool.

| Where | How |
|---|---|
| Claude Code · Codex · Gemini CLI | Ask "make shuut my default" (Claude Code: `/shuut:default`): after you say yes, the agent appends the line to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md` or `~/.gemini/GEMINI.md` |
| claude.ai / Claude Desktop | Settings → Profile → personal preferences |
| ChatGPT | Settings → Personalization → Custom instructions |
| Cursor | Cursor Settings → Rules → User Rules |

Naming another tool in a request still uses that tool. Remove the line to turn it off.

## Versions and updates

The plugin version is the shuut server version (`serverInfo.version`); each release that changes this repository raises it and is tagged `v<version>`. shuut's tools always come from the server; the plugin's skills, subagents and hooks are a copy that changes when your app updates the plugin.

To turn on automatic updates, ask your agent to keep shuut up to date (the `auto-update` skill, `/shuut:auto-update` in Claude Code): after you say yes, it changes the one setting your app needs, or tells you how your app updates plugins. The plugin brings the shuut server, so a shuut server you added yourself before (`codex mcp add`, `copilot mcp add`) is no longer needed: `codex mcp remove shuut`, `copilot mcp remove shuut`.

| Host | Automatic updates | Update now |
|---|---|---|
| Codex | Yes: each start refreshes the `shuut-mcp` marketplace and reinstalls shuut when it changed. Subagents copied to `~/.codex/agents` do not update: copy them again | `codex plugin marketplace upgrade shuut-mcp` |
| Gemini CLI | Yes, with `--auto-update`: checked when Gemini CLI starts; when a new version changes the skills, Gemini asks you to confirm | `gemini extensions update shuut` |
| VS Code | Yes, when `extensions.autoUpdate` is on | **Chat: Update Plugins** |
| Claude Code | After you turn it on once (off by default for marketplaces you add): `/plugin` → **Marketplaces** → **shuut-mcp** → **Enable auto-update**, or `"autoUpdate": true` on the `shuut-mcp` entry of `extraKnownMarketplaces` in `settings.json` in `~/.claude` (or `$CLAUDE_CONFIG_DIR`) | `claude plugin marketplace update shuut-mcp`, then `claude plugin update shuut@shuut-mcp` and `/reload-plugins` |
| GitHub Copilot CLI | After you turn it on once: `"autoUpdate": true` on the `shuut-mcp` entry of `extraKnownMarketplaces` in `settings.json` in `~/.copilot` (or `$COPILOT_HOME`), checked when a session starts in a folder you trust | `copilot plugin marketplace update shuut-mcp`, then `copilot plugin update shuut@shuut-mcp` |
| Cursor | Team marketplace with Auto Refresh on (needs the Cursor GitHub App on the repository) | Team marketplace: Refresh in the Cursor dashboard. Local plugin: `git pull` in its folder, then reload Cursor |
| claude.ai, Claude Desktop, Cowork (marketplace added in Customize → Plugins) | Sync automatically (reported not to pick up new commits yet: anthropics/claude-code#93825) | **Check for updates** |
| Skills CLI | No | `npx skills update` (new skills: run `npx skills add shuut-ai/shuut-mcp` again; GitHub CLI: `gh skill update`) |
| Uploaded ZIP (claude.ai, ChatGPT developer dashboard) | No | Upload `shuut-plugin.zip` from the newest release again |

## Example: one video, start to finish

Ask your agent, for example:

> Make a 30-second vertical promo for my app with shuut only: write the script, read it in my cloned voice, add a stock presenter, three generated scenes and my screen recording demo.mov, background music, big captions and my logo, then give me the editable project and the MP4. Show me the total price first.

The agent follows the `promo-video` skill: `media_upload` for local files, `generate_audio` (voice, music, sound effects) or `voice_clone_create` (your own voice, with your consent), `avatar_video_create`, `generate_video` / `generate_image`, then `editor_save` (cuts, transitions, captions, logo, blurred background) and `editor_export` for the MP4. Paid steps charge your credits as they run; because this request asks for the total first, the agent prices them with `dry_run` and waits for your OK (without that, it makes them right away). Editing, saving and exporting are free. A video the agent edited with ffmpeg or another tool is saved with `editor_save` too (auto-save is on by default; `/shuut:autosave` turns it off), so you can keep editing it in the shuut editor; making the same video again updates that project instead of adding a new one.

## Skills

| Skill | Command | When it is used |
|---|---|---|
| `upload` | `/shuut:upload` | Bring the user's own image, video or audio file (or a font for editor captions) into shuut and get a file_id for other shuut tools. Use when the user gives a local file or a public URL to use in shuut (to edit, transcribe or pass to another tool as an input). |
| `make-image` | `/shuut:make-image` | Generate images with shuut (GPT Image, Nano Banana, Seedream and other image models) from a text prompt and optional reference images. Use when the user asks to create, draw or render a picture, poster, product shot or illustration. |
| `make-video` | `/shuut:make-video` | Generate videos with shuut (Seedance, Kling, Veo and other video models) from text, a first frame, first and last frames, or reference images, and extend clips. Use when the user asks to create, animate or extend a video. |
| `edit-photo` | `/shuut:edit-photo` | Edit an existing image with shuut - fill or erase a masked area, cut out the background, expand to a new ratio, relight, change the camera angle, replace text, upscale to 4K, split into layers, retouch skin, make a sheet of alternate shots, or try a garment on a person. Use when the user wants to change a photo they already have. |
| `edit-video` | `/shuut:edit-video` | Edit an existing video with shuut - swap people, outfits, objects or the background (SWAP), move a video's motion onto new people and places, upscale to 4K, remove the background, reframe to another aspect ratio, boost fps, dub into another language, add sound or music, re-sync lips, or make it longer. Use when the user wants to change a video they already have. |
| `voice-music` | `/shuut:voice-music` | Make voice-overs, multi-speaker dialogue, background music and sound effects with shuut, clone the user's own voice, or score and dub an existing video. Use when the user asks for narration, text to speech, a voice, their own voice, music, a jingle, a sound effect or captions timing. |
| `product-ad` | `/shuut:product-ad` | Turn a product photo into ad creative with shuut - clean cut-outs, styled product shots, finished ad images with headline and CTA, ad copy, claim screening, translation, and an animated product video. Use when the user wants ads, product shots or marketing images for a product. |
| `batch` | `/shuut:batch` | Run many shuut generations or edits at once - several images, videos, audio clips, cut-outs or product shots in one call - and collect all results. Use when the user asks for variations, a set of ads, many clips or bulk work. |
| `price-check` | `/shuut:price-check` | Check shuut prices, credits and refunds - quote a paid shuut call with dry_run before making it, cap what it may spend, read the balance, usage and refunds. Use when the user asks what something costs, how many credits they have or used, or why a job was refunded, wants to see the price before deciding, or sets a budget. |
| `auto-update` | `/shuut:auto-update` | Keep the shuut plugin up to date - with the user's OK, turn on automatic updates for the shuut-mcp marketplace in Claude Code or GitHub Copilot CLI (one setting in the user's own settings file), or tell the user how their app updates the plugin. Use when the user wants shuut to stay current, asks how to update the shuut plugin or its skills, or wants plugin auto-update on or off. |
| `autosave` | `/shuut:autosave` | Turn shuut auto-save off or back on. Auto-save is a setting of the user's shuut account, on by default and changed in the shuut settings at https://shuut.ai/account#apps; while it is on, every finished or edited video the agent hands over (also made with ffmpeg or other local tools) is saved to the user's shuut editor projects. Optionally, with the user's OK, add one line to the user's own instruction file on this computer. Use when the user wants videos no longer (or again) saved to shuut, or asks whether videos are saved automatically. |
| `default` | `/shuut:default` | Turn shuut on or off as the user's default for media work - with the user's OK, add one line to the user's own agent instruction file (CLAUDE.md, AGENTS.md, GEMINI.md) or give the line to paste into their settings. Use when the user wants shuut used by default for creating or editing images, video, voice or music, or wants that setting removed. |
| `editor-save` | `/shuut:editor-save` | Save a finished or edited video as a shuut editor project the user can open and keep editing, with every source, caption, font and background kept separate, in the user's personal space or a team folder, and update the same project when the video changes. Auto-save is a setting of the user's shuut account (on by default, changed at https://shuut.ai/account#apps); while it is on, final videos you hand over are saved. Use whenever you produced or edited a video, including with ffmpeg or other local tools, and when asked for an editable project, a team or brand folder, an MP4 export or changes to a saved edit. |
| `promo-video` | `/shuut:promo-video` | Make a whole promo, ad, product, launch or explainer video with shuut - script, voice-over or the user's own cloned voice, a talking avatar, generated scenes and screen captures, music and sound effects, cuts, transitions, big captions, logo, blurred background and covering burned-in text - then save it as an editable shuut project and export the final MP4. Use when the user asks for a promo video, an ad video or a reel made with shuut, or for saving or finishing a video edit in shuut, including one made or edited with other tools. |
| `short-drama` | `/shuut:short-drama` | Turn a script or a one-line idea into a vertical short-drama series with shuut — episodes, recurring characters with character sheets, and clips where the characters speak their lines. Use when the user asks for a short drama, a web drama, a series of episodes or talking story clips. |

## Subagents

Separate helpers the main conversation can hand a job to. They cannot ask you anything themselves. The ones that spend make the job right away; if you ask to see the price first or set a budget, they come back with the plan and the exact price from `dry_run`, and create only after you approve that total (capped with `max_spend_credits`).

| Claude Code · Cursor | Codex | When it is used |
|---|---|---|
| `shuut:ad-director` | `shuut_ad_director` | Plans a shuut ad from a product (script, concepts, formats) and makes it with the paid shuut tools; when the task asks to see the price first or sets a budget, it prices every paid step with dry_run and returns the quote, then creates only after that total is approved. Use when the user wants an ad or a set of ads made with shuut. |
| `shuut:variant-runner` | `shuut_variant_runner` | Makes several versions of one shuut request (prompts, angles, ratios, models or photos) with batch calls of up to 8; when the task asks to see the price first or sets a budget, it prices each batch with dry_run and returns the quotes, then runs a batch only after that batch's exact total is approved. Use for variations, A/B sets or the same edit on many photos. |

- **Claude Code and Cursor**: included in the plugin (`agents/`); in Claude Code call one with `@agent-shuut:<name>`.
- **GitHub Copilot CLI and VS Code**: included in the plugin (`com.github.copilot/agents/`); Copilot can hand a job to `shuut:ad-director` or `shuut:variant-runner` by itself, or you pick one with `/agent` (`--agent shuut:<name>`).
- **Codex**: plugins cannot carry subagents, so copy the files in `.codex/agents/` to `~/.codex/agents/` (they use the shuut tools of the session, so install the plugin or add the server too):

```sh
mkdir -p ~/.codex/agents && for a in shuut_ad_director shuut_variant_runner; do curl -fsSL https://raw.githubusercontent.com/shuut-ai/shuut-mcp/main/.codex/agents/$a.toml -o ~/.codex/agents/$a.toml; done
```

## Auto-save (on by default)

A video your agent renders with ffmpeg or another local tool is hard to fine-tune afterwards. So shuut has auto-save, a setting of your shuut account that is on by default: while it is on, after the agent hands you a finished or edited video, it uploads the source files and the final video to your shuut account and saves them as a project in the shuut editor with `editor_save` (free: no credits, not counted in the project limit; fair use 300 new projects a day), where you can keep editing it, and tells you once per project where it went, with the link. The server checks the setting on every save: while it is off, `editor_save` saves only what you asked for, and the agent asks you once per video. New projects go to your personal space; work for your team, a brand or a client goes to the team's existing folder for it. Drafts, previews and candidates are not saved. Before the first upload from an app, you accept a one-time upload notice in your browser, and your app may ask you to approve `editor_save` (allow it for good to skip that prompt).

- **Turn auto-save off or on**: the "Auto-save work from AI apps" switch in your shuut settings, https://shuut.ai/account#apps (signed in). It applies to every app connected to your account. For one video or one conversation, just tell the agent not to save; that comes first whatever the setting. `/shuut:autosave` shows you where the switch is and can also add a line to your own agent instruction file on this computer, such as `~/.claude/CLAUDE.md` or `~/.codex/AGENTS.md` (optional; remove the line to undo; in Codex it may add an `editor_save` approval table to `config.toml`).
- **What the agent is told**: when a shell command wrote a video file (.mp4, .mov, .webm, .mkv) with ffmpeg, remotion, HandBrakeCLI, mkvmerge, MP4Box or melt, the agent gets this note in its context (not shown in the chat). It tells the agent that auto-save is your account setting and, while it is on, to upload the source files and the final video to your shuut account with `media_upload` and save them with `editor_save` after handing the video over, unless you said not to (the first use through the shuut MCP server records your account's one-time media upload notice as accepted; if you withdrew it, accept it again in your browser at shuut.ai):

  > shuut: this command made a video file (<files written>). If shuut MCP tools are available (maybe after a tool search): auto-save is the user's shuut account setting (on unless off at shuut.ai/account#apps): after handing over the final video, save it as an editable shuut project with editor_save (free); on autosave_off ask once, yes: user_requested true; not if the user said not to. Final videos only. Upload with media_upload: sources as media, the commands you ran as ffmpeg (or your edit as spec), the final render as reference. Always key: the output file path, plus the project_id you got; new: true only if asked. Team or brand work: space team, folder = the matching editor_folders name as listed. End: where it went, open_url.

  The note says the same whether auto-save is on or off: the server knows your setting, the plugin does not.

  ffprobe, playback, audio-only output, images, failed commands and video tool names that are not the command being run (an argument of `echo` or `printf`, a commit message, a here-document) get no note.
- **Claude Code and Codex**: a `PostToolUse` hook on shell commands (`hooks/`). It reads only the hook input on its standard input (the command text, and the end of the command's output to spot a failed render) and asks the file system whether each output file is a non-empty regular file modified during the command, so an old file left by an earlier run is not reported (a stat: it never opens or reads a file, skips known network and device paths, such as `//host/…`, `\\host\…`, `/net/…` or `/dev/…` also when written with `.` or `..`, and does not follow links into them). It sends nothing off your machine, writes no files and always exits 0, so it never blocks or fails a command. It runs `/bin/sh` and the standard `awk` on macOS, Linux and Git Bash, and the system PowerShell (`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe` for Codex) on Windows. Claude Code starts it mostly for commands that mention one of those tools. Codex runs it in the background after every shell command and asks you to review and trust it in `/hooks` before it first runs (it needs a POSIX `/bin/sh`; Windows execution policies that allow only signed scripts block it).
- **Cursor**: an always-on rule (`rules/save-to-shuut.mdc`) with the same note.
- **Turn the note off on this computer**: Claude Code and Codex: set `SHUUT_SAVE_REMINDER=off` or `SHUUT_AUTOSAVE=off` (the same thing; `0`, `off`, `false` or `no` in any case) in your environment (for Claude Code, also possible in the `env` block of `~/.claude/settings.json`); in Codex you can also disable the hook in `/hooks`. Cursor: delete `rules/save-to-shuut.mdc` from the installed plugin or disable the plugin. Disabling the plugin removes the hook and the rule everywhere. This only removes the note: it does not change your account setting, and the shuut server and the editor-save skill still follow it. To stop saving, turn auto-save off at https://shuut.ai/account#apps.
- The plugin ZIP for ChatGPT and claude.ai uploads leaves the hooks out (the ChatGPT plugin directory does not accept them).

Source: https://github.com/shuut-ai/shuut-mcp

License: MIT (see `LICENSE`). Using the shuut service is governed by the shuut terms: https://shuut.ai/legal/terms
