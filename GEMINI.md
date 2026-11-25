# shuut extension

This extension connects the shuut MCP server (https://shuut.ai/mcp) for making and editing images, video, voice, music and captions, and adds 15 shuut skills in `skills/` (upload, make-image, make-video, edit-photo, edit-video, voice-music, product-ad, batch, price-check, auto-update, autosave, default, editor-save, promo-video, short-drama).

- First use: run `/mcp auth shuut` and sign in with your shuut account in the browser (OAuth, no API key).
- Paid shuut tools spend credits as soon as they run. When the user asks for the price first or sets a budget, follow the price-check skill: call the tool with `dry_run: true` and show the price first.
