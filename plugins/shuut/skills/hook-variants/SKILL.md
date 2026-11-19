---
name: hook-variants
description: Make 1-4 more versions of a shuut Ad studio ad that open with different hooks, reusing the images and clips already made so only the changed voice lines are paid. Use when the user wants hook or A/B variants of an ad for testing.
---

# Hook variants of one ad

A variant is a new run in the same family as the original: it keeps the product facts, images and clips, and only the opening hook (and the voice lines it changes) is new.

1. Start from a run whose script is ready (see the ads-plan and ad-studio skills). To show the user which hooks the variants will use, read the hook candidates with `ad_run_get` and `view` "analysis": variants take the next best hooks by score.
2. Ask for the variants with `ad_run_change`: `action` "variant", the current `rev` and `count` (1-4). Building variants is free. To open the original ad with one specific hook instead, use `replan` with that hook (ads-plan skill). Hooks cannot be picked on a language version (lang_variant_hook): make hook variants on the original, then translate the one you want (ad-localize skill). A ratio version of a hook variant keeps that hook.
3. The result lists `variants` for the whole family, the original included: each with its own `run_id`, hook, state, quoted credits and open URL.
4. Price each new variant with `ad_run_make`: its `run_id` and `rev`, a fresh `idempotency_key`, `max_spend_credits` and `dry_run: true`. Images and clips already made in the family cost 0; only changed voice lines and checks are charged. Tell the user each price and the total.
5. When the user agrees, call `ad_run_make` again for each variant without `dry_run`, with the same `idempotency_key` and `max_spend_credits` at the agreed price.
6. Give the user each variant's open URL: the final video of each is made in their browser with the "Merge into video" button, as for any Ad studio run. Do not say a video is finished before that.

Example arguments for `ad_run_change`:

```json
{ "run_id": "r7Kq2mXa9", "action": "variant", "rev": 5, "count": 3 }
```

Example arguments for `ad_run_make`:

```json
{ "run_id": "r8Lm3nYb0", "rev": 1, "idempotency_key": "hook-variant-2", "max_spend_credits": 200, "dry_run": true }
```

## Keep it honest

- Hooks come from the analysis of collected facts; do not invent hooks, results or claims.
- Name each variant by its hook when you report them, so the user can tell them apart in a test.
