---
name: product
description: >
  Product strategy and UX decision-making for user-facing features. Use when
  asked about "product decision", "UX strategy", "how should we present this",
  "user trust", "what should the user see", "is this confusing", "zero friction",
  "product skill", or any question about how a feature should feel, communicate,
  or behave from the user's perspective. Also trigger when discussing feature
  positioning, onboarding flows, trust signals, progressive disclosure, or
  when there's a gap between what the product does and what the user understands.
---

# Product Decision Framework

Think through every product decision as: **what does the user need to know, feel, and do?**

## Core Philosophy

- **Zero confusion** - If a user has to think about how something works, redesign it
- **Honest by default** - State limitations plainly. Users respect honesty.
- **No dark patterns** - No tricks, urgency, guilt, or manipulation
- **Simplicity wins** - One clear path beats three clever options
- **Earn trust, don't claim it** - Show what you do, don't say "trust us"

## Decision Process

For every product/UX question, work through these five steps:

### 1. Identify the Job-to-be-Done

Not the feature, not the task: the outcome the user wants.
- "Search for flights" is a task. "Find the cheapest safe flight to visit family" is a job.
- The job tells you what matters. Everything else is noise.

### 2. Map Friction Points

Walk the experience step by step. At each step:
- **Clarity**: Does the user know what to do next?
- **Feedback**: Does the user know what just happened?
- **Credibility**: Does the user trust what they see?
- **Forgiveness**: Can the user recover from mistakes?

Flag every moment of confusion, hesitation, or doubt.

### 3. Apply Trust Signals

Users trust products that are transparent about:
- **What's happening** - "Searching 847 routes..." not a spinner
- **What's limited** - "Preview may not catch everything" not silence
- **What's AI vs. deterministic** - Users calibrate trust differently for each
- **What costs money/time** - No surprises after commitment

### 4. Choose Disclosure Level

Layer information by need:
- **L0 (everyone)**: Primary action, key feedback. If >20% need it, it's L0.
- **L1 (curious)**: Details, explanations. Accessible on hover/click.
- **L2 (power users)**: Settings, advanced options. If <5% need it, it's L2.

### 5. Write the Copy

- **Labels**: verb + object ("Search flights", "Clear filters")
- **Descriptions**: what it does, not how ("Shows airports behind each city")
- **Errors**: what went wrong + what to do ("No flights found. Try wider dates.")
- **Empty states**: guide, don't apologize ("Type a destination to start")

Avoid: "smart", "intelligent", "powered by AI", "magic" - these erode trust.
Prefer: specific, concrete, honest language describing actual behavior.

## Common Patterns

### Feature has partial coverage / is experimental
- Label: "Preview" (not "beta" or "experimental" - too technical)
- Set expectations: "Works best with city and country names"
- Show the reliable fallback: "AI refines your full query on search"

### AI does something but user doesn't know
- Make AI visible at the right moment, not before, not after
- "AI parsed 3 destinations from your query" > silently showing results
- Show the AI's interpretation so the user can correct it

### Two systems do similar things (instant preview vs. AI-powered final)
- Never show both without explaining the relationship
- Frame as stages: "Preview (instant) -> Full search (AI-powered)"
- The preview must NEVER contradict the final result

### User might not trust the output
- Show your work: intermediate steps, sources, confidence
- Let them verify: "Based on Google Flights data as of today"
- Give control: "Edit parsed query" instead of a black box

## Anti-Patterns (Never Do These)

- Showing a feature that works 70% of the time without indicating uncertainty
- Using "AI-powered" as a trust badge (it's the opposite for savvy users)
- Hiding limitations behind optimistic UI
- Making the user feel stupid when the system fails
- Requiring the user to learn the system's mental model
- Loading states without information ("Loading..." vs "Checking 12 airlines...")

## Output Format

For every product decision, deliver:
1. **Diagnosis**: The actual user problem (not the feature problem)
2. **Recommendation**: One clear direction with rationale
3. **Copy/UX spec**: Exact text, placement, behavior
4. **Wireframe**: ASCII or HTML mockup when the decision is visual
5. **Edge cases**: What happens when it breaks, is empty, or is slow
