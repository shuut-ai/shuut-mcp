---
name: upload
description: Bring the user's own image, video or audio file (or a font for editor captions) into shuut and get a file_id for other shuut tools. Use when the user gives a local file or a public URL to use in shuut (to edit, transcribe or pass to another tool as an input).
---

# Use the user's own file

Every tool that takes an image, video or audio input takes a shuut `file_id`. Uploading and importing are free (the account's daily upload limit applies).

1. The first time an account uses shuut through MCP, shuut records the account's one-time media upload notice as accepted, so uploads and imports work right away. Only an account that withdrew that notice gets media_consent_required from `media_upload` and `media_import_url`: the user must accept it again in a browser (sign in at https://shuut.ai and upload any file there). You cannot accept it on the user's behalf: ask the user to do it, then retry.
2. If the file is on the public web: call `media_import_url` with its https URL and use the returned `file_id`. The URL must serve the file itself (not a web page) without a login.
3. In ChatGPT, a file the user attached in this conversation goes to `media_import_url` as `attachments` (that field is shown only there).
4. If the file is local and you can run shell commands: call `media_upload` with `mime` and the exact `bytes` (or `files` for several, which returns one curl line for all), then send the raw bytes to `upload_url` with HTTP PUT and the given Content-Type header from your shell. This is shuut's own upload: do it even when the user asked to use only shuut tools. If curl says `Could not resolve host` or `Operation not permitted`, your shell has no network: ask the user to allow it (in Codex, approve running the command outside the sandbox, or set `network_access = true` under `[sandbox_workspace_write]` in the Codex config). Do not work around it by printing the file as base64 in the shell and sending that: the base64 floods your context, large files get cut off, and the upload fails. For example:

   ```sh
   curl -X PUT -H 'Content-Type: image/png' --data-binary @photo.png '<upload_url>'
   ```

   If you cannot run shell commands, call `media_upload_open`: it opens a window where the user picks the files, and it returns their `file_id`s. If no window appears, ask the user for a public URL (step 2). `data_base64` (the file as base64 in the call) is only for a small file when nothing else works: the server takes up to 4 MB, but clients often cut base64 near 1 MB (about 750 KB of file), and a cut file is refused as base64_truncated. With a shell, use the PUT above. The result of `data_base64` is the file itself with its `file_id` (no PUT or `media_confirm`), and the same content within 15 minutes returns the same `file_id`.

   A single video over 100 MB (up to 1 GB) comes back without `upload_url` (pass its local path as `filename`, so the curl line reads that file): the result has `parts[]` and one `curl` line that PUTs every part with its headers. Run that line, then `media_confirm`; if it lists parts still missing, PUT those parts again and confirm again.

5. Call `media_confirm` with the `upload_id` (or `upload_ids`) to get the `file_id` (status "pending" means the bytes have not arrived yet; `last_error` explains a rejected attempt, and the same `upload_url` can be retried until it expires).
6. Pass the `file_id` to any tool that takes an image, video or audio input. Outputs of earlier jobs also have a `file_id` you can reuse, and `products_list` returns saved product photo file_ids. `assets_delete` removes a job from the history, a saved product or a brand kit (it cannot be undone: ask the user first). There is no tool to delete an uploaded file: uploads and results are kept privately until the account is deleted, and to erase a file completely the user asks shuut support; the contact address is in the privacy policy at https://shuut.ai/legal/privacy.
7. If you edited a video for the user locally (ffmpeg or another editor), upload its clean sources and the final render, then save the final video with `editor_save` (without asking if the user's instructions turned on shuut auto-save, otherwise after the user agrees; not intermediates, previews or candidates, or if the user said not to), and give the user the private project's `open_url`. Saving the same video again updates its project: always pass `key` = the final output file path, plus its `project_id` if you have it (see the editor-save skill).

Example arguments for `media_upload`:

```json
{ "mime": "image/png", "bytes": 245760, "filename": "mug.png" }
```

## Several local files at once

For up to 10 local files, call `media_upload` once with `files` instead of `mime`/`bytes`/`filename`. Give each item's exact `bytes` and its path as `filename` (up to 120 characters; an absolute path or one relative to the folder you will run curl in, never starting with `~`, which curl cannot read inside quotes):

```json
{ "files": [{ "mime": "image/png", "bytes": 245760, "filename": "mug.png" }, { "mime": "video/mp4", "bytes": 8123456, "filename": "clip.mp4" }] }
```

Every item is checked before anything is created: if one has a wrong type, is too large or has too long a name, the call fails naming that item and nothing is created; fix it and send the whole list again. The hourly and daily upload counts are checked up front for this call only, not reserved: a PUT can still be refused with 429 if other uploads use up the daily count first, and the daily 3 GB size limit and the failed-upload limit are checked only at the PUT. `media_confirm` shows such a refusal as `last_error`.

The result has `uploads[]` (one `upload_id`, `upload_url` and `headers` each, same order) and `curl`, one shell line that PUTs each file separately and prints `files[N] failed` for any that did not go through (replace any `<file N>` with the path). Then call `media_confirm` once with `upload_ids`: `uploads[]` gives each file's `file_id` or why it is not ready (`pending`, `expired`, `last_error`, or an error such as not_found), and `ready`/`not_ready` count them. Some can be ready while others are not: retry only those.

Limits: images 20 MB, audio 20 MB, video 1 GB (one file per `media_upload` call; over 100 MB it comes back in parts, see step 4; `files` and `media_import_url` take videos up to 100 MB), fonts 40 MB. Types: PNG, JPEG, WebP, AVIF, HEIC (stored as JPEG), MP4, MOV, WebM, MP3, WAV, M4A, and TTF, OTF, WOFF, WOFF2 fonts (`font/ttf` etc.), which only editor text uses: other tools refuse a font `file_id`.

## People in files

Photos, videos and voices of people may only be used if they are the user's own or the person gave permission. Some tools take `consent`: pass `consent: true` only after the user confirms in this conversation that the person gave permission. Never set it on your own.
