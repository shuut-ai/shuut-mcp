---
name: ads-plan
description: Plan a video ad in shuut's Ad studio before making it - start from the user's own script or a reference ad, read the product analysis (audience, selling points, hook candidates, style) and competitor ads, pick the hook the script opens with, and edit the script in plain words. Use when the user wants to choose the angle or hook of an ad, compare it with competitors, already has a script, or wants an ad like a reference video.
---

# Plan the ad: analysis, hook and script

Planning is free. Nothing here makes materials or spends credits; making is the ad-studio skill (`ad_run_make`, dry_run first).

1. Start the run with `ad_run_start`: `url`, `file_ids` or `product_id`, and a fresh `idempotency_key`.
   - If the user already has a script, pass its text as `script` (up to 3000 characters). For a PDF or Word document, read it yourself and pass the text. The creator speaks those sentences in order, one line each, word for word, or translated if the script is in another language than the ad's speech (same lines, same order). No spoken line outside the script is added (the end card and on-screen inserts still come from the product facts), and the script's own structure never blocks the plan (no closing call to action is only a warning; the end card carries the next step). In a script kept in its own language, a sentence's words change only when they fail a claim or fact check themselves — it is rewritten (script_line_changed) or left out (script_line_dropped) — or in the TikTok cart case (script_line_cta, below); a translated script is spoken as its translation. Other notes give the real reason: script_line_ungrounded (no product fact backs its claim, so it was left out), script_line_unfit (it could not fit the captions or cuts), script_line_unfilled (the planner skipped it, so the server filled it in), script_line_cta (on TikTok in English, a last line asking for a cart the landing page does not have was replaced with the landing page's action). Each note shows the original sentence. script_line_untranslated is a block, not a note: the line could not be translated into the ad's languages, so making fails with plan_blocked until that line is changed (`action` "plan" — rewrite its speech or caption that is still in the original language; changing either clears the block) or the plan is redone (`action` "replan"). The script sets the length (up to 60 seconds; sentences that do not fit get a script_long note, or lines_trimmed when there are more sentences than the format has lines). A script is the ad's speech, so it cannot go with `options` voice_on false (script_voice_off). Its first sentence always opens the ad, so a run with a script cannot pick a hook or make hook variants (both fail with script_hook): skip steps 4 and 5. Language and aspect-ratio variants still work.
   - If the user wants an ad paced like another video, pass it as `reference`: a `file_id` from the upload skill, or a public `url` (one of the two). References open on 2026-11-26 00:00 KST; before then the call fails with reference_closed, so start without it. Only its structure (length, cuts and beats, shown in the analysis) is copied, not its words. After the first read the run keeps only that structure, not the address or file id: to use the video again, pass it again.
   - To add either to an existing run, use `ad_run_change` with `action` "input" and `input` holding `script` or `reference`, then "resume".
2. Wait with `ad_run_get`: `run_id`, the last `rev` and `wait` 20, until done is true.
3. Read the analysis with `ad_run_get` and `view` "analysis". It has the product category, the target audience (who, situations, pains, objections), the selling points (strongest first, each with its benefit and the facts it rests on), the hooks (best score first; each has an id such as h1, its text and voice line, the selling point it uses and a score; the one the script opened with is marked in use; a run with the user's script has none), angles, the suggested style and format with why, and notes. If the analysis failed, the result says so: plan from `view` "facts" instead.
   - Competitor products and ads are a separate read: `view` "competitors" (all in one result: up to 6 products and 8 ads).
4. Show the user the top hooks with their score and the selling point each uses, and let them pick one. Do not write a new hook yourself; the hooks come from the collected facts.
5. Rewrite the script with the chosen hook (only on a run without the user's script): `ad_run_change` with `action` "replan", the current `rev` and `options` hook set to the hook id. The analysis stays and only the script is rewritten (one free run). Setting the hook to null redoes the analysis too. An id that is not in the analysis fails with invalid_input.
6. To change the script in words ("shorter opening", "stress the price"), call `ad_run_change` with `action` "edit", the current `rev` and `request` (up to 400 characters). Nothing is saved: the result's edit shows the changes, what was skipped or refused, and the edited plan. If the user accepts it, save it with `action` "plan", `plan` set to that edited plan and `rev` set to the edit's base rev.
7. Read the new script with `view` "plan", then give the user the run's open URL or continue with the ad-studio skill to make it.

Example arguments for `ad_run_get`:

```json
{ "run_id": "r7Kq2mXa9", "view": "analysis" }
```

Example arguments for `ad_run_change`:

```json
{ "run_id": "r7Kq2mXa9", "action": "replan", "rev": 3, "options": { "hook": "h2" } }
```

## Keep it honest

- Competitor ads are for contrast only: do not copy their wording, names or claims.
- A stale error means the run changed: read it again and use the new `rev`.
