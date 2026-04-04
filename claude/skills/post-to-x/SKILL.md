---
name: post-to-x
description: >
  Cross-post LinkedIn content to X (Twitter). Use when user says "post to x",
  "cross-post to x", "tweet this", "share on x", "post on twitter", or wants
  to adapt a LinkedIn post for X/Twitter. Handles text shortening, media upload
  (images and videos), and posting via the X API v2 + v1.1 media endpoint.
---

# Post to X (Twitter)

Cross-post LinkedIn content to X, adapting text and attaching media.

## Prerequisites

X API credentials must be set in `~/.claude/skills/post-to-x/.env`:

```bash
X_API_KEY=your_api_key
X_API_SECRET=your_api_secret
X_ACCESS_TOKEN=your_access_token
X_ACCESS_TOKEN_SECRET=your_access_token_secret
```

These come from the X Developer Portal (developer.x.com). You need a project with
"Read and Write" permissions. The access token must be generated with read+write scope.

## Workflow

### Step 1: Find the LinkedIn post content

Look for the post text in the current directory or the directory the user references:
- `post-copy-final.txt` or `post-copy*.txt` for text
- `*.mp4`, `*.mov`, `*.webm` for video
- `*.jpg`, `*.jpeg`, `*.png` for images
- `thumbnail*.jpg`, `thumbnail*.png` for thumbnail images

If the user provides text directly, use that instead.

### Step 2: Adapt the text for X

LinkedIn posts are long-form. X has character limits:
- **280 characters** for text-only posts
- **280 characters** for posts with media (text portion)
- **Threads**: up to 25 tweets, each 280 chars

Strategy:
1. Extract the core hook/message from the LinkedIn post
2. Create a concise X version (aim for 200-250 chars to leave room for links)
3. Remove LinkedIn-specific CTAs ("DM me", "Comment below")
4. Replace with X-appropriate CTAs if needed ("Link in replies", thread format)
5. Keep hashtags minimal (0-2 max, only if truly relevant)
6. No emojis unless the user explicitly requests them

If the post is too rich for a single tweet, propose a thread (2-4 tweets max).

**Always show the adapted text to the user for approval before posting.**

### Step 3: Upload media (if any)

```bash
python3 ~/.claude/skills/post-to-x/scripts/post_to_x.py upload-media <file_path>
```

This returns a `media_id` to use in Step 4.

For video: the script handles chunked upload (INIT, APPEND, FINALIZE, STATUS polling).
For images: simple upload.

**Size limits:**
- Images: 5 MB (JPEG, PNG, GIF, WEBP)
- Video: 512 MB, up to 2:20 duration (MP4 with H.264 video, AAC audio)
- GIF: 15 MB

### Step 4: Post the tweet

```bash
# Text only
python3 ~/.claude/skills/post-to-x/scripts/post_to_x.py post --text "Your tweet text"

# With media
python3 ~/.claude/skills/post-to-x/scripts/post_to_x.py post --text "Your tweet text" --media-ids "media_id_1,media_id_2"

# Thread
python3 ~/.claude/skills/post-to-x/scripts/post_to_x.py thread --texts "Tweet 1|||Tweet 2|||Tweet 3"

# Thread with media on first tweet
python3 ~/.claude/skills/post-to-x/scripts/post_to_x.py thread --texts "Tweet 1|||Tweet 2" --media-ids "media_id_1"

# Dry run (show what would be posted without actually posting)
python3 ~/.claude/skills/post-to-x/scripts/post_to_x.py post --text "Your tweet" --dry-run
```

### Step 5: Verify

The script prints the tweet URL on success. Confirm the post looks correct.

## Text Adaptation Examples

**LinkedIn (long):**
```
I genuinely stopped using PowerPoint.
Spending days aligning boxes feels insane when you can build a whole app in the same time.
So I made an app for building slides.
Three prompts. Full deck. 2 minutes.
No Figma. No templates. Just prompts.
Open source. Free forever.
DM "DECK" if you want early access.
```

**X (short):**
```
I stopped using PowerPoint and built an app that generates full slide decks from prompts.

3 prompts. Full deck. 2 minutes.

Open source, free forever.

github.com/yourorg/yourrepo
```

## Error Handling

- **401 Unauthorized**: Check API credentials in `.env`
- **403 Forbidden**: App needs "Read and Write" permissions, not just "Read"
- **413 Payload Too Large**: Video exceeds 512 MB or image exceeds 5 MB
- **429 Rate Limited**: Wait and retry (script handles this automatically)
- **Media processing failed**: Video codec/format issue, try re-encoding with ffmpeg

## Rules

1. **Always show the adapted text to the user before posting.** Never auto-post.
2. **No emojis** unless user requests them.
3. **No em dashes.** Use commas, semicolons, colons.
4. **Keep it punchy.** X rewards brevity. Cut ruthlessly.
5. **Dry run first** if unsure. Use `--dry-run` flag.
