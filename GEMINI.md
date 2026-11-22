# shuut extension

This extension connects the shuut MCP server (https://shuut.ai/mcp) for making and editing images, video, voice, music and captions, and adds 14 shuut skills in `skills/` (price-first, upload, make-image, make-video, edit-photo, edit-video, voice-music, product-ad, batch, autosave, default, editor-save, promo-video, short-drama).

- First use: run `/mcp auth shuut` and sign in with your shuut account in the browser (OAuth, no API key).
- Paid shuut tools spend credits. Before a paid call, follow the price-first skill: call it with `dry_run: true` and show the user the price first.
