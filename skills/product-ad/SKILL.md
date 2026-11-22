---
name: product-ad
description: Turn a product photo into ad creative with shuut - clean cut-outs, styled product shots, finished ad images with headline and CTA, ad copy, claim screening, translation, and an animated product video. Use when the user wants ads, product shots or marketing images for a product.
---

# Product photo to ad

1. Get a `file_id` for the product photo (see the upload skill; uploading needs the account owner's one-time media upload notice accepted in a browser, otherwise it fails with media_consent_required and you cannot accept it for them) or pick one from `products_list`. `brand_kits_list` returns the user's saved colors, tone and logo `file_id`.
   - To save the product for later, call `product_save`; product tools then take its id as `product_id`.
   - For a brand kit, `brand_kit_extract` drafts the fields from the brand's public site (nothing is saved — review with the user), then `brand_kit_save`; `ad_create` takes its id as `brand_kit_id`.
2. Make the visual:
   - `remove_background` for a clean cut-out.
   - `product_shot_create` for a styled scene that keeps the product unchanged.
   - `ad_create` for a finished ad image with headline, short copy and CTA rendered in it (optionally with a `logo`). `plan_write` with kind ad_concepts drafts headline, copy, CTA and layout per angle for free.
3. Optional: `copy_write` drafts hooks and body copy (Korean unless you pass `language`); `claims_check` screens copy for risky claims under Korean advertising rules (reference only, not legal advice); `translate_text` localizes it.
4. To animate the result, pass the output `file_id` as `first_frame` to `generate_video` (see the make-video skill).
5. Every paid step: `dry_run: true` first, then for real, then `jobs_wait`.

Example arguments for `ad_create`:

```json
{ "product": "<product_file_id>", "headline": "Light every day", "body": "Absorbs fast with no sticky feel.", "cta": "Shop now", "ratio": "1:1", "idempotency_key": "ad-1", "dry_run": true }
```

## Keep it honest

- Use only claims the user gave you or that are on the product page; run `claims_check` before using health, effect or "best" claims.
