---
name: make-video
description: Generate videos with shuut (Seedance, Kling, Veo and other video models) from text, a first frame, first and last frames, or reference images, and extend clips. Use when the user asks to create, animate or extend a video.
---

# Make a video

1. For image-to-video, first get a `file_id` for the start image (see the upload skill, or use the `file_id` of an image you generated).
2. Optional: `models_explore` with kind "video" lists model ids and per-second prices (a short summary row each); for one model's lengths, ratios and resolutions, call it again with model set to that exact id, or with `fields` "full". Without `model`, shuut picks one that fits the inputs.
3. Call `generate_video` with `prompt` (and `first_frame` if any), `seconds`, `ratio` and `idempotency_key`; it charges at once (video is billed per second for most models). Only when the user asks for the price first or sets a budget, call it with `dry_run: true` before that (see the price-check skill). With a `first_frame`, most models make the video in that picture's shape: leave `ratio` out (or give the picture's own ratio). For another shape, first make the picture in that ratio (`image_edit` operation expand, or `resize_image`) and pass that `file_id` as `first_frame`; a ratio far from the picture's is refused before anything is charged.
4. Call `jobs_wait` repeatedly until `done` is true (1-5 minutes; each call waits up to 50 s).
5. Share `outputs[].url` for playback and `outputs[].original.url` for the full-resolution source when present; both expire at their stated times. The original object has file_id, url, url_expires_at, mime and, when known, bytes, width, height, seconds and codec.
6. To continue the clip, call `generate_video` with `extend_video` set to the output `file_id`. To start the next shot from where this one ends, `video_frame` (free) turns the clip's last frame into an image `file_id`; pass it as `first_frame` of the next `generate_video`.
7. To make one finished video from several clips, voice and music (cuts, captions, logo), pass their `file_id`s to `editor_save`, then `editor_export` for the MP4 (or WebM, GIF, M4A, WAV) (see the promo-video and editor-save skills).

Example arguments for `generate_video`:

```json
{ "prompt": "The camera slowly pushes in as steam rises from the cup", "first_frame": "<image_file_id>", "seconds": 5, "idempotency_key": "cup-video-1" }
```

For a multi-shot film from a shot list, use `director_create` (`plan_write` with kind director drafts the shot list for free); to compare takes cheaply, make 480p drafts with `draft: true` and finalize only the chosen one with `director_finalize` (within 14 days, same take). For several clips at once, use `generate_video_batch` (see the batch skill). shuut expands a short prompt for the model; when you send an exact, detailed prompt (for example to Seedance) and want it used word for word, pass `enhance: false`.

Other ways to start a video:

- `director_frame_create` makes a first frame that keeps a product photo exact; `avatar_scene_create` makes first frames of a person presenting a product (then `avatar_video_create`).
- `avatar_video_create` makes a person talk to an audio file: mode photo, lipsync, stock (a stock presenter, no photo needed) or product_review. `models_explore` kind video rows with `avatar_mode` (ask with `fields` "full") are the other models for that mode (pass the id as `model`; stock rows list `avatars`).
- `story_scene_create` makes the frames of a consistent story one by one (pass the previous frame's `file_id` as `previous`; `plan_write` with kind scenes drafts them).
- `photo_template_create` turns a photo into a short 9:16 video in two steps: `step` still (the first frame), then `step` video. The server writes the prompts.

## When it fails

- If `quote.seconds_adjusted` is true, the length was fitted to what the model or account allows: tell the user the billed `seconds`.
- A failed or cancelled job is refunded in full, except error.code outcome_unknown (see the price-check skill): check the same job_id later with `jobs_get` and do not resubmit.
- A photo of a real person needs the person's permission; see the upload skill for `consent`.
