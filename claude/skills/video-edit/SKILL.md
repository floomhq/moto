---
name: video-edit
description: |
  AI-powered video editing toolkit. Trim, concat, overlay text/images,
  mix audio, generate voiceover, add transitions, and export with social
  media presets. Uses Gemini for intelligent edit suggestions.
  Use when: creating videos, editing clips, adding overlays, mixing audio,
  generating voiceovers, exporting for social media, or when user says
  "edit video", "trim", "add text overlay", "mix audio", "voiceover",
  "export for linkedin/x/instagram".
  Runs on a dev server only (ffmpeg + python). Mac delegates via SSH.
---

# Video Edit Skill

AI-powered video editing with ffmpeg and Gemini intelligence.

## Quick Reference

| Command | What it does |
|---------|-------------|
| `video-edit trim` | Cut to time range |
| `video-edit concat` | Join clips or image sequences |
| `video-edit speed` | Change playback speed |
| `video-edit text` | Add text overlays with timing |
| `video-edit image` | Add image overlay (logo, watermark) |
| `video-edit audio-mix` | Mix multiple audio tracks |
| `video-edit voiceover` | Generate ElevenLabs voiceover |
| `video-edit transition` | Add fades/crossfades |
| `video-edit export` | Export with social media presets |
| `video-edit ai-review` | Gemini analyzes video, suggests edits |
| `video-edit ai-score` | Gemini scores video quality (0-10) |

## Architecture

All editing uses ffmpeg under the hood. The Python scripts generate and execute ffmpeg commands, keeping edits non-destructive (original files untouched).

```
Input video/images --> Edit operations --> ffmpeg command --> Output video
                          ^
                    Gemini AI review (optional)
```

## Workflow

### Step 1: Plan the edit

Either describe what you want, or use `ai-review` to get suggestions:

```bash
python3 ~/.claude/skills/video-edit/scripts/video_edit.py ai-review <video_path>
```

This extracts frames, sends to Gemini, and returns structured edit suggestions.

### Step 2: Execute edits

Chain operations. Each produces a new file (non-destructive):

```bash
# Trim to 30 seconds
python3 ~/.claude/skills/video-edit/scripts/video_edit.py trim <input> -o <output> --start 0 --end 30

# Add text overlay
python3 ~/.claude/skills/video-edit/scripts/video_edit.py text <input> -o <output> \
  --text "Your text here" --position bottom --start 0 --end 5 --style subtitle

# Mix audio
python3 ~/.claude/skills/video-edit/scripts/video_edit.py audio-mix <input> -o <output> \
  --tracks '{"voiceover.mp3": {"volume": 1.0}, "music.mp3": {"volume": 0.15, "fade_out": 3}}'

# Generate voiceover
python3 ~/.claude/skills/video-edit/scripts/video_edit.py voiceover \
  --text "Script here" --voice sarah --output voiceover.mp3

# Export for LinkedIn
python3 ~/.claude/skills/video-edit/scripts/video_edit.py export <input> -o <output> --preset linkedin
```

### Step 3: Review result

Use the review-video skill to visually inspect:
```bash
python3 ~/.claude/skills/review-video/scripts/extract_frames.py <output> --smart -n 10 --cleanup
```

Or use AI scoring:
```bash
python3 ~/.claude/skills/video-edit/scripts/video_edit.py ai-score <video_path>
```

## Operations Reference

### trim
```bash
video_edit.py trim <input> -o <output> --start <seconds> --end <seconds>
```
- `--start`: Start time in seconds (default: 0)
- `--end`: End time in seconds (default: video duration)
- `--fade-in`: Fade in duration (default: 0)
- `--fade-out`: Fade out duration (default: 0)

### concat
```bash
video_edit.py concat -o <output> --inputs '["clip1.mp4", "clip2.mp4"]'
# OR from image sequence with durations:
video_edit.py concat -o <output> --concat-file <concat.txt>
```
- `--inputs`: JSON array of video files to concatenate
- `--concat-file`: ffmpeg concat demuxer file (with `file` and `duration` lines)
- `--transition`: Transition between clips (none, fade, crossfade)
- `--transition-duration`: Transition duration in seconds

### speed
```bash
video_edit.py speed <input> -o <output> --factor 2.0
```
- `--factor`: Speed multiplier (2.0 = 2x faster, 0.5 = half speed)
- `--preserve-pitch`: Keep audio pitch when changing speed (default: true)

### text
```bash
video_edit.py text <input> -o <output> \
  --text "Hello" --position bottom --start 0 --end 5
```
- `--text`: Text content
- `--position`: top, center, bottom, top-left, top-right, bottom-left, bottom-right
- `--start` / `--end`: When to show (seconds)
- `--style`: plain, subtitle, title, caption, badge
- `--font-size`: Font size (auto-calculated if not set)
- `--font-color`: Color (white, yellow, #hex)
- `--bg-color`: Background color (black@0.6 for semi-transparent)
- `--font`: Font file path

Multiple text overlays: use `--texts` with JSON array:
```bash
--texts '[
  {"text": "Phase 1", "position": "bottom", "start": 0, "end": 5, "style": "subtitle"},
  {"text": "Phase 2", "position": "bottom", "start": 5, "end": 10, "style": "subtitle"}
]'
```

### image
```bash
video_edit.py image <input> -o <output> \
  --overlay logo.png --position top-right --scale 0.1 --opacity 0.8
```
- `--overlay`: Image file path
- `--position`: Same as text positions
- `--scale`: Scale relative to video width (0.1 = 10%)
- `--opacity`: 0.0-1.0
- `--start` / `--end`: When to show

### audio-mix
```bash
video_edit.py audio-mix <input> -o <output> \
  --tracks '{"voiceover.mp3": {"volume": 1.0, "delay": 2.0}, "music.wav": {"volume": 0.15, "fade_out": 3}}'
```
Track options:
- `volume`: 0.0-1.0 (default: 1.0)
- `delay`: Start delay in seconds
- `fade_in`: Fade in duration
- `fade_out`: Fade at end (duration in seconds)
- `loop`: Loop track to match video length

### voiceover
```bash
video_edit.py voiceover --text "Script" --voice sarah --output vo.mp3
```
Voices: sarah, rachel, adam, josh, elli, bella
- `--text`: Script text
- `--voice`: ElevenLabs voice name
- `--output`: Output MP3 path
- `--model`: TTS model (default: eleven_multilingual_v2)

### transition
```bash
video_edit.py transition <input> -o <output> --fade-in 1.0 --fade-out 1.0
```
- `--fade-in`: Fade from black at start
- `--fade-out`: Fade to black at end
- `--crossfade`: Duration for crossfade (only with concat)

### export
```bash
video_edit.py export <input> -o <output> --preset linkedin
```
Presets:

| Preset | Resolution | Max Duration | Notes |
|--------|-----------|-------------|-------|
| linkedin | 1920x1080 | 10min | h264, AAC 192k, faststart |
| linkedin-square | 1080x1080 | 10min | Cropped to square |
| x | 1920x1080 | 2:20 | h264, max 512MB |
| x-square | 1080x1080 | 2:20 | Square crop |
| instagram-reel | 1080x1920 | 90s | Vertical, 9:16 |
| instagram-feed | 1080x1080 | 60s | Square |
| youtube | 1920x1080 | none | h264, AAC 256k |
| web-optimized | 1280x720 | none | Small file, fast load |
| gif | 800xauto | 15s | Animated GIF, <5MB |
| thumbnail | 1280x720 | N/A | Single frame PNG |

### ai-review
```bash
video_edit.py ai-review <video_path> [--detailed]
```
Extracts 10 smart frames, sends to Gemini with video metadata. Returns:
- Overall quality assessment
- Pacing analysis
- Visual issues (overlapping text, low contrast, etc.)
- Audio sync assessment
- Specific edit suggestions with timestamps and commands

### ai-score
```bash
video_edit.py ai-score <video_path>
```
Returns a 0-10 score with breakdown:
- Visual quality (resolution, clarity, color)
- Pacing (timing, rhythm, attention)
- Audio (voiceover, music, SFX balance)
- Content (message clarity, CTA effectiveness)
- Production (transitions, overlays, branding)

## ElevenLabs Voices

| Name | Voice ID | Style |
|------|---------|-------|
| sarah | EXAVITQu4vr4xnSDxMaL | Mature, Reassuring, Confident |
| rachel | 21m00Tcm4TlvDq8ikWAM | Calm, Warm |
| adam | pNInz6obpgDQGcFmaJgB | Deep, Authoritative |
| josh | TxGEqnHWrfWFTfGW9XjX | Young, Casual |
| elli | MF3mGyEYCl7XYWbV9V6O | Young, Soft |
| bella | EXAVITQu4vr4xnSDxMaL | Soft, Sweet |

## Social Media Best Practices

| Platform | Ideal Length | Key Notes |
|----------|------------|-----------|
| LinkedIn | 30-90s | First 3s hook, subtitles mandatory, end with CTA |
| X/Twitter | 15-45s | Punchy, no intro fluff, loop-friendly |
| Instagram Reels | 15-30s | Vertical, text on screen, trending audio |
| YouTube | varies | Thumbnail matters, first 10s = retention |

## Tips

- **Non-destructive**: Every operation creates a new file. Chain operations by using output as next input.
- **Preview first**: Use `--dry-run` to see the ffmpeg command without executing.
- **Batch text**: Use `--texts` JSON array for multiple overlays in one pass (faster than chaining).
- **AI loop**: Run `ai-review` -> apply suggestions -> run `ai-score` -> iterate until 8+.
