# Visual Verification Template

Browser-based QA protocol for verifying that features actually work in production.

## Core Principle

**"Code exists" != "feature works"**

A function can exist, tests can pass, pull requests can be approved, and the feature still won't render on the live site. Only visual verification with screenshots proves a feature works.

## Verification Steps

### 1. Setup
- Navigate to the live production site (not localhost, not a preview URL)
- Take a **before** screenshot showing initial state
- Document exact steps to trigger the feature

### 2. Execute
- Perform the action that should trigger the feature
- Wait for all network requests to complete
- Take an **after** screenshot

### 3. Assert (Positive Assertions Only)
- **YES** - "Similar jobs section displays 3 job cards"
- **YES** - "Price changed from $19 to $15 in the DOM"
- **NO** - "No bugs found" (absence != presence)
- **NO** - "Should be visible" (speculation, not verification)

## Common Verification Failures

| Failure | What went wrong | How to detect |
|---------|-----------------|---------------|
| "Code review passed, but feature didn't render" | Conditional logic blocked rendering | Screenshot shows blank area where component should be |
| "Query was correct but data didn't load" | Network request failed silently | Network panel shows error, or loading state never cleared |
| "Component exists but is positioned off-screen" | CSS/layout issue | Screenshot shows overflow or positioned outside viewport |
| "Feature works on my machine but not prod" | Environment-specific data or config | Prod screenshot differs from local; check env vars, feature flags, permissions |

## Screenshot Checklist

Before claiming a feature is fixed:
- [ ] Screenshot shows the actual rendered feature (not loading spinner, not error state)
- [ ] All related UI elements are present (buttons, text, prices, counts)
- [ ] Data matches expected values (exact count, exact price, correct names)
- [ ] Previous fixes still work (regression check with screenshot of older feature)
- [ ] Mobile viewport verified (use `resize_window` to 390x812 for mobile issues)

## Example: Verifying a Job Card Fix

**Issue**: Job cards show incorrect company name.

1. **Before screenshot** - Production site, job list visible, card shows wrong name
2. **Action** - Click job card, wait for 2 seconds
3. **After screenshot** - Card now shows correct company name
4. **Assertion** - "Job card displays 'Acme Corp' (verified with screenshot)"
5. **Regression check** - Verify previous fixes (job count, salary range, etc.) still work

## For Multi-State Features

Use accessibility snapshots (a11y trees) before/after to detect structural changes:

```bash
# Before action
browser_snapshot > before.txt

# After action
browser_snapshot > after.txt

# Diff to see what changed
diff before.txt after.txt
```

This catches UI changes that screenshots alone might miss.

## Mobile Testing

Responsive issues often only show on mobile viewports:

```
resize_window(390, 812)  # iPhone 12/13/14 Pro
take_screenshot()
```

Issues to check:
- Text overflow or truncation
- Button sizes (touch target minimum 44x44px)
- Modal/dropdown alignment
- Image aspect ratios

## Red Flags for Skipped Verification

If you think any of these, you're rationalizing skipped verification:
- "The code looks correct, so it should work" → Run it and screenshot it
- "Tests passed, so the feature is definitely fixed" → Verify on the live site
- "I saw it work on my machine" → Prod state is what matters
- "The deploy succeeded" → Deployment != feature working

**Rule: Screenshots are evidence, not optional.**
