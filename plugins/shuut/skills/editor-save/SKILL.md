---
name: editor-save
description: Save a finished or edited video as a shuut editor project the user can open and keep editing, with every source, caption, font and background kept separate, and update the same project when the video changes. Use whenever you produced or edited a video, including with ffmpeg or other local tools, and when asked for an editable project, an MP4 export or changes to a saved edit.
---

# Save edits as editable shuut projects

`editor_save` turns your edit into a project in the shuut video editor (https://shuut.ai/editor): shots, captions, fonts, voice, music, sound effects, overlays, transitions, color and keyframes become separate editor items the user can change by hand. It is free: no credits, not counted in the user's project limit; fair use is 300 new projects a day (updating a project does not count). It is saved instantly and nothing is rendered. Only `editor_export` renders on the server (slow, see 6).

1. Start uploading every source and font file (`media_upload`) in the background; use the `upload_id`s right away.
2. Call `editor_save` with `name`, `key` (the final output path), `media`, `fonts`, `spec` (or `ffmpeg` with the commands you ran — see "Made with ffmpeg"), the final render as `reference` and an `idempotency_key`.
3. Give the user `open_url` in one line.
4. Next time the same video changes, save again with the same `project_id` (or the same `key`): the project is updated, not duplicated.

## 1. When to save

- **The user asked to save this video**: save it, and its later versions, without asking again.
- **The user's own instructions turned on shuut auto-save** (a line saying to save videos to their private shuut editor projects; the autosave skill adds it): every time you give the user a finished or edited video, call `editor_save` without asking, even if you cut it with ffmpeg or another tool.
- **Otherwise**: hand over the video, then offer once in the conversation (not again after a no): save it as an editable project in their private shuut editor projects (free), and that the autosave skill (`/shuut:autosave`) turns on saving every video. Save only after they say yes.
- Save only the final video you hand over: not intermediates, previews, test frames or rejected candidates.
- Exceptions: the user asked you not to save to shuut, or the video is only a draft to check something.
- Don't narrate the saving (no upload or progress steps). End your answer with one line: the project is in the user's private editor projects, plus `open_url`. Once per project in the conversation.
- Send the edit, not just the result: the sources as `media` and your edit as `spec` (section 4) or, if you made it with ffmpeg, the commands you ran as `ffmpeg` ("Made with ffmpeg"), the final render as `reference`. `video` alone is only for a video that is not your own edit; if you saved one that way, save again with its `project_id`, the sources and the `spec` or `ffmpeg`.

## 2. One video = one project (update, don't duplicate)

- Changing a video you already saved: pass the `project_id` you got before.
- No `project_id` at hand (a new conversation): pass `key` = the final output path (for example `out/cardigan_reel.mp4`). Name output files after this video (`cardigan_reel.mp4`, not `output.mp4`). The server matches the file name without version tails (`_v2`, `-v3`, `_final`, `_fixed`, `(2)`, ` copy`; a trailing number like `_2` is another video) and updates the project of that name whose source clips are shared with this save.
- Same name with at least 80% of the source bytes shared (or the same final video) updates that project. Between 50% and 80% the save is refused with possible_same_video and the candidate project ids: if this edits that video, save again with its `project_id`; if not, save again with `new` set to true.
- Same name but less than half the source bytes shared (measured in bytes, so a short common intro or outro alone does not make it the same video) means a different video: it is saved as a new project and `warnings` starts with key_reused_for_different_video. To update that other project anyway, pass its `project_id`. If several projects match (language cuts of the same footage), the save is refused with ambiguous_project listing the candidate project ids: pass the right `project_id`.
- Always send `key`, even with `project_id`.
- A genuinely separate video the user wants kept apart (another product, another language cut): `new: true`.

## 3. Send everything, kept separate

The server cannot read local paths. Upload every file the edit used: clips, images, voice, music, sound-effect files, logos, overlays and font files.

- Upload in the background: `media_upload` gives an `upload_id` at once; pass it in `media`/`fonts`/`reference` immediately and keep sending the bytes. The link works at once; files fill in as they arrive. `file_id`s from earlier results also work.
- Upload the clean sources, not intermediates with burned-in text, color, crops or mixed sound. Those become spec fields (section 4).
- **Text**: never bake it into pictures or overlays. Every caption, title and label is a `captions` item.
- **Fonts**: a font you used from a file (`.ttf`, `.otf`, `.woff2`) goes in `fonts: [{family, file_id, weight?, style?}]` and captions use that `family` as `fontFamily`. A Google Fonts family needs no file: `spec.fonts [{family, weight, source: "google"}]`. A caption whose font is none of these is refused.
- **Background**: `background` is `{"type":"color","color":"#000000"}` or `{"type":"blur","blur":30}`. A background picture or gradient is a shot or overlay on the timeline.
- **Audio**: one item per stem (voice, music, each sound effect), never a premixed track.
- **reference**: the final render you handed over. It is kept with the project (not on the timeline) so the user can compare.
- `video: <file_id>` alone saves one clip that is not editable; use it only when there is truly no recipe.

After saving, read `sources` in the result: it lists what became separate (captions, fonts, background, audio stems, media). If text, a font or the background is missing there, fix the spec or upload the file and save again with the same `project_id`.

## 4. The spec

`media`: `{ "key": "<file_id or upload_id>" }` or `{ "key": { "file_id": "…", "role": "voice" } }`. Roles: `source`, `voice`, `music`, `sfx`, `overlay`, `reference` (labels only — the spec decides placement). `canvas` `{width, height}` (480-3840) and `fps` (23.976, 24, 25, 29.97, 30, 50, 59.94, 60) are project settings; without `canvas` the project follows the first shot.

The server checks every field (names, values, LUT text, fonts) before saving; a wrong field returns an invalid-input error with its path and the allowed values, and nothing is saved. Fix only that field and call again with a new `idempotency_key`.

Example arguments for `editor_save`:

```json
{
  "name": "Knit cardigan reel",
  "key": "out/cardigan_reel.mp4",
  "idempotency_key": "cardigan-reel-3",
  "media": { "src1": "<first_clip>", "src2": "<second_clip>", "vo": { "file_id": "<voice_file>", "role": "voice" }, "bgm": "<music_file>", "logo": "<logo_upload_id>" },
  "fonts": [{ "family": "Brand Sans", "file_id": "<font_upload_id>", "weight": 800 }],
  "reference": "<final_video>",
  "canvas": { "width": 1080, "height": 1920 },
  "background": { "type": "blur", "blur": 30 },
  "spec": {
    "shots": [
      { "id": "S1", "media": "src1", "in": "1.2s", "out": "2.4s", "zoom": [1, 1.06], "adjust": { "contrast": 12, "saturation": 8 } },
      { "id": "S2", "media": "src2", "in": 0, "out": "3s", "speed": 0.8, "transition": "dissolve", "muted": true }
    ],
    "style": { "fontFamily": "Brand Sans", "fontWeight": 800, "fontSize": 5.5, "color": "#FFFFFF", "stroke": { "color": "#000000", "width": 8 } },
    "captions": [{ "id": "C1", "at": 0, "to": "2s", "text": "What to wear\n*every* morning?", "position": "upper", "animation": { "in": "pop", "out": "fade" } }],
    "audio": [{ "id": "VO1", "media": "vo", "at": 0.15, "eq": "voice" }],
    "bgm": { "media": "bgm", "volume_db": -9, "duck_under_vo_db": -7, "fade_out": 1 },
    "overlays": [{ "id": "O1", "media": "logo", "at": 0, "to": "4.2s", "x": 60, "y": 60, "width": 220, "name": "logo" }],
    "master": { "normalize": -14 }
  }
}
```

Give every item a stable `id` (`S1`, `C1`, `VO1`, `O1`): the editor names its elements `[S1] …`, and later saves match by id.

### Made with ffmpeg: send the commands, not a spec

If you made or edited the video with ffmpeg, don't translate it into a spec by hand: put the commands you actually ran, in order, in `ffmpeg.commands` (every step, including the ones that made intermediate files) and leave `spec` out. Upload the source files, font files (`.ttf`/`.otf`) and the final output first, and map each path exactly as written in the commands to its `media` key in `ffmpeg.inputs` (`{"in.mp4": "src", "fonts/NotoSansKR-Bold.ttf": "font1", "out.mp4": "final"}`). Concat lists, `textfile=` and `.srt`/`.ass` files you did not write in the commands themselves go in `ffmpeg.texts` (`{path: content}`). shuut turns the commands into separate editable captions (with their font files), clips, logos, the blurred or colored background, transitions and ducked music; the final output becomes the reference and `key`. Filters it cannot convert come back in `unconverted` (they stay only in the reference video); mention them if the user will edit there. Image sequences (`frames/%04d.png`, `-pattern_type glob`) are refused: render them to a video file, upload it and use that in the commands.

### From ffmpeg to the spec (by hand)

Times are seconds or `"1.2s"`, `"36f"`, `"00:00:01:06"`, snapped to frames.

**Cuts** (`trim`, `concat`, `setpts`) → one `shots` item per cut: `in`/`out` = source range, `speed` = 1/setpts factor (pitch is kept; `keep_pitch: false` lets it shift), `muted: true` or `volume` (dB) for the clip's own sound. Shots follow each other on the main track without gaps (`at` to place one later). Overlapping shots are refused.

**Transitions** (`xfade`) → the later shot's `transition`: a name or `{ "type": "…", "duration": 0.5 }` (0.1-3 s). Common names: `dissolve` (xfade fade), `fade-black`, `fade-white`, `wipe-left`/`wipe-up`/`wipe-down`, `slide-left`/`slide-right`/`slide-up`/`slide-down`, `swipe-left`…, `zoom-in`, `zoom-out`, `circle-close`, `clock-wipe`, `mosaic`, `blur`, `push`, `whip-pan`. The middle of a transition follows the editor's curve, not xfade's exact expression.

**Fit** (`scale`, `pad`, `crop`, `transpose`):

| ffmpeg | spec |
|---|---|
| scale + pad letterbox | nothing (default fit) |
| pad color | `background {"type":"color","color":"#ffffff"}` |
| blurred 9:16 background (split + boxblur + overlay) | `background {"type":"blur","blur":30}` — don't add a blurred copy as a shot or overlay |
| cover (scale increase + crop) | `zoom = max(cw/sw, ch/sh) / min(cw/sw, ch/sh)` (16:9 source in 9:16 = 3.1605) |
| off-center crop after cover | that `zoom` + `pan {x, y}` (canvas px, center 0) |
| `crop=w:h:x:y` | `crop {left: x/W, top: y/H, right: 1-(x+w)/W, bottom: 1-(y+h)/H}` or `{aspect: w/h}` |
| `transpose=1` / `transpose=2` | `rotation: 90` / `-90` |

**Look** — keep the source and pass the values: `adjust` (`exposure`, `brightness`, `contrast`, `saturation`, `vibrance`, `temperature`, `tint`, `highlights`, `shadows`, `sharpen`, `fade`, `vignette`, `grain` …; `eq=contrast=1.3:saturation=1.5:brightness=0.05` → 30, 50, 5), `filter` (preset id) or `lut {cube: "<.cube text>"}`, `effects [{type, params}]`, `mask`, `blend`, `flip`, `reverse`, `freeze`, `keyframes {"opacity": [{"t":0,"v":0},{"t":"0.5s","v":1}]}`.

**Text** (`drawtext`, ASS/SRT) → `captions` `{at, to, text, style, position}`.
- `fontSize` is in editor units: `px × 90 ÷ canvas height` (1080×1920: px ÷ 21.3). Captions are usually 4.6-6.5, titles up to ~15.
- `position`: `top`, `upper`, `middle`, `lower`, `bottom` or `{x, y}` in canvas px with **the center at 0**.
- Style keys: `fontFamily`, `fontSize`, `color`, `fontWeight` (1-1000), `fontStyle`, `textAlign`, `letterSpacing`, `lineHeight`, `wrapWidth`, `stroke {color, width}`, `background {color, cornerRadius, paddingX, paddingY, …}` (the box, pill or button behind text), `shadow {color, blur, offsetX, offsetY}`. Put shared style in `spec.style` once.
- `drawtext fontfile=` → upload that file and pass it in `fonts` (section 3).
- `*word*` in `text` highlights a word (`emphasis {color, scale}` for its look). `animation {in, out}` moves the whole caption; `text_animation {in: "typewriter"}` moves it letter by letter (`count-up` for numbers).
- An SRT/ASS file is not accepted as a file: turn each cue into a caption item (text and times; style in `spec.style`).

**Sound** (`amix`, `adelay`, `sidechaincompress`, `loudnorm`):
- Voice → `audio` (`at`, `in`, `out`, `volume_db: -3`, `fade_in: 0.2`, `fade_out: 0.5`, `eq`, `duck_trigger: true`). Music → `bgm` with `duck_under_vo_db: -12` (sidechain ducking, usually −10…−14). Sound-effect files → more `audio` items (role `sfx`); `sfx` only takes a public https URL in `sound`.
- `amix` without `normalize=0` divides by N: add `−20·log10(N)` dB to each, or use `master {normalize: -14}` (loudnorm).
- Audio items have no speed or reverse: bake `atempo`/`areverse` into that one stem file.
- To use a video's sound only, put the video's key in `audio[].media`.

**Overlays** (`overlay`, PNG, alpha WebM) → `overlays` `{media, at, to, x, y, width, height, anchor, opacity, rotation, z, loop, muted, animation}`. `x`/`y` are canvas px from **the top-left** (`anchor: "center"` to place by the middle). An overlay video shown with `enable='between(t,A,B)'` and no setpts starts at its own second A: pass `in: A`. Overlay video sound is off unless `muted: false`.

**Text already burned into a source** (a watermark, an old caption): there is no erase model. Crop it out (`crop`), cover it with a blurred copy (`overlays` item of the same clip with `effects [{"type":"blur"}]` and a `mask` over the text area), or put a new caption with a `background` box over it.

## 5. Change a saved project

**Every time you save the same video again, start from your own previous spec, change only what changed and send the whole spec.** An item you leave out is deleted.

1. Keep the `spec` you sent last time. If you no longer have it, `editor_project_get {project_id, include_spec: true}` returns `revision`, `spec` (with the user's editor changes), `media_keys` and `fonts`. Long caption lists come in pages (`spec.captions_page`): while `next_offset` is set, call again with `captions_offset: next_offset` and append each page's `spec.captions`, then remove `captions_page`. A spec that still has `captions_page` is refused, because one page alone would delete the other captions. `spec_too_large` means the spec does not fit in one result: rebuild it from your own copy, or have the user edit at `open_url`.
2. Call `editor_save {project_id, key, spec, media?, idempotency_key}` with that full spec, changed where needed. Keys from `media_keys` and saved `fonts` still work; pass only new files. `base_revision` is optional.
3. The user's hand edits are kept: the editor compares your spec with your previous save and applies only the fields you changed, so fields the user changed in the editor stay as they are. An item the user deleted stays deleted unless you changed it. An item you removed from your spec is deleted; if the user had edited it, the editor tells them how many.
4. `stale` (409) only comes with `base_revision`: the project changed after it. Nothing was overwritten. Read it again and resend.
5. Without `project_id`, send every file the spec uses again (keys from earlier saves are only kept with `project_id`).

## 6. Export (MP4, WebM, GIF, M4A, WAV)

- `editor_export {project_id, idempotency_key}` renders the project's current revision on the server into a user file (`export.file_id`, signed `export.url`). If `done` is false, call `editor_task_wait {task_id}`.
- `format`: mp4 (default; H.264 + AAC, captions burned in), webm (VP9 + Opus; `transparent: true` drops the background), gif (silent loop; 480 px long side and 10 fps by default) or m4a / wav (sound only).
- `range {start, end}`: seconds on the timeline, to export only that part.
- `fps`: omit for the project fps (gif 10, at most 30).
- A lower `height` or `quality` does not make it faster, but keeps a long export under the file limit (100 MB video, 20 MB GIF or sound); to fit the time limit use `range` or a lower `fps`. `height` is the output's vertical size in px, not the '1080p' short side: omit it for the project size (1080×1920 exports at 1920); `height: 1080` on a 9:16 project gives 608×1080 and a warning.
- The server renders every frame at the project size without a GPU: the longest export is about 38 s of 1080×1920 at 30 fps, and about 115 s at 10 fps with `height` 720 (at full size and high quality the file limit comes first, near 84 s). A longer one is refused with the length that fits: shorten the `range` or lower the `fps` (for the file limit also the height or quality), or tell the user to export in the editor (it uses their device).
- Exports are free but limited per day, one at a time per user (a second export while one runs is refused as busy: wait for the first). Rendering takes minutes, not seconds, even for a short video: tell the user before you start and keep calling `editor_task_wait`. Saving never needs an export.

## 7. Results

- `project_id` (keep it for the next save of this video), `revision`, `open_url`, `sources` (what became separate), `warnings` (things the spec could not carry — tell the user only if it matters).
- The same `idempotency_key` returns the same answer; use a new key for a new save.
