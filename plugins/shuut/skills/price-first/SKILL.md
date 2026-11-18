---
name: price-first
description: Check the exact shuut price before spending credits, then create. Use before any paid shuut tool (images, videos, audio, edits, batches) or when the user asks what something costs, how many credits they have, or why a job was refunded.
---

# Check the price before spending

shuut bills the signed-in user's credits (100 credits = US$1). Every paid tool takes `dry_run`, `idempotency_key` and `max_spend_credits`.

1. Call `balance` to see the credits, expiring lots, whether the account can create, and its concurrent job limit.
2. Call the create tool you plan to use with `dry_run: true` and an `idempotency_key`. It returns `cost_credits`, `balance_credits` and `sufficient_balance`; nothing runs and nothing is charged. `quote.seconds_adjusted` is true when the length was fitted to what the model or account allows.
3. Tell the user the price. When they agree, call the same tool again without `dry_run` (a new or the same `idempotency_key` both work). Add `max_spend_credits` to refuse a higher price.
4. Keep the `idempotency_key` when you retry the same request: the same key and the same input return the same job instead of charging twice.

Example arguments for `generate_image`:

```json
{ "prompt": "A red sneaker on wet asphalt at night", "idempotency_key": "sneaker-1", "dry_run": true }
```

## Refunds

- A failed or cancelled job is refunded in full (see `refunded_credits`).
- The exception is error.code outcome_unknown: the provider's outcome is still being checked, so the unconfirmed part stays charged until it is confirmed (refunded_credits shows any part already returned; a result may still arrive, or the rest is refunded then). Check the same job_id again later with `jobs_get`; do not submit a replacement job.
- `jobs_cancel` cancels a job that has not started running and refunds it in full.

## When it fails

- insufficient_credits: nothing was charged. Tell the user the price and their balance, and show the `top_up_url` from the error (the shuut page with credits and plans for their account). Follow the error's `next_step`. Retry with the same `idempotency_key` only when the user asks.
- max_spend_exceeded: nothing was charged. Ask the user before raising `max_spend_credits`.
- `usage_get` summarizes credits charged and refunded over the last N days, and `subscription_get` shows the user's plan, renewal date and this period's subscription credits.
