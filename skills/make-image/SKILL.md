---
name: make-image
description: Generate images with shuut (GPT Image, Nano Banana, Seedream and other image models) from a text prompt and optional reference images. Use when the user asks to create, draw or render a picture, poster, product shot or illustration.
---

# Make an image

1. Optional: `models_explore` with kind "image" lists the image models (a short summary row each); for one model's ratios and resolutions, call it again with model set to that exact id, or with `fields` "full". Without `model`, shuut uses its default photo model.
2. Call `generate_image` with `prompt` and `idempotency_key`; it charges at once and returns a `job_id` in about a second. Only when the user asks for the price first or sets a budget, call it with `dry_run: true` before that (see the price-check skill). Reference images go in `references` as `file_id`s (see the upload skill).
3. Call `jobs_wait` with that `job_id` until `done` is true (usually 10-60 s).
4. Show the user each `outputs[].url`. The URLs expire at `url_expires_at`; `jobs_result` returns fresh ones.

Example arguments for `generate_image`:

```json
{ "prompt": "A ceramic mug on a linen tablecloth, soft morning light", "ratio": "1:1", "count": 2, "idempotency_key": "mug-1" }
```

For several prompts at once, use `generate_image_batch` (see the batch skill). For one-click presets (for example resize-image or scenes-pro), call `get_presets` and `get_preset_instructions`.

## When it fails

- A failed job is refunded in full; read `error.code` and `error.message` from `jobs_get` before changing the prompt.
- content_blocked or a refused person photo: explain the reason to the user; do not retry the same input with another model to get around it.
- To edit the result, pass the output `file_id` to `image_edit` (see the edit-photo skill).
