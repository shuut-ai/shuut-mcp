---
name: make-video
description: Generate videos with shuut (Seedance, Kling, Veo and other video models) from text, a first frame, first and last frames, or reference images, and extend clips. Use when the user asks to create, animate or extend a video.
---

# Make a video

1. For image-to-video, first get a `file_id` for the start image (see the upload skill, or use the `file_id` of an image you generated).
2. Optional: `models_explore` with kind "video" for model ids, lengths, ratios and per-second prices. Without `model`, shuut picks one that fits the inputs.
3. Call `generate_video` with `prompt` (and `first_frame` if any), `seconds`, `ratio` and `idempotency_key`. Use `dry_run: true` first: video is billed per second for most models (see the price-first skill).
4. Call `jobs_wait` repeatedly until `done` is true (1-5 minutes; each call waits up to 50 s).
5. Share `outputs[].url` for playback and `outputs[].original.url` for the full-resolution source when present; both expire at their stated times. The original object has file_id, url, url_expires_at, mime and, when known, bytes, width, height, seconds and codec.
6. To continue the clip, call `generate_video` with `extend_video` set to the output `file_id`.

Example arguments for `generate_video`:

```json
{ "prompt": "The camera slowly pushes in as steam rises from the cup", "first_frame": "<image_file_id>", "seconds": 5, "ratio": "9:16", "idempotency_key": "cup-video-1", "dry_run": true }
```

For a multi-shot film from a shot list, use `director_create` (`plan_write` with kind director drafts the shot list for free). For several clips at once, use `generate_video_batch` (see the batch skill).

Other ways to start a video:

- `director_frame_create` makes a first frame that keeps a product photo exact; `avatar_scene_create` makes first frames of a person presenting a product (then `avatar_video_create`).
- `story_scene_create` makes the frames of a consistent story one by one (pass the previous frame's `file_id` as `previous`; `plan_write` with kind scenes drafts them).
- `photo_template_create` and `product_app_create` turn photos into a short 9:16 video in two steps: `step` still (the first frame), then `step` video. The server writes the prompts.

## When it fails

- If `quote.seconds_adjusted` is true, the length was fitted to what the model or account allows: tell the user the billed `seconds`.
- A failed or cancelled job is refunded in full, except error.code outcome_unknown (see the price-first skill): check the same job_id later with `jobs_get` and do not resubmit.
- A photo of a real person needs the person's permission; see the upload skill for `consent`.
