<p align="center">
  <a href="https://shuut.ai/mcp"><img src=".github/assets/banner.jpg" alt="shuut MCP: make and edit images, videos and audio from your AI assistant" width="100%"></a>
</p>

<p align="center">
  <a href="https://registry.modelcontextprotocol.io/?q=ai.shuut%2Fshuut"><img alt="MCP Registry: ai.shuut/shuut" src="https://img.shields.io/badge/MCP_Registry-ai.shuut%2Fshuut-d7ff3a?labelColor=0b0b0c"></a>
  <a href="https://cursor.directory/plugins/shuut"><img alt="cursor.directory" src="https://img.shields.io/badge/cursor.directory-shuut-d7ff3a?labelColor=0b0b0c"></a>
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-d7ff3a?labelColor=0b0b0c"></a>
</p>

<p align="center">
  <a href="https://shuut.ai">shuut.ai</a> · <a href="https://shuut.ai/mcp">Setup guide</a> · <a href="#install">Install</a> · <a href="#skills">Skills</a>
</p>

Image generation, video generation and image/video editing with GPT Image, Nano Banana, Seedream image generation, Seedance video generation, Kling and Veo: product shots, ads and avatars. Also voice, music and captions. Billed to your shuut credits. 1 credit = 1 US cent, same prices as the shuut app. Pass `dry_run: true` first to any paid tool for the exact price without spending; `max_spend_credits` caps a call.

- **Server**: `https://shuut.ai/mcp` (Streamable HTTP, OAuth sign-in with your shuut account — no API key)
- **Skills**: 10 step-by-step workflows, also served by the server itself
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
| Any MCP client | Add the server `https://shuut.ai/mcp`; the same skills are served by the server itself (prompts, `skill://shuut/<name>/SKILL.md` resources, and the `get_workflow_instructions` tool) |

**Server only** (terminal)

```sh
claude mcp add --transport http shuut https://shuut.ai/mcp
codex mcp add shuut --url https://shuut.ai/mcp
```

## Skills

| Skill | Command | When it is used |
|---|---|---|
| `price-first` | `/shuut:price-first` | Check the exact shuut price before spending credits, then create. Use before any paid shuut tool (images, videos, audio, edits, batches) or when the user asks what something costs, how many credits they have, or why a job was refunded. |
| `upload` | `/shuut:upload` | Bring the user's own image, video or audio file into shuut and get a file_id for other shuut tools. Use when the user gives a local file or a public URL to edit, animate, dub or use as a reference. |
| `make-image` | `/shuut:make-image` | Generate images with shuut (GPT Image, Nano Banana, Seedream and other image models) from a text prompt and optional reference images. Use when the user asks to create, draw or render a picture, poster, product shot or illustration. |
| `make-video` | `/shuut:make-video` | Generate videos with shuut (Seedance, Kling, Veo and other video models) from text, a first frame, first and last frames, or reference images, and extend clips. Use when the user asks to create, animate or extend a video. |
| `edit-photo` | `/shuut:edit-photo` | Edit an existing image with shuut - fill or erase a masked area, cut out the background, expand to a new ratio, relight, change the camera angle, replace text, upscale to 4K, split into layers, retouch skin, make a sheet of alternate shots, or try a garment on a person. Use when the user wants to change a photo they already have. |
| `edit-video` | `/shuut:edit-video` | Edit an existing video with shuut - swap a product, outfit or background, restyle, upscale to 4K, remove the background, reframe to another aspect ratio, boost fps, dub into another language, add sound or music, re-sync lips, or make it longer. Use when the user wants to change a video they already have. |
| `voice-music` | `/shuut:voice-music` | Make voice-overs, multi-speaker dialogue, background music and sound effects with shuut, or score and dub an existing video. Use when the user asks for narration, text to speech, a voice, music, a jingle, a sound effect or captions timing. |
| `product-ad` | `/shuut:product-ad` | Turn a product photo into ad creative with shuut - clean cut-outs, styled product shots, finished ad images with headline and CTA, ad copy, claim screening, translation, and an animated product video. Use when the user wants ads, product shots or marketing images for a product. |
| `batch` | `/shuut:batch` | Run many shuut generations or edits at once - several images, videos, audio clips, cut-outs or product shots in one call - and collect all results. Use when the user asks for variations, a set of ads, many clips or bulk work. |
| `ad-studio` | `/shuut:ad-studio` | Turn a product page or product photos into a fact-checked video ad script with shuut's Ad studio (ad_run_start, ad_run_get, ad_run_change, ad_run_make). Use when the user wants a product video ad script or storyboard from a URL or photos. |

Source: https://github.com/shuut-ai/shuut-mcp

License: MIT (see `LICENSE`). Using the shuut service is governed by the shuut terms: https://shuut.ai/legal/terms
