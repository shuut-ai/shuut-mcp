---
name: ads-plan
description: Plan a video ad in shuut's Ad studio before making it - read the product analysis (audience, selling points, hook candidates, style) and competitor ads, pick the hook the script opens with, and edit the script in plain words. Use when the user wants to choose the angle or hook of an ad, compare it with competitors, or change the script.
---

# Plan the ad: analysis, hook and script

Planning is free. Nothing here makes materials or spends credits; making is the ad-studio skill (`ad_run_make`, dry_run first).

1. Start the run with `ad_run_start`: `url`, `file_ids` or `product_id`, and a fresh `idempotency_key`.
2. Wait with `ad_run_get`: `run_id`, the last `rev` and `wait` 20, until done is true.
3. Read the analysis with `ad_run_get` and `view` "analysis". It has the product category, the target audience (who, situations, pains, objections), the selling points (strongest first, each with its benefit and the facts it rests on), the hooks (best score first; each has an id such as h1, its text and voice line, the selling point it uses and a score; the one the script opened with is marked in use), angles, the suggested style and format with why, and notes. If the analysis failed, the result says so: plan from `view` "facts" instead.
   - Competitor products and ads are a separate read: `view` "competitors" (all in one result: up to 6 products and 8 ads).
4. Show the user the top hooks with their score and the selling point each uses, and let them pick one. Do not write a new hook yourself; the hooks come from the collected facts.
5. Rewrite the script with the chosen hook: `ad_run_change` with `action` "replan", the current `rev` and `options` hook set to the hook id. The analysis stays and only the script is rewritten (one free run). Setting the hook to null redoes the analysis too. An id that is not in the analysis fails with invalid_input.
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
