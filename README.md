# shuut MCP — skills and plugin

Image generation, video generation and image/video editing with GPT Image, Nano Banana, Seedream image generation, Seedance video generation, Kling and Veo: product shots, ads and avatars. Also voice, music and captions. Billed to your shuut credits. 1 credit = 1 US cent, same prices as the shuut app. Pass `dry_run: true` first to any paid tool for the exact price without spending; `max_spend_credits` caps a call.

- MCP server: `https://shuut.ai/mcp` (Streamable HTTP, OAuth sign-in with your shuut account — no API key)
- Setup guide: https://shuut.ai/mcp
- This repository is generated from the shuut source; edits here are overwritten.

## Install

| Where | How |
|---|---|
| Claude Code | `/plugin marketplace add Doers-Corp/shuut-mcp` then `/plugin install shuut@shuut-mcp` |
| claude.ai / Claude Desktop / Cowork | Customize → Plugins → Add marketplace → `Doers-Corp/shuut-mcp`, install **shuut**, then connect shuut on the plugin's Connectors tab |
| Codex / ChatGPT desktop | `codex plugin marketplace add Doers-Corp/shuut-mcp`, then install **shuut** from the Plugins Directory |
| Any MCP client | Add the server `https://shuut.ai/mcp`; the same skills are served by the server itself (prompts, `skill://shuut/<name>/SKILL.md` resources, and the `get_workflow_instructions` tool) |

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

Source: https://github.com/Doers-Corp/shuut-mcp

License: MIT (see `LICENSE`). Using the shuut service is governed by the shuut terms: https://shuut.ai/legal/terms
