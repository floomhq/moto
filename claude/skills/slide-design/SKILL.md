---
name: slide-design
description: Visual design system for creating high-quality presentation slides (HTML, PPTX, or PDF). Use when designing pitch deck slides, presentation visuals, or any slide-based content. Covers layout composition, typography, color, data visualization, and visual hierarchy for 1920x1080 slide formats. Focuses on making slides that look professionally designed, not AI-generated.
---

# Slide Design

## The One Rule

Every slide needs ONE visual anchor: the single element your eye goes to first. Everything else supports it. If nothing dominates, the slide is dead.

## Visual Hierarchy (The 3-Level System)

Every slide has exactly 3 levels:
1. **Hero element** (60% visual weight): The big number, the key chart, the product screenshot, the bold headline. Font size 48-96px or a dominant visual.
2. **Supporting content** (30%): Subhead, labels, secondary data. Font size 14-20px.
3. **Ambient details** (10%): Section labels, page numbers, author name. Font size 11-13px, muted color.

If you have 4+ levels of visual weight on one slide, simplify.

## Layout Composition

### Avoid These Layouts
- **Centered everything**: Creates a floating, unanchored feel. Anchor content to edges/grids.
- **Even columns with identical structure**: Two cards, same height, same padding, same content density = boring. Vary the proportions.
- **Full-bleed cards on dark backgrounds**: Card boundaries become invisible. Use subtle borders or offset backgrounds.

### Use These Layouts
- **60/40 split**: Hero left, supporting right (or vice versa). The asymmetry creates energy.
- **Offset grid**: Cards that don't perfectly align create visual interest
- **Breathing room**: 48-64px padding from slide edges. 20-36px gaps between elements.
- **Bottom-anchored bars**: Summary bars, CTAs, or key stats at the bottom ground the slide.

### Filling Space Intentionally
When content doesn't fill the slide:
- DON'T stretch cards to fill (creates dead space inside cards)
- DON'T add filler content
- DO let cards be natural height and center the content area vertically
- DO use generous padding and let the background breathe
- DO add a visual element (ambient glow, subtle pattern, key stat) to occupy space purposefully

## Typography

### Font Pairing
- One display/headline font (serif or distinctive sans) + one body font (clean sans-serif)
- NEVER use only one font for everything (looks like a document, not a presentation)
- Display fonts with character: Instrument Serif, Playfair Display, Fraunces, Newsreader
- Body fonts: DM Sans, General Sans, Satoshi, Plus Jakarta Sans
- AVOID: Inter, Roboto, Arial, system fonts (generic AI slop)

### Font Sizing (1920x1080)
| Element | Size | Weight |
|---------|------|--------|
| Slide headline | 42-52px | 400 (serif) or 600 (sans) |
| Hero number/stat | 64-96px | 700 |
| Card title | 20-28px | 600 |
| Body text | 13-15px | 400 |
| Labels/captions | 11-13px | 500 |
| Section tags | 9-11px | 600, uppercase, tracked |

## Color on Dark Themes

### The Dark Palette Stack
```
Background:     #0a0a0a (near-black, not pure black)
Card surface:   rgba(255,255,255,0.04) background + rgba(255,255,255,0.06) border
Primary text:   #e8e8e8 (not pure white, reduces glare)
Secondary text: #888888
Tertiary text:  #555555
Accent:         ONE brand color (green #10b981, blue #60a5fa, etc.)
```

### Making Dark Slides Not Look Dead
- Add a subtle dot-grid or noise texture to the background
- Use ambient glows (radial-gradient with brand color at 6-10% opacity) behind key elements
- Invert ONE element per slide (white/light circle, card, or badge on the dark bg)
- Make sure at least one element on every slide uses the accent color

## Data Visualization

- Big stat numbers (64-96px) with small labels below, not inline
- Bar charts > pie charts > tables. Always.
- Max 4 data points per visualization. More = noise.
- Use color to highlight the ONE data point that matters
- Include the "so what": a one-line insight below the chart

## Quality Checklist

Before finalizing any slide:
- [ ] Can I identify the ONE hero element instantly?
- [ ] Is there dead space inside any card or container?
- [ ] Does the slide have visual variety (not all the same card/list pattern)?
- [ ] Is the accent color used at least once?
- [ ] Would this look designed if I showed it without context?
- [ ] Is font size hierarchy clear (3 levels, not 5)?
