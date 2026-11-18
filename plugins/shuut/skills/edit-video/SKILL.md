---
name: edit-video
description: Edit an existing video with shuut - swap a product, outfit or background, restyle, upscale to 4K, remove the background, reframe to another aspect ratio, boost fps, dub into another language, add sound or music, re-sync lips, or make it longer. Use when the user wants to change a video they already have.
---

# Edit an existing video

1. Get a `file_id` for the video (see the upload skill), or use the `file_id` of a video you generated.
2. Pick the tool:
   - `remix_video_create`: swap a product, outfit, background or object (mode swap), restyle the whole video (mode style), or replace the person (mode person; see consent).
   - `video_upscale_create`: choose `resolution` (default 4K). If the video is the playback copy of a shuut result, its `outputs[].original` may already be full resolution: download that instead.
   - `video_tools_create`: `operation` remove_background, reframe (needs `ratio`), fps_boost or depth_map.
   - `dub_video`: translate the speech into another language in the speakers' own voices.
   - `generate_audio` with `video`: add sound effects (mode sfx) or music (mode music) made for that video.
   - `avatar_video_create` mode lipsync: re-sync the mouth to a new audio file.
   - `generate_video` with `extend_video`: make it longer.
   - `motion_cut_create`: make the person in a photo perform the movement from this video.
3. Call it with `dry_run: true` to see the price and any input-limit error (length, size, resolution) before spending. Edit tools that quote started seconds show an upper bound and refund the difference after the job.
4. Call it for real, then `jobs_wait` until done.

Example arguments for `remix_video_create`:

```json
{ "mode": "swap", "source_video": "<video_file_id>", "target": "product", "images": [{ "file_id": "<product_file_id>", "role": "product" }], "idempotency_key": "swap-1", "dry_run": true }
```

## When it fails

- invalid_input before charging usually names the limit (length, size, frame size, HDR): tell the user the limit instead of guessing.
- A video showing a real person needs the person's permission; pass `consent: true` only after the user confirms (see the upload skill).
- A failed job is refunded in full, except error.code outcome_unknown (see the price-first skill).
