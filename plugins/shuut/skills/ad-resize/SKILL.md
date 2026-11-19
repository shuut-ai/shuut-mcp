---
name: ad-resize
description: Make 4:5, 1:1 or 16:9 versions of a shuut Ad studio ad, with captions, offer card and safe areas laid out again for each ratio, reusing the materials already made. Use when the user needs the same ad for feed, square or landscape placements.
---

# Same ad, other ratios

Ad studio ads are made vertical (9:16). A ratio version is a new run in the same family that lays the captions, offer card and safe areas out again for its ratio and reuses the materials.

1. Start from a run whose materials are made (see the ad-studio skill).
2. Ask for the ratios in one call with `ad_run_change`: `action` "variant", the current `rev` and `ratio`, a list of 1-3 of "4:5", "1:1" and "16:9". Building ratio versions is free. One call makes one kind of variant: ratios, hooks (hook-variants skill) or languages (ad-localize skill). A vertical shot in 16:9 keeps its full frame with side margins; it is not cropped.
3. The result lists `variants` for the family, the original included: each with its own `run_id`, ratio, state, quoted credits and open URL.
4. Check the price with `ad_run_make` on the new `run_id`: its `rev`, a fresh `idempotency_key`, `max_spend_credits` and `dry_run: true`. A ratio version usually costs 0 because it only lays out and renders again; tell the user the quoted price either way.
5. When the user agrees, call `ad_run_make` again without `dry_run`, with the same `idempotency_key`.
6. Give the user each version's open URL: the final video is made in their browser with the "Merge into video" button. Do not say it is finished before that. If the editor notes that text was shrunk to fit the ratio (ratio_text_small), ask the user to check that it is still readable on a phone.

Example arguments for `ad_run_change`:

```json
{ "run_id": "r7Kq2mXa9", "action": "variant", "rev": 6, "ratio": ["4:5", "1:1"] }
```

## Keep it honest

- Say which placements each ratio is for only as the user's choice; do not promise reach or performance.
