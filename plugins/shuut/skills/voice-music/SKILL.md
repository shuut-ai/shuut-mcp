---
name: voice-music
description: Make voice-overs, multi-speaker dialogue, background music and sound effects with shuut, or score and dub an existing video. Use when the user asks for narration, text to speech, a voice, music, a jingle, a sound effect or captions timing.
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
- `captions_transcribe`: words with start and end times from a 16 kHz mono WAV (1 credit per usable result).

## Voices of real people

A cloned voice (`vc_...`) or dubbing uses a real person's voice: it must be the user's own or used with that person's permission. Pass `consent: true` only after the user confirms in this conversation. Never set it on your own.
