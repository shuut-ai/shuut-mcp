---
name: edit-video
description: Edit an existing video with shuut - swap people, outfits, objects or the background (SWAP), move a video's motion onto new people and places, upscale to 4K, remove the background, reframe to another aspect ratio, boost fps, dub into another language, add sound or music, re-sync lips, or make it longer. Use when the user wants to change a video they already have.
---

# Edit an existing video

1. Get a `file_id` for the video (see the upload skill), or use the `file_id` of a video you generated.
2. Pick the tool:
   - SWAP (4 s or longer; the first 30 s is used): first `swap_find_people` with the video — it returns the people (ids p1, p2 … and face pictures). Then `swap_video_create`:
     mode `object` changes only the chosen people (whole look, face and hair, or outfit — each person needs a photo), objects or the background and keeps everything else as filmed;
     mode `motion` keeps only the movement, camera and cuts and redraws the people and the place (`location` photo or text, optional `style`).
   - `video_upscale_create`: choose `resolution` (default 4K). If the video is the playback copy of a shuut result, its `outputs[].original` may already be full resolution: download that instead.
   - `video_tools_create`: `operation` remove_background, reframe (needs `ratio`), fps_boost or depth_map.
   - `dub_video`: translate the speech into another language in the speakers' own voices.
   - `generate_audio` with `video`: add sound effects (mode sfx) or music (mode music) made for that video.
   - `avatar_video_create` mode lipsync: re-sync the mouth to a new audio file.
   - `generate_video` with `extend_video`: make it longer.
3. Call it with `dry_run: true` to see the price and any input-limit error (length, size, resolution) before spending. Edit tools that quote started seconds show an upper bound and refund the difference after the job.
4. Call it for real, then `jobs_wait` until done.

Call `swap_find_people` first; once it returned the person p1:

Example arguments for `swap_video_create`:

```json
{ "mode": "object", "video": "<video_file_id>", "photos": ["<person_photo_file_id>"], "targets": [{ "person": "p1", "photo": 0, "change": "person" }], "idempotency_key": "swap-1", "dry_run": true }
```

## When it fails

- invalid_input before charging usually names the limit (length, size, frame size, HDR): tell the user the limit instead of guessing.
- swap_analysis_missing: call `swap_find_people` with the video again. swap_invalid: read `problem` (a target without a photo, an unused photo, an unknown person id …).
- A video or photo showing a real person needs the person's permission; pass `consent: true` only after the user confirms (see the upload skill).
- A failed job is refunded in full, except error.code outcome_unknown (see the price-first skill).
