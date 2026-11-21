<p align="center">
  <a href="https://shuut.ai/mcp"><img src=".github/assets/banner.jpg" alt="shuut MCP: make and edit images, videos and audio from your AI assistant" width="100%"></a>
</p>

<p align="center">
  <a href="https://registry.modelcontextprotocol.io/?q=ai.shuut%2Fshuut"><img alt="MCP Registry: ai.shuut/shuut" src="https://img.shields.io/badge/MCP_Registry-ai.shuut%2Fshuut-d7ff3a?labelColor=0b0b0c"></a>
  <a href="https://cursor.directory/plugins/shuut"><img alt="cursor.directory" src="https://img.shields.io/badge/cursor.directory-shuut-d7ff3a?labelColor=0b0b0c"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-d7ff3a?labelColor=0b0b0c"></a>
</p>

<p align="center">
  <a href="https://shuut.ai">shuut.ai</a> · <a href="https://shuut.ai/mcp">Setup guide</a> · <a href="#install">Install</a> · <a href="#example-one-video-start-to-finish">Example</a> · <a href="#skills">Skills</a> · <a href="#subagents">Subagents</a>
</p>

Image generation, video generation and image/video editing with GPT Image, Nano Banana, Seedream image generation, Seedance video generation, Kling and Veo: product shots, ads and avatars. Also voice, music and captions. Billed to your shuut credits. 1 credit = 1 US cent, same prices as the shuut app. Pass `dry_run: true` first to any paid tool for the exact price without spending; `max_spend_credits` caps a call.

- **Server**: `https://shuut.ai/mcp` (Streamable HTTP, OAuth sign-in with your shuut account — no API key)
- **Skills**: 13 step-by-step workflows, also served by the server itself
- **Subagents**: 2 helpers (Ad director, Variant runner) for Claude Code, Cursor and Codex; the ones that spend quote with `dry_run` first and create only after you approve the price
- This repository is generated from the shuut source; edits here are overwritten.

## Install

**One click**

<a href="https://claude.ai/customize/connectors?modal=add-custom-connector&connectorName=shuut&connectorUrl=https%3A%2F%2Fshuut.ai%2Fmcp"><img alt="Add to Claude" src="https://img.shields.io/badge/Add_to_Claude-0b0b0c?style=for-the-badge&logo=claude&logoColor=d7ff3a"></a>
<a href="https://cursor.com/install-mcp?name=shuut&config=eyJ1cmwiOiJodHRwczovL3NodXV0LmFpL21jcCJ9"><img alt="Add to Cursor" src="https://img.shields.io/badge/Add_to_Cursor-0b0b0c?style=for-the-badge&logo=cursor&logoColor=d7ff3a"></a>
<a href="https://vscode.dev/redirect/mcp/install?name=shuut&config=%7B%22type%22%3A%22http%22%2C%22url%22%3A%22https%3A%2F%2Fshuut.ai%2Fmcp%22%7D"><img alt="Install in VS Code" src="https://img.shields.io/badge/Install_in_VS_Code-0b0b0c?style=for-the-badge"></a>

**Plugin** (skills and the server together)

| Where | How |
|---|---|
| Claude Code | `/plugin marketplace add shuut-ai/shuut-mcp` then `/plugin install shuut@shuut-mcp` |
| claude.ai / Claude Desktop / Cowork | Customize → Plugins → Add marketplace → `shuut-ai/shuut-mcp`, install **shuut**, then connect shuut on the plugin's Connectors tab |
| Codex / ChatGPT desktop | `codex plugin marketplace add shuut-ai/shuut-mcp`, then install **shuut** from the Plugins Directory |
| Cursor (Teams and Enterprise plans) | Dashboard → Plugins & MCPs → Team Marketplaces → Add Marketplace → Import from Repo → `https://github.com/shuut-ai/shuut-mcp`, then install **shuut** |
| Any MCP client | Add the server `https://shuut.ai/mcp`; the same skills are served by the server itself (prompts, `skill://shuut/<name>/SKILL.md` resources, and the `get_workflow_instructions` tool) |

**Server only** (terminal)

```sh
claude mcp add --transport http --scope user shuut https://shuut.ai/mcp
codex mcp add shuut --url https://shuut.ai/mcp
```

**Codex notes**

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

**VS Code and Cursor**: shuut has about 68 tools. If the app says a request has too many tools (VS Code allows 128 per request), turn off the shuut tools you do not use in its tool picker (VS Code: Configure Tools).

**Skills only** (any agent that reads Agent Skills; add the server above for the tools)

```sh
npx skills add shuut-ai/shuut-mcp
gh skill install shuut-ai/shuut-mcp --all   # GitHub CLI 2.94+
```

## Example: one video, start to finish

Ask your agent, for example:

> Make a 30-second vertical promo for my app with shuut only: write the script, read it in my cloned voice, add a stock presenter, three generated scenes and my screen recording demo.mov, background music, big captions and my logo, then give me the editable project and the MP4. Show me the total price first.

The agent follows the `promo-video` skill: `media_upload` for local files, `generate_audio` (voice, music, sound effects) or `voice_clone_phrase` + `voice_clone_create` (your own voice, with your consent), `avatar_video_create`, `generate_video` / `generate_image`, then `editor_save` (cuts, transitions, captions, logo, blurred background) and `editor_export` for the MP4. Every paid step is priced with `dry_run` first; editing, saving and exporting are free. A video the agent edited with ffmpeg or another tool can be saved with `editor_save` too (the agent offers it, or saves every time if you turn on `/shuut:autosave`), so you can keep editing it in the shuut editor; making the same video again updates that project instead of adding a new one.

## Skills

| Skill | Command | When it is used |
|---|---|---|
| `price-first` | `/shuut:price-first` | Check the exact shuut price before spending credits, then create. Use before any paid shuut tool (images, videos, audio, edits, batches) or when the user asks what something costs, how many credits they have, or why a job was refunded. |
| `upload` | `/shuut:upload` | Bring the user's own image, video or audio file (or a font for editor captions) into shuut and get a file_id for other shuut tools. Use when the user gives a local file or a public URL to use in shuut (to edit, transcribe or pass to another tool as an input). |
| `make-image` | `/shuut:make-image` | Generate images with shuut (GPT Image, Nano Banana, Seedream and other image models) from a text prompt and optional reference images. Use when the user asks to create, draw or render a picture, poster, product shot or illustration. |
| `make-video` | `/shuut:make-video` | Generate videos with shuut (Seedance, Kling, Veo and other video models) from text, a first frame, first and last frames, or reference images, and extend clips. Use when the user asks to create, animate or extend a video. |
| `edit-photo` | `/shuut:edit-photo` | Edit an existing image with shuut - fill or erase a masked area, cut out the background, expand to a new ratio, relight, change the camera angle, replace text, upscale to 4K, split into layers, retouch skin, make a sheet of alternate shots, or try a garment on a person. Use when the user wants to change a photo they already have. |
| `edit-video` | `/shuut:edit-video` | Edit an existing video with shuut - swap people, outfits, objects or the background (SWAP), move a video's motion onto new people and places, upscale to 4K, remove the background, reframe to another aspect ratio, boost fps, dub into another language, add sound or music, re-sync lips, or make it longer. Use when the user wants to change a video they already have. |
| `voice-music` | `/shuut:voice-music` | Make voice-overs, multi-speaker dialogue, background music and sound effects with shuut, clone the user's own voice, or score and dub an existing video. Use when the user asks for narration, text to speech, a voice, their own voice, music, a jingle, a sound effect or captions timing. |
| `product-ad` | `/shuut:product-ad` | Turn a product photo into ad creative with shuut - clean cut-outs, styled product shots, finished ad images with headline and CTA, ad copy, claim screening, translation, and an animated product video. Use when the user wants ads, product shots or marketing images for a product. |
| `batch` | `/shuut:batch` | Run many shuut generations or edits at once - several images, videos, audio clips, cut-outs or product shots in one call - and collect all results. Use when the user asks for variations, a set of ads, many clips or bulk work. |
| `autosave` | `/shuut:autosave` | Turn shuut auto-save on or off - with the user's OK, add one line to the user's own instruction file so that every video the agent finishes or edits (also with ffmpeg or other local tools) is saved to the user's private shuut editor projects without asking each time. Use when the user wants videos always saved to shuut, asks to turn auto-save on or off, accepts an offer to save every video, or wants the agent to use shuut first for media work. |
| `editor-save` | `/shuut:editor-save` | Save a finished or edited video as a shuut editor project the user can open and keep editing, with every source, caption, font and background kept separate, and update the same project when the video changes. Use whenever you produced or edited a video, including with ffmpeg or other local tools, and when asked for an editable project, an MP4 export or changes to a saved edit. |
| `promo-video` | `/shuut:promo-video` | Make a whole promo, ad, product, launch or explainer video with shuut - script, voice-over or the user's own cloned voice, a talking avatar, generated scenes and screen captures, music and sound effects, cuts, transitions, big captions, logo, blurred background and covering burned-in text - then save it as an editable shuut project and export the final MP4. Use when the user asks for a promo video, an ad video or a reel made with shuut, or for saving or finishing a video edit in shuut, including one made or edited with other tools. |
| `short-drama` | `/shuut:short-drama` | Turn a script or a one-line idea into a vertical short-drama series with shuut — episodes, recurring characters with character sheets, and clips where the characters speak their lines. Use when the user asks for a short drama, a web drama, a series of episodes or talking story clips. |

## Subagents

Separate helpers the main conversation can hand a job to. They cannot ask you anything themselves: the ones that spend come back with the plan and the exact price from `dry_run`, and create only after you approve that total (capped with `max_spend_credits`).

| Claude Code · Cursor | Codex | When it is used |
|---|---|---|
| `shuut:ad-director` | `shuut_ad_director` | Plans a shuut ad from a product (script, concepts, formats), prices every paid step with dry_run and returns the quote, then creates only after the user approves that exact total. Use when the user wants an ad or a set of ads made with shuut. |
| `shuut:variant-runner` | `shuut_variant_runner` | Makes several versions of one shuut request (prompts, angles, ratios, models or photos) with batch calls of up to 8 - prices each batch with dry_run and returns the quotes, then runs a batch only after the user approves that batch's exact total. Use for variations, A/B sets or the same edit on many photos. |

- **Claude Code and Cursor**: included in the plugin (`agents/`); in Claude Code call one with `@agent-shuut:<name>`.
- **Codex**: plugins cannot carry subagents, so copy the files in `.codex/agents/` to `~/.codex/agents/` (they use the shuut tools of the session, so install the plugin or add the server too):

```sh
mkdir -p ~/.codex/agents && for a in shuut_ad_director shuut_variant_runner; do curl -fsSL https://raw.githubusercontent.com/shuut-ai/shuut-mcp/main/.codex/agents/$a.toml -o ~/.codex/agents/$a.toml; done
```

## Save reminder

A video your agent renders with ffmpeg or another local tool is hard to fine-tune afterwards. So the plugin reminds the agent that it can save it as a project in the shuut editor with `editor_save` (free: no credits, not counted in the project limit; fair use 300 new projects a day), where you can keep editing it. The agent saves without asking you first only if you turned on auto-save with `/shuut:autosave` (it adds one line to your own agent instruction file, such as `~/.claude/CLAUDE.md` or `~/.codex/AGENTS.md`, and in Codex may add an `editor_save` approval table to `config.toml`; remove the line and that table to turn it off); otherwise it offers once per chat after handing over the video, and not again after you say no.

- **What the agent is told**: when a shell command wrote a video file (.mp4, .mov, .webm, .mkv) with ffmpeg, remotion, HandBrakeCLI, mkvmerge, MP4Box or melt, the agent gets this note in its context (not shown in the chat). If you turned on auto-save, it asks the agent to upload the source files and the final video to your shuut account with `media_upload` and save them with `editor_save` **without asking you first**; otherwise to offer it once (before the first upload from an app, you accept a one-time upload notice in your browser):

  > shuut: this command made a video file (<files written>). If shuut MCP tools are available (maybe after a tool search) and the user's own instructions turned on shuut auto-save, save it as an editable shuut project with editor_save (free: no credits, not counted in the project limit; fair use 300 new projects a day) without asking; otherwise offer it once per chat, not again after a no (/shuut:autosave). Only final videos: not files a later command reads, previews, candidates, or if the user said no. Upload with media_upload: sources as media, the commands you ran as ffmpeg (or your edit as spec), the final render as reference (editor-save skill). Always key: the output file path, plus the project_id you got; new: true only if asked.

  ffprobe, playback, audio-only output, images, failed commands and video tool names that are not the command being run (an argument of `echo` or `printf`, a commit message, a here-document) get no note.
- **Claude Code and Codex**: a `PostToolUse` hook on shell commands (`hooks/`). It reads only the hook input on its standard input (the command text, and the end of the command's output to spot a failed render) and asks the file system whether each output file is a non-empty regular file (a stat: it never opens or reads a file, skips known network and device paths, such as `//host/…`, `\\host\…`, `/net/…` or `/dev/…` also when written with `.` or `..`, and does not follow links into them). It sends nothing off your machine, writes no files and always exits 0, so it never blocks or fails a command. It runs `/bin/sh` and the standard `awk` on macOS, Linux and Git Bash, and the system PowerShell (`C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe` for Codex) on Windows. Claude Code starts it mostly for commands that mention one of those tools. Codex runs it in the background after every shell command and asks you to review and trust it in `/hooks` before it first runs (it needs a POSIX `/bin/sh`; Windows execution policies that allow only signed scripts block it).
- **Cursor**: an always-on rule (`rules/save-to-shuut.mdc`) with the same note.
- **Turn it off**: Claude Code and Codex: set `SHUUT_SAVE_REMINDER=off` in your environment (for Claude Code, also possible in the `env` block of `~/.claude/settings.json`); in Codex you can also disable the hook in `/hooks`. Cursor: the variable does not reach the rule, so delete `rules/save-to-shuut.mdc` from the installed plugin or disable the plugin. Disabling the plugin removes the hook and the rule everywhere.
- The plugin ZIP for ChatGPT and claude.ai uploads leaves the hooks out (the ChatGPT plugin directory does not accept them).

Source: https://github.com/shuut-ai/shuut-mcp

License: MIT (see `LICENSE`). Using the shuut service is governed by the shuut terms: https://shuut.ai/legal/terms
