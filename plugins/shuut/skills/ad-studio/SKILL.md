---
name: ad-studio
description: Turn a product page or product photos into a fact-checked video ad script with shuut's Ad studio (ad_run_start, ad_run_get, ad_run_change, ad_run_make). Use when the user wants a product video ad script or storyboard from a URL or photos.
---

# Ad studio: product to fact-checked ad script

The Ad studio reads the product (page URL, photos, or a saved product), collects facts with their sources, and writes a script that only claims what those facts support. It is the same run the user sees at https://shuut.ai/ad. The script is free. When `ad_run_make` is listed it makes the voice, images, clips and music (paid); the finished MP4 is made in the user's browser: they open the run's open URL, press the "Merge into video" button (its label is shown in the user's language) and keep the tab open (Chrome or Edge, or Safari 26+; not Linux or Firefox; no extra credits). Tell the user before spending and do not say the video is finished until then. The made materials are the files of the run's `job_ids` (`jobs_result`); `ad_run_change` drops the run's material list but those jobs stay. Runs the user started in the web app are listed by `ad_runs_list`.

1. Start with `ad_run_start`: give `url`, `file_ids` (photos or detail-page captures from `media_upload`), or `product_id`, plus a fresh `idempotency_key`. Optional `note` (what to stress) and `options` (seconds 6-60, format, lang, voice and music on or off, faces, motion). If the user has their own script, pass it as `script` (lines follow it, claims are still fact-checked); to copy the flow of an ad they like, pass `reference` with a `file_id` (their video from `media_upload`) or a public video `url` (only its beats and length are copied, never its words; available from 2026-11-26 00:00 KST, before that the run is refused with reference_closed). Free: 10 runs a day (60 with a card on file), 2 running at once. If the error code is media_consent_required, the account owner must accept shuut's one-time media upload notice in a browser first; you cannot accept it for them. Ask them, then retry with the same `idempotency_key`.
2. Wait with `ad_run_get`: pass `run_id`, the last `rev`, and `wait` 20. It returns as soon as the run changes (changed is false if nothing changed). Repeat until done is true. Do not poll without `rev`.
3. Review: when the state is ready, read `ad_run_get` with `view` "facts" (12 per page, `offset`) and `view` "plan". Facts whose use is "held" are left out of the script (unverified, conflicting, or risky claims such as "best" or medical wording). `view` "analysis" shows the research behind the script: the buyer, the selling points, the hook candidates (the one opening the script is marked in_use; a run with the user's own script opens with that script, so none is), and the chosen style and tier; `view` "competitors" shows the competitor research (products, ads and what they say). The user's own script is shown in full only in the default view (other views give only its length).
4. Adjust if needed with `ad_run_change`, always with the current `rev`. `options` and `input` change only the fields you pass. `action` "facts" switches `facts` on or off, or `confirm` held prices the user says are correct, and rewrites the script (one free run). "replan" rewrites the script from the same facts, optionally with a new `note` or `options` (one free run); with `options.hook` set to a hook id from view "analysis" it keeps the analysis and rewrites the script to open with that hook (show the user the hooks and let them pick; changing the note, format or tier, or an analysis noted judge_off, analyzes again and drops the pick). A run with the user's own script always opens with that script: picking a hook is refused (script_hook), and its voice must stay on (script_voice_off). "edit" turns the user's words in `request` into a proposed script without saving it (60 a day, apart from free runs): show the user the changes, and if they agree save that script with "plan" and the proposal's base rev. "plan" overwrites the script with an edited object from view "plan". "input" changes the URL, photos, note, own script or reference and redoes the facts and the written script; then "resume" reads again. "stop" and "resume". A stale error means the run changed: read it again and use the new `rev`. To delete a run permanently, ask the user first and call `ad_run_delete`.
5. Hand off: give the user the run's open URL from the result. It opens the run in shuut's Ad studio, where they can review and edit the facts and the script, and where a made ad is rendered into the final video. Once the materials are made, the result's edit URL opens them in shuut's editor for free-form edits.

Example arguments for `ad_run_start`:
```json
{ "url": "https://shop.example/products/linen-shirt", "note": "Stress the breathable fabric", "options": { "seconds": 15, "lang": "en" }, "idempotency_key": "ad-linen-shirt-1" }
```

Example arguments for `ad_run_get`:
```json
{ "run_id": "r7Kq2mXa9", "rev": 1, "wait": 20 }
```

## Failures that need the user

- page blocked, not a product, unreadable input, too few facts: ask for product photos or detail-page captures, upload them, then `ad_run_change` with `action` "input" and "resume".
- daily limit: today's free runs are used up; wait for the retry time in the error.
- too many runs: two runs are working; wait or stop one.

Never invent facts, prices or reviews the run did not collect. Say which facts the script uses.
