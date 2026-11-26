---
name: edit-photo
description: Edit an existing image with shuut - fill or erase a masked area, cut out the background, expand to a new ratio, relight, change the camera angle, replace text, upscale to 4K, split into layers, retouch skin, make a sheet of alternate shots, or try a garment on a person. Use when the user wants to change a photo they already have.
---

# Edit an existing image

1. Get a `file_id` for the image (see the upload skill), or use the `file_id` of an image you generated.
2. Pick the tool:
   - `image_edit` with `operation`: fill (redraw the masked area from `prompt`), erase (remove the masked object), cutout (transparent PNG), expand (outpaint to `options.ratio`), relight, angle, text (`text_replacements`), upscale (to 4K), layers (split into transparent layers), skin (natural skin retouch; see consent), shots (3x3 sheet of alternate shots). A `mask` is a PNG the same size as the image, white = the area to change.
   - `remove_background`: cut the subject out as a transparent PNG, or on a solid `background` (white, black, light_gray or any #RRGGBB) and, with a background, centered on a fixed `canvas` size. Same price, no AI redraw.
   - `tryon_create`: dress a person in a garment (person photo + garment photo; needs the person's permission).
   - `product_shot_create`: put a product photo into a new advertising scene (see the product-ad skill).
   - `resize_image`: recompose an image into another aspect ratio with an image model (to extend the photo outward instead, use `image_edit` operation expand).
3. `get_preset_instructions` with preset edit-<operation> (for example edit-relight) returns that operation's options and an example.
4. Call the tool (it charges at once; `dry_run: true` first only when the user asks for the price, see the price-check skill), then `jobs_wait` until done.

Example arguments for `image_edit`:

```json
{ "operation": "expand", "image": "<image_file_id>", "options": { "ratio": "16:9", "place": "center" }, "idempotency_key": "expand-1" }
```

## Layers

With operation layers, results include each layer's file_id, signed URL, placement box and name. `layers.items` is paged: pass `layers.next_offset` and `layers.revision` to `jobs_result` as `layer_offset` and `layer_revision` until `layers.next_offset` is null. A changed revision (layer_document_changed) means restarting at offset 0.

After the layers job is done:

- `layers_edit` renames, moves, resizes, rotates, fades, hides, locks or deletes layers and adds the user's images as new layers (free; pass the current `revision` — if it changed, nothing is saved).
- `layer_redraw` splits one layer into child layers or redraws it from a prompt (paid; then `jobs_wait`).
- For a shots sheet, `edit_shots_split` cuts the 3x3 sheet into one image per shot (free).

## When it fails

- Skin retouch and try-on use a real person's photo, which needs that person's permission (a minor's from a parent or legal guardian, a public figure's from that person; usage policy): pass `consent: true` only after the user confirms in this conversation that the person gave permission.
- A failed job is refunded in full, except error.code outcome_unknown (see the price-check skill).
