---
name: doc-coauthoring
description: Guide users through a structured workflow for co-authoring documentation. Use when user wants to write documentation, proposals, technical specs, decision docs, or similar structured content. This workflow helps users efficiently transfer context, refine content through iteration, and verify the doc works for readers. Trigger when user mentions writing docs, creating proposals, drafting specs, or similar documentation tasks.
---

# Doc Co-Authoring Workflow

This skill provides a structured workflow for guiding users through collaborative document creation. Act as an active guide, walking users through three stages: Context Gathering, Refinement & Structure, and Reader Testing.

## When to Offer This Workflow

**Trigger conditions:**
- User mentions writing documentation: "write a doc", "draft a proposal", "create a spec", "write up"
- User mentions specific doc types: "PRD", "design doc", "decision doc", "RFC"
- User seems to be starting a substantial writing task

**Initial offer:**
Offer the user a structured workflow for co-authoring the document. Explain the three stages:

1. **Context Gathering**: User provides all relevant context while Claude asks clarifying questions
2. **Refinement & Structure**: Iteratively build each section through brainstorming and editing
3. **Reader Testing**: Test the doc with a fresh Claude (no context) to catch blind spots before others read it

Ask if they want to try this workflow or prefer to work freeform.

## Stage 1: Context Gathering

**Goal:** Close the gap between what the user knows and what Claude knows.

### Initial Questions

Ask for meta-context about the document:

1. What type of document is this? (e.g., technical spec, decision doc, proposal)
2. Who's the primary audience?
3. What's the desired impact when someone reads this?
4. Is there a template or specific format to follow?
5. Any other constraints or context to know?

### Info Dumping

Encourage the user to dump all the context they have:
- Background on the project/problem
- Related discussions or documents
- Why alternative solutions aren't being used
- Organizational context (team dynamics, past incidents)
- Timeline pressures or constraints
- Technical architecture or dependencies

**During context gathering**, ask clarifying questions when the user signals they've done their initial dump. Generate 5-10 numbered questions based on gaps.

**Exit condition:** Sufficient context has been gathered when questions show understanding - when edge cases and trade-offs can be asked about without needing basics explained.

## Stage 2: Refinement & Structure

**Goal:** Build the document section by section through brainstorming, curation, and iterative refinement.

**For each section:**

### Step 1: Clarifying Questions
Ask 5-10 clarifying questions about what should be included.

### Step 2: Brainstorming
Brainstorm 5-20 things that might be included in this section.

### Step 3: Curation
Ask which points should be kept, removed, or combined. Examples:
- "Keep 1,4,7,9"
- "Remove 3 (duplicates 1)"
- "Combine 11 and 12"

### Step 4: Gap Check
Ask if there's anything important missing.

### Step 5: Drafting
Draft the section based on what they've selected.

### Step 6: Iterative Refinement
Make edits based on feedback using str_replace (never reprint the whole doc).

**Continue iterating** until user is satisfied with the section.

### Near Completion

When 80%+ of sections are done, re-read the entire document and check for:
- Flow and consistency across sections
- Redundancy or contradictions
- Anything that feels like generic filler
- Whether every sentence carries weight

## Stage 3: Reader Testing

**Goal:** Test the document with a fresh Claude (no context bleed) to verify it works for readers.

### Testing Approach (if sub-agents available)

1. **Predict Reader Questions**: Generate 5-10 questions readers would realistically ask
2. **Test with Sub-Agent**: Invoke a sub-agent with just the document content and each question
3. **Report and Fix**: Report what Reader Claude got right/wrong, fix gaps

### Testing Approach (manual)

1. **Predict Reader Questions**: Generate 5-10 realistic reader questions
2. **Setup Testing**: Open a fresh Claude conversation, paste the document content, ask the generated questions
3. **Iterate Based on Results**: Fix sections where Reader Claude struggled

### Exit Condition

When Reader Claude consistently answers questions correctly and doesn't surface new gaps, the doc is ready.

## Final Review

Before completion:
1. Recommend a final read-through by the user - they own this document
2. Suggest double-checking any facts, links, or technical details
3. Ask them to verify it achieves the desired impact

## Tips for Effective Guidance

**Tone:** Be direct and procedural. Don't try to "sell" the approach - just execute it.

**Handling Deviations:**
- If user wants to skip a stage: Ask if they want to skip and work freeform
- If user seems frustrated: Suggest ways to move faster
- Always give user agency to adjust the process

**Quality over Speed:**
- Don't rush through stages
- Each iteration should make meaningful improvements
- The goal is a document that actually works for readers
