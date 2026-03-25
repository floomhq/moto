---
name: subagent-templates
description: >
  Templates and patterns for spawning and coordinating subagents (parallel Claude instances).
  Use when a task benefits from parallelization, independent verification, or specialized
  sub-tasks. Triggers: "use subagents", "spawn agents", "parallelize this", "run in parallel",
  "use multiple agents", or when a task has clearly independent parallel workstreams.
---

# Subagent Templates

## When to Use Subagents

**Good uses:**
- Independent tasks that can run in parallel (QA checks, analysis, validation)
- Tasks requiring fresh context/perspective (reader testing, independent review)
- Large workloads that can be split by domain or file
- Verification tasks that should be independent from the author

**Bad uses:**
- Tasks with sequential dependencies (B must run after A finishes)
- Tasks requiring shared state that's hard to merge
- Simple tasks where coordination overhead exceeds benefit

## Pattern 1: Parallel Analysis

Split a large analysis into independent slices, run in parallel, merge results.

```
TASK: Analyze codebase for security issues

SUBAGENTS:
- Agent A: Check authentication and authorization code
- Agent B: Check API input validation and sanitization
- Agent C: Check environment variables and secrets handling
- Agent D: Check dependency vulnerabilities

MERGE: Collect all findings, deduplicate, prioritize by severity
```

## Pattern 2: Independent Verification

Have a fresh agent verify work without the context bias of the original agent.

```
TASK: Verify the PDF skill QA

SUBAGENT PROMPT:
"You are a QA engineer reviewing this slide presentation for issues.
Assume there ARE problems - your job is to find them.
Here is the content: [content]

Check for:
- Missing content
- Overlapping elements
- Text overflow
- Leftover placeholder text

Report ALL issues found, even minor ones."
```

## Pattern 3: Parallel Implementation

Split implementation across files/modules, implement in parallel, merge.

```
TASK: Add dark mode support

SUBAGENTS:
- Agent A: Update color tokens and CSS variables
- Agent B: Update component themes (buttons, cards, inputs)
- Agent C: Update charts and data visualizations

MERGE: Review for consistency across all changes
```

## Pattern 4: Research and Synthesis

Multiple agents research different aspects, main agent synthesizes.

```
TASK: Evaluate three database options

SUBAGENTS:
- Agent A: Research PostgreSQL - performance, pricing, hosting options
- Agent B: Research PlanetScale - performance, pricing, limitations
- Agent C: Research Supabase - performance, pricing, auth integration

MAIN AGENT: Synthesize findings into recommendation
```

## Effective Subagent Prompts

### Structure
```
You are a [ROLE] working on [SPECIFIC TASK].

Your ONLY job is to [NARROW SCOPE].

Context you need:
[MINIMAL REQUIRED CONTEXT - only what's needed for this sub-task]

Do NOT:
- [thing outside scope]
- [thing outside scope]

Output format:
[SPECIFIC FORMAT]
```

### Key principles
- **Narrow scope**: Each subagent should have ONE clear job
- **Minimal context**: Only provide what's needed for the sub-task
- **Specific output format**: Make results easy to merge
- **Independent**: Subagents should not depend on each other's output
- **Fresh perspective**: Don't leak your conclusions into the subagent prompt for verification tasks

## Merging Subagent Results

After parallel execution:
1. Collect all outputs
2. Deduplicate (same finding reported by multiple agents)
3. Resolve conflicts (agents disagree - investigate)
4. Synthesize into final result

If agents disagree, investigate the discrepancy before accepting either result.
