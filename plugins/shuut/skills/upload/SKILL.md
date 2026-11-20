---
name: upload
description: Bring the user's own image, video or audio file into shuut and get a file_id for other shuut tools. Use when the user gives a local file or a public URL to use in shuut (to edit, transcribe or pass to another tool as an input).
---

# Use the user's own file

Every tool that takes an image, video or audio input takes a shuut `file_id`. Uploading and importing are free (the account's daily upload limit applies).

1. Before the first upload or import: the account owner must have accepted shuut's one-time media upload notice in a browser (sign in at https://shuut.ai and upload any file there). Until then `media_upload` and `media_import_url` fail with media_consent_required. You cannot accept it on the user's behalf: ask the user to do it, then retry.
2. If the file is on the public web: call `media_import_url` with its https URL and use the returned `file_id`. The URL must serve the file itself (not a web page) without a login.
3. In ChatGPT, a file the user attached in this conversation goes to `media_import_url` as `attachments` (that field is shown only there). Elsewhere, if the file is small (up to 4 MB): call `media_upload` with `mime` and `data_base64` (the file as base64). The result is the file itself with its `file_id`; no PUT or `media_confirm` is needed, and sending the same content again within 15 minutes returns the same `file_id`.
4. If the file is local and larger: call `media_upload` with `mime` and the exact `bytes`, then send the raw bytes to `upload_url` with HTTP PUT and the given Content-Type header, for example:

   ```sh
   curl -X PUT -H 'Content-Type: image/png' --data-binary @photo.png '<upload_url>'
   ```

5. Call `media_confirm` with the `upload_id` to get the `file_id` (status "pending" means the bytes have not arrived yet; `last_error` explains a rejected attempt, and the same `upload_url` can be retried until it expires).
6. Pass the `file_id` to any tool that takes an image, video or audio input. Outputs of earlier jobs also have a `file_id` you can reuse, and `products_list` returns saved product photo file_ids. `assets_delete` removes a job from the history, a saved product or a brand kit (it cannot be undone: ask the user first).

Example arguments for `media_upload`:

```json
{ "mime": "image/png", "bytes": 245760, "filename": "mug.png" }
```

Limits: images 20 MB, audio 20 MB, video 100 MB. Types: PNG, JPEG, WebP, AVIF, MP4, MOV, WebM, MP3, WAV, M4A.

## People in files

Photos, videos and voices of people may only be used if they are the user's own or the person gave permission. Some tools take `consent`: pass `consent: true` only after the user confirms in this conversation that the person gave permission. Never set it on your own.
