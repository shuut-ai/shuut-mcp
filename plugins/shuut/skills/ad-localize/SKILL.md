---
name: ad-localize
description: Make language versions of a finished shuut Ad studio ad - the script, captions, voice and offer card are translated and spoken in that language - for several languages in one call. Use when the user wants the same ad in other languages or markets.
---

# Same ad, other languages

A language version is a new run in the same family as the original: the script, captions, on-screen text and end offer are translated and the voice speaks the new language (the original's speech language and pronunciation notes are not carried over). Images stay; in a one-take run the talking clip is made again in the new language, and that cost is in the quote.

1. Start from a run whose materials are made (see the ad-studio skill). Pick the hook first: on a language version a hook cannot be picked (lang_variant_hook), so make hook versions on the original (hook-variants skill) and translate the one you want. Ask the user which languages, as shuut site language codes such as en, ja, zh-Hant or pt-PT (up to 14; the ad's current language is left out).
2. Ask for them in one call with `ad_run_change`: `action` "variant", the current `rev` and `langs`. Translating a batch uses one of the day's free runs, however many languages it has; if none could be made, the free run is given back. Languages already made in the family are not translated again. One call makes one kind of variant: languages, hooks (hook-variants skill) or ratios (ad-resize skill).
3. The result lists `variants` for the family, the original included: each with its own `run_id`, language, state, quoted credits and open URL. A language that could not be made is listed in `skipped` with its reason; tell the user. On translate_failed, retry with fewer languages (3 or 4 per call); on variants_full (24 runs per family), ask before deleting unused versions with `ad_run_delete`. Read a version's script with `ad_run_get` and `view` "plan" and show it to the user, or someone who reads that language, before making it.
4. Price each version with `ad_run_make`: its `run_id` and `rev`, a fresh `idempotency_key`, `max_spend_credits` and `dry_run: true`. The new voice and checks are charged, plus the talking clip in a one-take run; images and other clips already made cost 0. Tell the user each price and the total.
5. When the user agrees, call `ad_run_make` again for each version without `dry_run`, with the same `idempotency_key`.
6. Give the user each version's open URL: the final video is made in their browser with the "Merge into video" button. Do not say it is finished before that.

Example arguments for `ad_run_change`:

```json
{ "run_id": "r7Kq2mXa9", "action": "variant", "rev": 6, "langs": ["en", "ja"] }
```

## Keep it honest

- The claim check screens copy under Korean advertising rules; other markets have their own rules, so tell the user to review health, effect or "best" claims for each market.
- Prices, offers and currency in the copy are translated, not converted: check them with the user for each market.
