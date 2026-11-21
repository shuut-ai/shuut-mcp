---
name: voice-music
description: Make voice-overs, multi-speaker dialogue, background music and sound effects with shuut, clone the user's own voice, or score and dub an existing video. Use when the user asks for narration, text to speech, a voice, their own voice, music, a jingle, a sound effect or captions timing.
---

# Voice-over, dialogue and music

1. Call `voices_list` to choose a voice (and the model it belongs to). It also lists which models take `emotion` and `pace`, and the user's own cloned voices (ids starting with `vc_`).
2. Call `generate_audio` with mode "speech" and `text`; each line becomes one audio file. For two to four speakers use mode "dialogue" with `turns`.
3. For music or sound effects use mode "music" or "sfx" with a `prompt` and `seconds`, or pass a `video` to score that video (the result follows the video's length).
4. Use `dry_run: true` first (see the price-first skill). The `generate_audio` description states the current line, character and length limits; a length outside the range is fitted to the nearest allowed length and the quote shows `requested_seconds` and `seconds_adjusted`.
5. Call `jobs_wait`; audio is usually ready in under a minute.

Example arguments for `generate_audio`:

```json
{ "mode": "music", "prompt": "Warm lo-fi instrumental for a skincare ad", "seconds": 20, "idempotency_key": "music-1", "dry_run": true }
```

## Related tools

- `dub_video`: translate the speech in a video into another language in the speakers' own voices.
- `avatar_video_create`: make a photo speak an audio file (mode photo), or re-sync a video's lips to it (mode lipsync).
- `captions_transcribe`: words with start and end times from an audio or video file up to 2 minutes (1 credit per usable result).
- `editor_save`: put the voice, music and sound effects under video clips with captions in one editable project (free); `editor_export` renders the MP4.

## Voices of real people

A cloned voice (`vc_...`) or dubbing uses a real person's voice: it must be the user's own or used with that person's permission. Pass `consent: true` only after the user confirms in this conversation. Never set it on your own.

## Clone the user's own voice

shuut clones only the user's own voice, with the same separate consent as the shuut app. It is free (one saved voice per account).

1. Call `voice_clone_phrase` (language `ko` or `en`). First show the user its `notice` as it is (purpose, data, retention, processors, the right to refuse, policy links). Do not ask them to record before they have seen it.
2. Then show the `phrase`. The voice owner reads it exactly at the start of one recording, then keeps talking naturally for about a minute: WAV or MP3, one speaker, quiet room, 20-180 seconds. Only the voice owner may read it; a sample made elsewhere does not contain the phrase and fails the check.
3. Upload it with `media_upload`: up to 4 MB as `data_base64`; larger files with `bytes`, then PUT the raw bytes to `upload_url` and call `media_confirm`. If the error code is media_consent_required, the user must accept the upload notice in a browser at https://shuut.ai; you cannot accept it for them.
4. Ask the user to confirm in this conversation that the recording is their own voice and that, having read the notice, they agree to have it cloned for use in shuut. This consent is separate from shuut's terms; do not continue without it, and never assume it.
5. Only then call `voice_clone_create` with `name`, `audio` (the file_id), `phrase_token`, `consent: true` and an `idempotency_key` (`dry_run: true` checks the inputs only). It runs in the background: resend the same arguments until `status` is `done` (gives `voice_id`) or `failed` (read `error.next_step`). Never change the key while it is running.
6. Read a script in that voice: `generate_audio` with mode "speech", `voice` set to the `vc_...` id and `model` omitted (or one of `my_voices[].models` from `voices_list`). For a talking avatar, pass the resulting audio `file_id` as `audio` of `avatar_video_create`.

shuut does not import voice ids from other services. `voices_delete` deletes a voice (or all, withdrawing consent, which also stops clones still in progress) at shuut and the provider; use it only when the user asks.
