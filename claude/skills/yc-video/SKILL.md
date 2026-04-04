---
name: yc-video
description: |
  Plan, audit, and score startup launch videos using YC-grade production standards.
  Use when: creating product launch teasers, scoring video quality for social distribution,
  planning narrative structure for LinkedIn/X autoplay, reviewing cold-audience effectiveness.
  Triggers: "launch video", "yc video", "score the video", "plan the teaser",
  "audit launch video", "cold audience test", "video narrative", "teaser structure".
---

# YC Video Skill

Plan, build, audit, and score startup launch videos that convert cold social feeds.

## Three Modes

| Mode | When | Command |
|------|------|---------|
| **Plan** | Starting a new video | `/yc-video plan` |
| **Score** | Evaluating an existing video | `/yc-video score <path>` |
| **Audit** | Deep qualitative review | `/yc-video audit <path>` |

---

## Mode 1: Plan

### Step 1: Define the constraints

Collect from user or infer:
- **Duration**: 15s (teaser), 30s (explainer), 60s (demo)
- **Format**: Square (1080x1080, LinkedIn/X autoplay) or Wide (1920x1080, YouTube/X)
- **Audio**: Muted-first (captions carry the story) or VO-driven
- **Platform**: LinkedIn, X, YouTube, Product Hunt
- **Audience temperature**: Cold (never heard of you) or Warm (waitlist, followers)

### Step 2: Apply the 3-Act Structure

Every YC-grade launch video follows this arc:

```
ACT 1: PAIN (0-3s)
  Statement of a problem the VIEWER has felt.
  Not your metric. Not your product. Their frustration.
  Must work in silent autoplay (text on screen).

ACT 2: BRIDGE + FLOW (3-10s)
  "What if..." or "So I built..." transition.
  One continuous product demonstration.
  NOT feature list. One fluid action: input -> magic -> output.
  The product is the hero. Show, don't tell.

ACT 3: PROOF + CLOSE (10-15s)
  Social proof, metric, or "aha" reveal.
  Logo + CTA + URL.
  This is where your impressive number lives (not second 1).
```

### Step 3: Write the shot list

For each second, define:
- Visual (what's on screen)
- Text overlay (what the muted viewer reads)
- VO line (if applicable)
- Animation (entry, emphasis, exit)

Use this format:
```
| Time | Visual | Caption | VO | Animation |
|------|--------|---------|----|-----------|
| 0-1s | Dark bg, pain text | "You apply to 50 jobs." | -- | Fade from black, type-on |
| 1-3s | Pain continued | "Hear back from 2." | -- | Beat pause, then type |
| 3-4s | Product appears | "What if jobs found you?" | "What if..." | Slide up from bottom |
```

### Step 4: Validate against the Cold Feed Test

Before building, answer these 5 questions YES:
1. **Muted scroll test**: Does the first frame + caption stop a thumb?
2. **3-second test**: Does a viewer who watches 3s muted understand what this is?
3. **Jargon-free**: Would a non-technical LinkedIn user understand every caption?
4. **One idea**: Is there exactly one core message? (Not 3 features, not 5 stats)
5. **Verb before noun**: Does the CTA tell them to DO something? ("Drop your LinkedIn" not "AI matching platform")

If any answer is NO, revise before building.

---

## Mode 2: Score

### Step 1: Extract frames

```bash
python3 ~/.claude/skills/review-video/scripts/extract_frames.py <video_path> --smart -n 12 --cleanup
```

### Step 2: Read all frames visually

Read every extracted frame using the Read tool in parallel.

### Step 3: Score using the YC Video Rubric

Score each dimension 1-10. **List flaws BEFORE stating a number.**

| Dimension | Weight | What 10/10 looks like |
|-----------|--------|----------------------|
| **Cold Clarity** | 25% | A stranger understands the product in 5s muted. No jargon. No unexplained metrics. |
| **Narrative Arc** | 20% | Pain -> Bridge -> Flow -> Proof -> Close. Clear emotional progression. Viewer feels "I need this." |
| **Visual Craft** | 15% | Clean composition, consistent palette, no clipping, proper spacing. Looks funded, not bootstrapped. |
| **Motion Design** | 10% | Purposeful animation. Nothing static, nothing gratuitous. Spring physics, eased transitions. |
| **Caption Design** | 10% | Readable at phone size. High contrast. Proper timing (not too fast, not lingering). Carries the story alone. |
| **VO/Audio Sync** | 10% | VO matches visuals exactly. Music supports, never competes. Silence used intentionally. |
| **CTA Effectiveness** | 10% | Viewer knows exactly what to do next. URL visible. Action verb. No ambiguity. |

### Step 4: Calculate weighted score

```
OVERALL = (Cold*0.25 + Arc*0.20 + Visual*0.15 + Motion*0.10 + Caption*0.10 + Sync*0.10 + CTA*0.10)
```

### Step 5: Output format

```
## YC Video Score: [filename]

### Flaws (list ALL before scoring)
1. [Flaw description with timestamp]
2. ...

### Dimension Scores
| Dimension | Score | Key Issue |
|-----------|-------|-----------|
| Cold Clarity | X/10 | [one-line] |
| Narrative Arc | X/10 | [one-line] |
| Visual Craft | X/10 | [one-line] |
| Motion Design | X/10 | [one-line] |
| Caption Design | X/10 | [one-line] |
| VO/Audio Sync | X/10 | [one-line] |
| CTA Effectiveness | X/10 | [one-line] |

### OVERALL: X.X / 10

### Top 3 Changes for +1 Point
1. [Specific, actionable change with expected impact]
2. ...
3. ...

### Verdict
[SHIP IT / ITERATE / REBUILD] - [one sentence why]
```

Verdict thresholds:
- **SHIP IT**: 8.5+ overall, no dimension below 7
- **ITERATE**: 7.0-8.4, or any dimension below 7
- **REBUILD**: Below 7.0, or Cold Clarity below 6

### Step 6: Gemini cross-check (optional)

For an independent second opinion, run the Gemini scoring script:

```bash
python3 ~/.claude/skills/yc-video/scripts/yc_score.py <video_path>
```

---

## Mode 3: Audit

Deep qualitative review. Use after scoring identifies problem areas.

### Step 1: Extract 20 frames with scene detection

```bash
python3 ~/.claude/skills/review-video/scripts/extract_frames.py <video_path> --smart -n 20 --threshold 0.05 --cleanup
```

### Step 2: Second-by-second analysis

For each second of the video:
- What is the viewer seeing?
- What is the viewer reading (caption)?
- What is the viewer hearing (VO)?
- Are these three aligned? (visual + text + audio saying the same thing)
- What emotion is being triggered?
- Would the viewer keep watching or scroll?

### Step 3: The Cold Feed Simulation

Imagine three LinkedIn personas watching this on their phone:
1. **VP Engineering at Series B** (knows the problem space, skeptical of new tools)
2. **Junior dev job hunting** (the target user, scrolling fast)
3. **Non-technical observer** (no tech context, pure visual/emotional read)

For each persona: would they (a) stop scrolling, (b) watch past 3s, (c) visit the URL?

### Step 4: Output the audit

```
## YC Video Audit: [filename]

### Second-by-Second Breakdown
| Time | Visual | Caption | VO | Alignment | Emotion |
|------|--------|---------|------|-----------|---------|
| 0-1s | ... | ... | ... | [OK/DRIFT/MISSING] | ... |

### Persona Reactions
| Persona | Stop? | Watch 5s? | Click CTA? | Why/Why Not |
|---------|-------|-----------|------------|-------------|
| VP Eng | ... | ... | ... | ... |
| Job Hunter | ... | ... | ... | ... |
| Non-tech | ... | ... | ... | ... |

### Critical Issues (ordered by impact)
1. [Issue + fix]
2. ...

### Rebuild Recommendation
[If REBUILD verdict: the complete new shot list with the corrected structure]
```

---

## YC Launch Video Patterns (Research-Backed)

These patterns come from analyzing successful YC Demo Day videos, Product Hunt launches, and high-engagement LinkedIn product teasers.

### The Rules

1. **Pain first, product second.** Never open with your metric, your logo, or your feature. Open with something the viewer has FELT. "You apply to 50 jobs. Hear back from 2." beats "97" every time for cold audiences.

2. **Design for muted autoplay.** 85% of LinkedIn/X video is watched without sound. If your video doesn't work on mute, it doesn't work. Text overlays carry the story. VO is supplementary.

3. **One continuous flow.** Not a feature list. Not a montage. One unbroken product action: paste URL -> loading -> results appear. The viewer's brain follows the flow. Cuts reset cognitive load.

4. **Verb before noun.** "Drop your LinkedIn" not "AI-powered job matching." "Build slides in 2 minutes" not "Presentation generation platform." Action verbs compel. Nouns describe.

5. **The impressive metric is the PAYOFF.** Put your "97 match score" or "4000 startups" at second 10, not second 1. The viewer needs context to care about the number. Without context, numbers are noise.

6. **Logo at the end, never the start.** No one cares about your brand at second 0. They care about their problem. Logo + URL in the last 2-3 seconds only.

7. **Under 15 seconds for LinkedIn.** Completion rate drops off a cliff after 15s on feeds. 15s forces ruthless editing. Every frame earns its place or gets cut.

8. **No "we" or "our".** It's "you" and "your." "Your match score" not "Our matching algorithm." The video is about the viewer, not the company.

### Hook Patterns That Work

| Pattern | Example | Why It Works |
|---------|---------|-------------|
| **Pain statement** | "You apply to 50 jobs. Hear back from 2." | Viewer nods, feels seen |
| **Contrarian claim** | "Job boards are broken. Here's proof." | Creates curiosity gap |
| **Demo-first** | [Screen recording starts immediately] | Shows before tells |
| **Question** | "What if jobs applied to you?" | Forces mental engagement |
| **Before/After** | Split screen: old way vs new way | Visual contrast is instant |

### Anti-Patterns (Instant Scroll)

| Don't | Why | Do Instead |
|-------|-----|------------|
| Open with logo | No one cares about your brand yet | Open with pain or demo |
| Open with metric | No context = no meaning | Put metrics at second 10+ |
| Feature montage | Cognitive overload, nothing sticks | One continuous flow |
| "We're excited to announce" | Corporate cringe, zero value | Show the product |
| Slow fade from black | Wastes precious first-frame attention | Start with content |
| Background music only | Silent autoplay = dead video | Captions + text on screen |

---

## Scoring Calibration

To keep scores honest:

| Score | Meaning | Real-world equivalent |
|-------|---------|----------------------|
| 10/10 | Indistinguishable from a funded startup's agency-produced video | Loom, Linear, Vercel launch videos |
| 9/10 | Broadcast-ready, minor nitpicks only | Top 5% of Product Hunt launches |
| 8/10 | Professional, ships confidently | Good indie hacker launch |
| 7/10 | Competent but missing polish or narrative clarity | Average product demo |
| 6/10 | Works but feels amateur or confusing | Screen recording with text |
| 5/10 | Significant issues, would not post | Rough draft |
| 1-4 | Fundamentally broken | Unwatchable |

**8+ = can ship. Below 8 = keep iterating.**
