# shuut for Claude

Image generation, video generation and image/video editing with GPT Image, Nano Banana, Seedream image generation, Seedance video generation, Kling and Veo: product shots, ads and avatars. Also voice, music and captions. Billed to your shuut credits. 1 credit = 1 US cent, same prices as the shuut app. Paid tools run at once; with `dry_run: true` they return the exact price without spending, and `max_spend_credits` caps a call.

## Set up

1. Add **shuut** from the Claude directory (Customize → Plugins).
2. Open the plugin's **Connectors** tab and connect **shuut**, then sign in with your shuut account (free signup at https://shuut.ai). You choose whether Claude may create and spend credits, or only read.
3. Ask for what you want, for example: "Make a 9:16 product photo of my sneaker on wet asphalt at night."

Paid tools spend shuut credits as soon as they run (1 credit = 1 US cent, the same prices as the shuut app). Ask for the price first and Claude shows it before anything is made.

## Skills

- `upload`: Bring the user's own image, video or audio file (or a font for editor captions) into shuut and get a file_id for other shuut tools. Use when the user gives a local file or a public URL to use in shuut (to edit, transcribe or pass to another tool as an input).
- `make-image`: Generate images with shuut (GPT Image, Nano Banana, Seedream and other image models) from a text prompt and optional reference images. Use when the user asks to create, draw or render a picture, poster, product shot or illustration.
- `make-video`: Generate videos with shuut (Seedance, Kling, Veo and other video models) from text, a first frame, first and last frames, or reference images, and extend clips. Use when the user asks to create, animate or extend a video.
- `edit-photo`: Edit an existing image with shuut - fill or erase a masked area, cut out the background, expand to a new ratio, relight, change the camera angle, replace text, upscale to 4K, split into layers, retouch skin, make a sheet of alternate shots, or try a garment on a person. Use when the user wants to change a photo they already have.
- `edit-video`: Edit an existing video with shuut - swap people, outfits, objects or the background (SWAP), move a video's motion onto new people and places, upscale to 4K, remove the background, reframe to another aspect ratio, boost fps, dub into another language, add sound or music, re-sync lips, or make it longer. Use when the user wants to change a video they already have.
- `voice-music`: Make voice-overs, multi-speaker dialogue, background music and sound effects with shuut, clone the user's own voice, or score and dub an existing video. Use when the user asks for narration, text to speech, a voice, their own voice, music, a jingle, a sound effect or captions timing.
- `product-ad`: Turn a product photo into ad creative with shuut - clean cut-outs, styled product shots, finished ad images with headline and CTA, ad copy, claim screening, translation, and an animated product video. Use when the user wants ads, product shots or marketing images for a product.
- `batch`: Run many shuut generations or edits at once - several images, videos, audio clips, cut-outs or product shots in one call - and collect all results. Use when the user asks for variations, a set of ads, many clips or bulk work.
- `price-check`: Check shuut prices, credits and refunds - quote a paid shuut call with dry_run before making it, cap what it may spend, read the balance, usage and refunds. Use when the user asks what something costs, how many credits they have or used, or why a job was refunded, wants to see the price before deciding, or sets a budget.
- `autosave`: Turn shuut auto-save off or back on. Auto-save is a setting of the user's shuut account, on by default and changed in the shuut settings at https://shuut.ai/account#apps; while it is on, every finished or edited video the agent hands over (also made with ffmpeg or other local tools) is saved to the user's shuut editor projects. Optionally, with the user's OK, add one line to the user's own instruction file on this computer. Use when the user wants videos no longer (or again) saved to shuut, or asks whether videos are saved automatically.
- `default`: Turn shuut on or off as the user's default for media work - with the user's OK, add one line to the user's own agent instruction file (CLAUDE.md, AGENTS.md, GEMINI.md) or give the line to paste into their settings. Use when the user wants shuut used by default for creating or editing images, video, voice or music, or wants that setting removed.
- `editor-save`: Save a finished or edited video as a shuut editor project the user can open and keep editing, with every source, caption, font and background kept separate, in the user's personal space or a team folder, and update the same project when the video changes. Auto-save is a setting of the user's shuut account (on by default, changed at https://shuut.ai/account#apps); while it is on, final videos you hand over are saved. Use whenever you produced or edited a video, including with ffmpeg or other local tools, and when asked for an editable project, a team or brand folder, an MP4 export or changes to a saved edit.
- `promo-video`: Make a whole promo, ad, product, launch or explainer video with shuut - script, voice-over or the user's own cloned voice, a talking avatar, generated scenes and screen captures, music and sound effects, cuts, transitions, big captions, logo, blurred background and covering burned-in text - then save it as an editable shuut project and export the final MP4. Use when the user asks for a promo video, an ad video or a reel made with shuut, or for saving or finishing a video edit in shuut, including one made or edited with other tools.
- `short-drama`: Turn a script or a one-line idea into a vertical short-drama series with shuut — episodes, recurring characters with character sheets, and clips where the characters speak their lines. Use when the user asks for a short drama, a web drama, a series of episodes or talking story clips.

## Subagents

- `ad-director`: Plans a shuut ad from a product (script, concepts, formats) and makes it with the paid shuut tools; when the task asks to see the price first or sets a budget, it prices every paid step with dry_run and returns the quote, then creates only after that total is approved. Use when the user wants an ad or a set of ads made with shuut.
- `variant-runner`: Makes several versions of one shuut request (prompts, angles, ratios, models or photos) with batch calls of up to 8; when the task asks to see the price first or sets a budget, it prices each batch with dry_run and returns the quotes, then runs a batch only after that batch's exact total is approved. Use for variations, A/B sets or the same edit on many photos.

## Privacy and support

- Privacy policy: https://shuut.ai/legal/privacy?lang=en
- Terms: https://shuut.ai/legal/terms?lang=en
- Support: help@shuut.ai
- Setup guide: https://shuut.ai/mcp?tab=claude
