---
name: batch
description: Run many shuut generations or edits at once - several images, videos, audio clips, cut-outs or product shots in one call - and collect all results. Use when the user asks for variations, a set of ads, many clips or bulk work.
---

# Many at once

1. Pick the batch tool: `generate_image_batch`, `generate_video_batch` or `generate_audio_batch` for those three, or `create_batch` with `tool` set to any other paid tool (for example remove_background or product_shot_create on many photos). Each takes `items` (1-8); each item takes the same fields as the single tool, without `idempotency_key`, `dry_run` and `max_spend_credits`.
2. Call it with `items` and an `idempotency_key`: it makes the items and charges each one at once. If any item is invalid, nothing is created and the error names `items[i]`.
3. Only when the user asks for the price first or sets a budget: call it with `dry_run: true` first (the result has `total_cost_credits`, `balance_credits`, `sufficient_balance` and a quote per item; nothing is charged), then call it again without `dry_run`, with the same `idempotency_key` and that `total_cost_credits` as `max_spend_credits`. `max_spend_credits` caps what the batch charges in total: if the quoted total is above it, nothing new is created and the call fails with max_spend_exceeded.
4. Each created item has its own `job_id`. Wait for all of them in one call with `jobs_wait` and `job_ids` (up to 10; `until` "any" returns as soon as one more ends). It returns `jobs`, `done_count`, `pending_ids` and `all_done` without output URLs; collect the outputs with `jobs_result` for each job.

Example arguments for `create_batch`:

```json
{ "tool": "remove_background", "items": [{ "image": "<photo1_file_id>" }, { "image": "<photo2_file_id>" }], "idempotency_key": "cutouts-1" }
```

## Partial results

- The result counts `created` and `failed`. An item that was not created was not charged; its `error` says why.
- Items over the account's concurrent job limit (see `balance`: `max_concurrent_jobs`, `active_jobs`) fail and are listed in `retry_indices`; call again later with the same `idempotency_key`.
- An item also fails on its own with quote_changed if its price went up between the quote and creation.
- Calling again with the same `idempotency_key` and the same `items` first returns the items already made (no new charge) and only creates the rest. If no item could be created, the call fails, nothing was charged, and `items` holds each error.
- An item that failed for another reason is not made again by the same `idempotency_key`. To try those items again, send only them (`new_key_indices` lists them) as a new call with a new `idempotency_key`: the other items are already made, and a new key for the whole batch makes and charges them again. If the user asked to see prices or set a budget, price that call with `dry_run: true` first and pass its `total_cost_credits` as `max_spend_credits`.
