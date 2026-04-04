---
name: review-video
description: |
  Review videos by extracting representative frames and analyzing them visually.
  Use when: (1) reviewing a rendered video (Remotion, ffmpeg output, etc.),
  (2) checking video quality or content, (3) verifying animations or transitions,
  (4) debugging video rendering issues. Triggers: "review video", "check the video",
  "does the video look right", "verify the render", or any request to visually
  inspect a .mp4, .webm, .mov, or other video file.
---

# Video Review

Review videos by extracting frames and analyzing them visually.

## Workflow

### Step 1: Extract frames

```bash
python3 ~/.claude/skills/review-video/scripts/extract_frames.py <video_path> --smart -n 10 --cleanup
```

### Step 2: Read ALL frames in parallel

Read every frame path from output using Read tool. Parallel reads for speed.

### Step 3: Cleanup temp files

Run the cleanup command printed at the end (if --cleanup was used).

### Step 4: Provide structured review

```
## Video Review: [filename]

**Metadata**: [resolution] | [duration] | [fps] fps | [codec]

### Overall Assessment
[1-2 sentences]

### Frame-by-Frame Notes
- > [0:00] Opening: [observation]
- o [0:05] [observation]
- * [0:10] Scene change: [observation]
- = [0:15] Closing: [observation]

### Issues Found
- [ ] Issue at [timestamp]: [description]

### Verdict
[PASS / NEEDS FIXES / FAIL] - [reason]
```

## Options

| Flag | Description |
|------|-------------|
| `-n NUM` | Number of frames (default: 10) |
| `--smart` | Use scene detection (recommended) |
| `--threshold FLOAT` | Scene sensitivity 0.0-1.0 (default: 0.1, lower=more sensitive) |
| `--cleanup` | Print cleanup command for temp files |
| `--json` | Output as JSON |
| `-o DIR` | Custom output directory |
| `-q NUM` | JPEG quality 1-31 (default: 2, lower=better) |

## Frame Source Icons

| Icon | Meaning |
|------|---------|
| > | Start of video |
| = | End of video |
| * | Scene change detected |
| o | Evenly-spaced filler |

## Frame Count Guidelines

| Use Case | Command |
|----------|---------|
| Quick check | `-n 5` |
| Standard | `-n 10 --smart` |
| Animation | `-n 20 --smart --threshold 0.05` |
| Debug | `-n 30 --smart` |
