---
name: short-drama
description: Turn a script or a one-line idea into a vertical short-drama series with shuut — episodes, recurring characters with character sheets, and clips where the characters speak their lines. Use when the user asks for a short drama, a web drama, a series of episodes or talking story clips.
---

# Short drama: script to talking clips

There is no single server tool for this: you plan the series yourself, then make the pictures and clips with the regular paid tools. The shuut app's Short Drama Studio does the same steps with a free analysis and storyboard.

1. Read the script (or the idea) and split it into episodes in story order. For each episode write a title, the hook of its first 3 seconds and the cliffhanger it ends on. List the recurring characters (name, apparent age, look, outfit, voice) and the places. Keep names the script gives; never use a real person's or a celebrity's name or likeness, and for photorealistic series make every character an adult.
2. Break each episode into clips of 4 to 15 seconds: one place per clip, one to four shots, and the lines spoken in it. Keep each line short enough to say in its shot (about 6 Korean syllables or 2.5 English words per second). Avoid readable screens, signs, clocks and crowds — video models break on them.
3. Show the user the plan and the price before spending: call each create tool with `dry_run: true` first (see the price-first skill), add up `cost_credits`, and wait for their approval.
4. Make one character sheet per recurring character with `story_scene_create`: the scene asks for the same person shown full body from the front, the side and the back plus a face close-up on a plain grey background with no text; the setting carries the look and the art style. Call `jobs_wait` until `done` is true and keep each output `file_id`.
5. Make each clip with `generate_video`: put the character sheets (and a place picture if you made one) in `reference_images`, name who is in which image in the prompt, describe the shots in order, and write every spoken line inside quotation marks in the script's language. Use quotation marks only for spoken lines — describe a sign or a note without quoting it, or it may be spoken. On models that can speak (Kling 4.0, Seedance 2.5, Omni 1.2 Flash, Veo 3.1 and Veo 3.1 Fast), shuut tells the model to say only the quoted lines, word for word, with lip sync; other models get no speech. For photorealistic characters use `model` klingai/kling-v4 — it is the engine that keeps real-looking faces from reference images. Keep `ratio`, `resolution` and the reference images the same for every clip of a series.
6. Call `jobs_wait` with all the clip `job_ids` and `include_results: true` until every job is done, then share each output in episode order; if its `note` says only the first jobs carry files, get the others' outputs with `jobs_result`. When a clip should continue exactly where the previous one ends, `video_frame` (free) gives the previous clip's last frame as an image `file_id`: pass it as `first_frame` of the next `generate_video`.
7. To join an episode into one video, stay in shuut: call `editor_save` with `media` (the clip file ids), `spec` holding one shots item per clip in story order (see the editor-save skill), `key` = a name for that episode (for example `drama/ep01.mp4`) and an `idempotency_key`. It is free, and the user gets an editable project (`open_url`). For the MP4, call `editor_export` with the `project_id` and an `idempotency_key`.

Example arguments for `story_scene_create`:

```json
{ "scene": "Character sheet of Hayun: full body front, side and back views and a face close-up, plain grey background, no text", "setting": "Photorealistic Korean TV drama look. Hayun: woman in her late twenties, shoulder-length straight black hair, cream trench coat over a navy knit", "ratio": "16:9", "idempotency_key": "drama-hayun-sheet", "dry_run": true }
```

Example arguments for `generate_video`:

```json
{ "prompt": "Image 1 is Hayun, image 2 is Dohyun. Rooftop at dusk. Shot 1 (0-4s): medium shot, slow push-in: Hayun turns to Dohyun. Hayun (shaky): \"Why tell me now?\" Shot 2 (4-8s): close-up of Dohyun, static. Dohyun (quietly): \"I was scared.\" No subtitles or on-screen text.", "model": "klingai/kling-v4", "reference_images": ["<hayun_sheet_file_id>", "<dohyun_sheet_file_id>"], "seconds": 8, "ratio": "9:16", "idempotency_key": "drama-ep1-clip1", "dry_run": true }
```

## When it fails

- A failed or cancelled job is refunded in full, except error.code outcome_unknown: check the same job_id later with `jobs_get` and do not submit a replacement (see the price-first skill).
- Seedance and Omni may refuse reference images that show a real-looking face; use Kling 4.0 for photorealistic characters, or a drawn or 3D art style.
- A photo of a real person needs that person's permission; see the upload skill for `consent`. Do not use photos of children or of public figures.
