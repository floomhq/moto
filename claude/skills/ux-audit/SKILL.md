# Independent UX Audit

Independent UX quality audit using Gemini as the judge. Takes screenshots of live pages at multiple viewports and themes, sends them to Gemini for scoring across 7 UX dimensions. Produces actionable report with per-page breakdown.

Use when user says "ux audit", "audit the ux", "ux score", "design audit", "audit this site", "independent audit", "score the ux", "ux review", or wants an independent design evaluation of a website.

## Arguments

- `/ux-audit <url>` -- quick mode: screenshot-based scoring (default)
- `/ux-audit <url1> <url2> ...` -- audit specific pages
- `/ux-audit <url> --focus "mobile, typography"` -- audit with focus areas
- `/ux-audit deep <url>` -- deep mode: Gemini autonomously browses and tests the site
- `/ux-audit deep <url> --auth <login_url> <user> <pass>` -- deep mode with auth credentials

## Workflow

### Step 1: Prepare

```bash
rm -rf /tmp/ux-audit && mkdir -p /tmp/ux-audit
```

Parse the arguments to get the list of URLs to audit. If only a domain is given (e.g., `https://example.com`), infer the key pages (typically /, /about, /pricing, /waitlist, /docs).

### Step 2: Capture Screenshots

Use `chrome-devtools` MCP tools for screenshot capture. For EACH URL:

**2a. Navigate and prepare:**
```
navigate_page(type="url", url="<URL>")
```
Wait for load, then force any reveal animations:
```
evaluate_script: () => {
  document.querySelectorAll('[data-reveal]').forEach(el => el.setAttribute('data-reveal', 'visible'));
  return 'ready';
}
```

**2b. Desktop Light (1280x800):**
```
evaluate_script: () => { document.documentElement.dataset.theme = 'light'; return 'light'; }
```
Wait 1s, then:
```
take_screenshot(fullPage=true, filePath="/tmp/ux-audit/{slug}-desktop-light.png")
```

**2c. Desktop Dark:**
```
evaluate_script: () => { document.documentElement.dataset.theme = 'dark'; return 'dark'; }
```
Wait 1s, then:
```
take_screenshot(fullPage=true, filePath="/tmp/ux-audit/{slug}-desktop-dark.png")
```

**2d. Resize to mobile:**
```
resize_page(width=390, height=844)
```

**2e. Mobile Light:**
```
evaluate_script: () => { document.documentElement.dataset.theme = 'light'; return 'light'; }
```
Wait 1s, then:
```
take_screenshot(fullPage=true, filePath="/tmp/ux-audit/{slug}-mobile-light.png")
```

**2f. Mobile Dark:**
```
evaluate_script: () => { document.documentElement.dataset.theme = 'dark'; return 'dark'; }
```
Wait 1s, then:
```
take_screenshot(fullPage=true, filePath="/tmp/ux-audit/{slug}-mobile-dark.png")
```

**2g. Restore desktop viewport:**
```
resize_page(width=1280, height=800)
```

**Slug naming:** Use the URL path. `/` becomes `home`, `/about` becomes `about`, etc.

**If a page does not support theme switching** (no `data-theme` attribute), skip the dark/light variants and just capture desktop + mobile (2 screenshots instead of 4).

### Step 3: Build Payload and Run Audit

After ALL screenshots are captured, construct a JSON object and pipe it to the audit script:

```json
{
  "site": "example.com",
  "pages": [
    {
      "url": "https://example.com/",
      "slug": "home",
      "screenshots": [
        "/tmp/ux-audit/home-desktop-light.png",
        "/tmp/ux-audit/home-desktop-dark.png",
        "/tmp/ux-audit/home-mobile-light.png",
        "/tmp/ux-audit/home-mobile-dark.png"
      ]
    },
    {
      "url": "https://example.com/about",
      "slug": "about",
      "screenshots": [...]
    }
  ],
  "context": "Brief description of what this site is and who it's for",
  "focus_areas": "Optional focus areas from user"
}
```

Run:
```bash
echo '<JSON>' | python3 ~/.claude/skills/ux-audit/scripts/ux-audit.py
```

### Step 4: Present Results

Print the full output from the script. Do NOT summarize, filter, or editorialize. Show everything Gemini returned. The audit is independent precisely because Claude does not interfere with the verdict.

After presenting, offer: "Want me to fix the top issues?"

## Deep Mode Workflow

When user specifies `deep` (e.g., `/ux-audit deep https://example.com`):

### Step 1: Prepare

```bash
rm -rf /tmp/ux-audit/deep && mkdir -p /tmp/ux-audit/deep
```

Parse URLs. If only a domain is given, infer key pages.

### Step 2: Build Payload and Run

Construct a JSON object and pipe to the deep audit script:

```json
{
  "site": "example.com",
  "urls": ["https://example.com/", "https://example.com/about", "https://example.com/waitlist"],
  "context": "Brief description of what this site is and who it's for",
  "focus_areas": "Optional focus areas",
  "auth": {
    "login_url": "https://example.com/login",
    "username": "user@example.com",
    "password": "secret"
  },
  "cdp_port": 9222
}
```

The `auth` field is optional. Only include it if the user provides credentials or the site requires login.

Run:
```bash
echo '<JSON>' | GEMINI_API_KEY=$GEMINI_API_KEY timeout 5m python3 ~/.claude/skills/ux-audit/scripts/ux-audit-deep.py
```

### Step 3: Present Results

Print the full output. Do NOT summarize or editorialize. The deep audit is fully autonomous: Gemini decides what to test, where to click, what forms to fill. Claude has zero influence on the testing decisions.

**What deep mode does that quick mode doesn't:**
- Gemini controls the browser directly via CDP (Chrome DevTools Protocol)
- Tests interactive elements: clicks buttons, fills forms, submits data
- Checks all navigation links for 404s
- Monitors JavaScript console errors
- Tests responsive behavior by resizing viewport
- Tests both light and dark themes
- Checks accessibility (headings, alt text, labels, focus indicators)
- Measures page load performance
- Takes screenshots as evidence throughout testing
- Up to 30 agentic turns of autonomous testing

### When to Use Deep vs Quick

| | Quick Mode | Deep Mode |
|---|---|---|
| Speed | ~30 seconds | 2-5 minutes |
| Method | Screenshots only | Autonomous browser testing |
| Interactive testing | No | Yes (clicks, forms, links) |
| Console errors | No | Yes |
| Accessibility | Visual only | Programmatic checks |
| Performance | No | Yes (timing metrics) |
| Auth support | No | Yes (credentials) |
| Use when | Quick score check | Pre-launch thorough audit |

## Important Rules

- **NEVER skip screenshots.** Every page needs all 4 variants (or 2 if no theme support).
- **ALWAYS use fullPage=true.** Gemini needs to see the entire page, not just the viewport.
- **ALWAYS force reveal animations.** Elements hidden by IntersectionObserver must be made visible before capture.
- **DO NOT pre-judge.** Let Gemini score independently. Do not add commentary like "I think this page looks good."
- **If chrome-devtools is unavailable**, fall back to `authenticated-browser` (Playwright) for screenshots.
- **Maximum 10 pages per audit** to stay within Gemini's context limits.
- **Deep mode requires Chrome on port 9222** (or specify cdp_port in the payload).
- **Deep mode timeout: 5 minutes max.** Use `timeout 5m` to prevent runaway audits.
