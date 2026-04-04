---
name: republic-design
description: Republic-style UX design reviewer and scorer for pitch decks, landing pages, and investor-facing materials. Applies Republic.com's design DNA (financial-grade trust, data-forward, restrained elegance) to score and improve any visual artifact. Use when user says "republic", "republic style", "score design", "polish deck", "investor-grade design", or wants to elevate visual quality to crowdfunding-platform standards.
---

# Republic-Style Design System

## Design DNA

Republic's design is built on one principle: **financial-grade trust through visual restraint**. Every pixel earns investor confidence. No decoration exists without purpose. The platform feels like a Bloomberg terminal dressed in Dieter Rams' philosophy.

## The Republic Aesthetic

### 1. Color Palette (The Trust Stack)

```
Background:         #ffffff (pure white, no off-whites)
Surface:            #f9fafb (cards, containers)
Surface elevated:   #ffffff + box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04)
Border:             #e5e7eb (light gray, 1px)
Border emphasis:    #d1d5db (slightly darker, for active/hover)

Text primary:       #111827 (near-black, high contrast)
Text secondary:     #6b7280 (muted gray)
Text tertiary:      #9ca3af (captions, timestamps)

Brand green:        #10b981 (emerald-500, success, CTA, growth)
Brand green light:  #ecfdf5 (emerald-50, subtle badge backgrounds)
Brand green border: #a7f3d0 (emerald-200, badge borders)

Danger:             #ef4444 (red-500, sparingly)
Danger light:       #fef2f2 (red-50, badge background)

Accent:             #3b82f6 (blue-500, links only)
```

**Rules:**
- Maximum 2 accent colors per slide (green + one other)
- Never use gradients on backgrounds or cards
- Never use colored left borders on cards (AI slop pattern)
- Dark cards (#111827 or #1a1a1a) used sparingly: max 1 per slide for contrast
- No opacity tricks for backgrounds; use real color values

### 2. Typography

**Primary font:** Inter (the fintech standard)
**Display/headline alternative:** DM Sans 600-700 (acceptable substitute)
**Monospace:** JetBrains Mono or SF Mono (code blocks only)

```
Hero stat:          64-80px, weight 700, tracking -0.02em
Slide headline:     36-44px, weight 600, tracking -0.01em
Card title:         18-22px, weight 600
Body text:          15-16px, weight 400, line-height 1.6
Small label:        12-13px, weight 500, uppercase, tracking 0.05em
Caption:            13-14px, weight 400, color #9ca3af
```

**Rules:**
- Max 3 font size tiers per slide (hero, body, caption)
- Headlines never bold-italic or decorated
- No text shadows, no text-stroke, no gradient text
- Labels always uppercase with letter-spacing
- Line-height: 1.3 for headlines, 1.6 for body

### 3. Spacing System

```
Slide padding:      64px vertical, 80px horizontal
Section gap:        48px between major sections
Card padding:       24-32px
Card gap:           16-20px between cards
Element gap:        12-16px between items in a list
Icon-to-text:       12px
```

**Rules:**
- Consistent rhythm: pick one spacing unit (8px base) and stick to multiples
- Generous whitespace beats cramming content
- Never let content touch container edges (min 24px padding)

### 4. Cards & Containers

**Standard card:**
```css
background: #ffffff;
border: 1px solid #e5e7eb;
border-radius: 12px;
padding: 24px 28px;
/* No shadow by default */
```

**Elevated card (important content):**
```css
background: #ffffff;
border: 1px solid #e5e7eb;
border-radius: 12px;
padding: 28px 32px;
box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
```

**Accent card (CTA or key metric):**
```css
background: #ecfdf5;
border: 1px solid #a7f3d0;
border-radius: 12px;
padding: 28px 32px;
```

**Dark card (sparingly, max 1 per slide):**
```css
background: #111827;
color: #f9fafb;
border: none;
border-radius: 12px;
padding: 32px;
```

**Rules:**
- border-radius: 12px universally (never 0, never 20px+)
- No colored left borders on cards
- No gradient backgrounds on cards
- No double borders or border tricks
- Cards should feel like they could exist on republic.com

### 5. Data Presentation

**Stat display (Republic's signature):**
```html
<div class="stat">
  <span class="stat-value">$2.4M</span>
  <span class="stat-label">RAISED TO DATE</span>
</div>
```
- Value: 48-72px, weight 700, color #111827 or #10b981
- Label: 12px, uppercase, tracking 0.05em, color #9ca3af
- Always value above label, never inline

**Progress bars:**
```css
.bar-track { height: 6px; background: #f3f4f6; border-radius: 3px; }
.bar-fill { height: 6px; background: #10b981; border-radius: 3px; }
```
- Thin (6-8px), not chunky
- Rounded ends
- No gradients or stripes in bars

**Charts:**
- Clean axes, minimal gridlines (#f3f4f6)
- Data points as small circles (6-8px), not large dots
- Area fills at 10-15% opacity of the line color
- Max 2 data series per chart
- Always include axis labels

### 6. Icons & Visual Elements

**Icon style:** Outlined/stroke, 1.5px stroke weight, 20-24px size
**Icon color:** #6b7280 (muted) or #111827 (emphasis)
**Icon containers:** 40x40px circle or rounded square, background #f3f4f6

**Rules:**
- No filled/solid icons (too heavy)
- No colored icon backgrounds (except green for success states)
- No emoji-style icons
- Prefer Heroicons outline or Lucide
- If using brand logos: real SVGs from SimpleIcons, never text-in-circles

### 7. Buttons & CTAs

```css
/* Primary */
background: #10b981;
color: #ffffff;
border: none;
border-radius: 8px;
padding: 12px 24px;
font-size: 15px;
font-weight: 600;

/* Secondary */
background: #ffffff;
color: #111827;
border: 1px solid #e5e7eb;
border-radius: 8px;
padding: 12px 24px;
```

- No gradient buttons
- No pill-shaped buttons (border-radius: 9999px)
- No icon-only buttons without labels
- Max 1 primary CTA per slide

### 8. Badges & Tags

```css
/* Standard badge */
background: #f3f4f6;
color: #6b7280;
border-radius: 6px;
padding: 4px 10px;
font-size: 12px;
font-weight: 500;

/* Success badge */
background: #ecfdf5;
color: #059669;
border: 1px solid #a7f3d0;

/* Danger badge */
background: #fef2f2;
color: #dc2626;
border: 1px solid #fecaca;
```

### 9. Backgrounds & Atmosphere

- Pure white (#ffffff) for slide backgrounds
- No gradient meshes, no noise textures, no ambient glows
- No radial gradient decorations (they look AI-generated)
- If depth is needed: use a single subtle shadow, not background effects
- No dot-grids or pattern overlays

### 10. Diagrams & Flow Charts

- Connectors: 1.5px solid lines, color #d1d5db
- Arrow heads: small, clean triangles (6px)
- Flow direction: left-to-right or top-to-bottom
- Node style: standard card style (white, 1px border, 12px radius)
- Connection points: small circles (6px) at node edges
- Use green (#10b981) only for the active/highlighted path
- Gray for secondary paths

---

## Scoring Rubric (10 Dimensions)

When scoring a slide or deck, evaluate on these 10 axes (1-10 each):

### 1. Trust Signal (Does it feel like a financial platform?)
- 10: Could be a Republic deal page
- 5: Looks like a startup landing page
- 1: Looks like a hackathon project

### 2. Typography Discipline
- 10: 3 clear tiers, consistent sizing, proper tracking
- 5: Too many sizes, inconsistent weights
- 1: Random sizing, decorative fonts

### 3. Color Restraint
- 10: 2 colors max, used with surgical precision
- 5: 3-4 colors, some unnecessary
- 1: Rainbow, gradients everywhere

### 4. Whitespace & Breathing Room
- 10: Content breathes, nothing feels cramped
- 5: Adequate but could use more space
- 1: Wall of content, no margins

### 5. Card & Container Quality
- 10: Consistent radius, borders, padding. Republic-standard.
- 5: Mixed styles, some inconsistency
- 1: Random borders, colors, no system

### 6. Data Presentation
- 10: Numbers are heroes, clean stat displays, thin progress bars
- 5: Data exists but layout is average
- 1: Data buried in text, no visual treatment

### 7. Icon & Visual Coherence
- 10: Consistent stroke icons, proper sizing, real brand logos
- 5: Mixed icon styles
- 1: Emoji, filled icons, text-in-circles

### 8. Layout Composition
- 10: Clear visual anchor, asymmetric columns, purposeful grid
- 5: Functional but predictable
- 1: Everything centered or evenly spaced

### 9. Dark Element Usage
- 10: Dark cards used sparingly for maximum impact
- 5: Too many or too few dark elements
- 1: Dark elements feel random or overwhelming

### 10. AI-Slop Avoidance
- 10: No colored left-borders, no gradient cards, no emoji, no generic patterns
- 5: Some AI-slop patterns present
- 1: Looks like ChatGPT generated the CSS

**Scoring formula:**
- Average of 10 dimensions = raw score
- Penalty: -0.5 for each AI-slop pattern detected
- Bonus: +0.3 for each "this could be on Republic" element

---

## Common Republic-Style Fixes

| Problem | Republic Fix |
|---------|-------------|
| Dark card with colored left border | Remove border-left, use full dark bg or green accent border (all sides) |
| Gradient background on container | Solid color: #f9fafb for light, #111827 for dark |
| Too many colors | Reduce to #111827 + #10b981 + #ef4444 (if needed) |
| Large rounded corners (16-20px) | Standardize to 12px |
| Thick borders (2px+) | Reduce to 1px #e5e7eb |
| Chunky progress bars | 6px height, rounded, no stripes |
| Icon size inconsistency | Standardize to 20px in 40px containers |
| Text-heavy sections | Extract key stat as hero number, demote rest |
| Multiple CTAs per slide | One primary CTA, rest are secondary/text links |
| Decorative background effects | Remove entirely, pure white |

---

## Workflow

1. **Audit**: Read all slides/pages, catalog every design choice
2. **Score**: Apply the 10-dimension rubric to each slide
3. **Prioritize**: Rank fixes by visual impact (highest delta per change)
4. **Fix**: Apply Republic-style corrections, starting with highest-impact
5. **Verify**: Screenshot and re-score after fixes
6. **Iterate**: Repeat until average score >= 9.0
