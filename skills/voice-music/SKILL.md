---
name: voice-music
description: Make voice-overs, multi-speaker dialogue, background music and sound effects with shuut, clone the user's own voice, or score and dub an existing video. Use when the user asks for narration, text to speech, a voice, their own voice, music, a jingle, a sound effect or captions timing.
---

# Voice-over, dialogue and music

1. Call `voices_list` to choose a voice (and the model it belongs to). It also lists which models take `emotion` and `pace`, and the user's own cloned voices (ids starting with `vc_`).
2. Call `generate_audio` with mode "speech" and `text`; each line becomes one audio file. For two to four speakers use mode "dialogue" with `turns`.
3. For music or sound effects use mode "music" or "sfx" with a `prompt` and `seconds`, or pass a `video` to score that video (the result follows the video's length; leave out `seconds` and `loop` then). With a `video`, the sfx result is that video with the sound added (MP4).
4. The call charges at once; only when the user asks for the price first or sets a budget, make it with `dry_run: true` before (see the price-check skill). The `generate_audio` description states the current line, character and length limits; a length outside the range is fitted to the nearest allowed length and the quote shows `requested_seconds` and `seconds_adjusted`.
5. Call `jobs_wait`; audio is usually ready in under a minute.

Example arguments for `generate_audio`:

```json
{ "mode": "music", "prompt": "Warm lo-fi instrumental for a skincare ad", "seconds": 20, "idempotency_key": "music-1" }
```

## Related tools

- `dub_video`: translate the speech in a video into another language in the speakers' own voices. To match the lips to the dub, call `avatar_video_create` with mode "lipsync", the original as `video`, the dubbed result's `file_id` as `audio` (a video up to 60 s with a sound track works as `audio`) and `consent` (same rule as below).
- `avatar_video_create`: make a photo speak an audio file (mode photo), or re-sync a video's lips to it (mode lipsync).
- To change the voice in a recording or in a video's speech to another voice, use the preset `sound-voice-change` (`get_preset_instructions`); it follows the same voice consent as dubbing.
- `captions_transcribe`: words with start and end times from an audio or video file (1 credit per started 2 minutes of transcribed audio, up to 5). For a subtitle file, pass `format` "srt" or "vtt": the result then has the file text under that name, ready to save or hand over. Pass `language` (two letters, for example "ko") and `vocabulary` (up to 20 words the speech uses, such as brand and people's names) to get those words right. A WAV or MP3 longer than 10 minutes is transcribed for its first 10 minutes only (the transcript then says truncated and gives the source length in source_seconds); video up to 10 minutes and M4A up to 2 minutes (for a longer one, extract the sound as MP3 and transcribe that). Long results come in pages: while `transcript.next_offset` is set, call `jobs_result` with `transcript_offset` (and the same `format`) and join the pages in order. For captions in an `editor_save` project, build the `captions` items from the words in `transcript`, not from the subtitle file.
- `editor_save`: put the voice, music and sound effects under video clips with captions in one editable project (free); `editor_export` renders the MP4 (or WebM, GIF, M4A, WAV).

## Voices of real people

A cloned voice (`vc_...`) or dubbing uses a real person's voice: it must be the user's own or used with that person's permission. Pass `consent: true` only after the user confirms in this conversation. Never set it on your own.

## Clone the user's own voice

shuut clones only the user's own voice, with the same separate consent as the shuut app. It is free (one saved voice per account).

1. Call `voice_clone_phrase` (language `ko` or `en`). First show the user its `notice` as it is (purpose, data, retention, processors, the right to refuse, policy links). Do not ask them to record before they have seen it.
2. Then show the `phrase`. The voice owner reads it exactly at the start of one recording, then keeps talking naturally for about a minute: WAV, MP3 or M4A (a phone voice memo works), one speaker, quiet room, 20-180 seconds. Only the voice owner may read it; a sample made elsewhere does not contain the phrase and fails the check, and files made by shuut (such as speech results) are not accepted as a recording. If the user cannot make a recording file, they can record in the shuut app at https://shuut.ai/sound?kind=myvoice.
3. Upload it (see the upload skill): with a shell, `media_upload` with `bytes`, then PUT the raw bytes to `upload_url` and call `media_confirm`; `data_base64` only for a small file. If the error code is media_consent_required (only an account that withdrew the one-time upload notice gets it), the user must accept the notice again in a browser at https://shuut.ai; you cannot accept it for them. You may check the recording before asking for consent: the step 5 call with `dry_run: true` and consent still false checks everything else first.
4. Ask the user to confirm in this conversation that the recording is their own voice and that, having read the notice, they agree to have it cloned for use in shuut. This consent is separate from shuut's terms; do not continue without it, and never assume it.
5. Only then call `voice_clone_create` with `name`, `audio` (the file_id), `phrase_token`, `consent: true` and an `idempotency_key` (`dry_run: true` checks the inputs only). It runs in the background: resend the same arguments until `status` is `done` (gives `voice_id`) or `failed` (read `error.next_step`). Never change the key while it is running.
6. Read a script in that voice: `generate_audio` with mode "speech", `voice` set to the `vc_...` id and `model` omitted (or one of `my_voices[].models` from `voices_list`). For a talking avatar, pass the resulting audio `file_id` as `audio` of `avatar_video_create`.

shuut does not import voice ids from other services. `voices_delete` deletes a voice (or all, withdrawing consent, which also stops clones still in progress) at shuut and the provider; use it only when the user asks.
