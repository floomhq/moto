---
name: algorithmic-art
description: Creating algorithmic art using p5.js with seeded randomness and interactive parameter exploration. Use this when users request creating art using code, generative art, algorithmic art, flow fields, or particle systems. Create original algorithmic art rather than copying existing artists' work.
---

Algorithmic philosophies are computational aesthetic movements that are then expressed through code. Output .md files (philosophy), .html files (interactive viewer), and .js files (generative algorithms).

This happens in two steps:
1. Algorithmic Philosophy Creation (.md file)
2. Express by creating p5.js generative art (.html + .js files)

## STEP 1: ALGORITHMIC PHILOSOPHY CREATION

Create an ALGORITHMIC PHILOSOPHY (not static images or templates) that will be interpreted through:
- Computational processes, emergent behavior, mathematical beauty
- Seeded randomness, noise fields, organic systems
- Particles, flows, fields, forces
- Parametric variation and controlled chaos

### THE CRITICAL UNDERSTANDING
- What is received: Subtle input from the user, used as a foundation - not a constraint on creative freedom.
- What is created: An algorithmic philosophy/generative aesthetic movement.
- What happens next: The same session receives the philosophy and EXPRESSES IT IN CODE - creating p5.js sketches that are 90% algorithmic generation, 10% essential parameters.

### HOW TO GENERATE AN ALGORITHMIC PHILOSOPHY

**Name the movement** (1-2 words): "Organic Turbulence" / "Quantum Harmonics" / "Emergent Stillness"

**Articulate the philosophy** (4-6 paragraphs):

Capture the ALGORITHMIC essence through:
- Computational processes and mathematical relationships
- Noise functions and randomness patterns
- Particle behaviors and field dynamics
- Temporal evolution and system states
- Parametric variation and emergent complexity

**CRITICAL**: Emphasize craftsmanship REPEATEDLY - the final algorithm must feel meticulously crafted, refined through countless iterations, the product of deep expertise.

**The algorithmic philosophy should be 4-6 paragraphs long.** Output as a .md file.

---

## STEP 2: DEDUCING THE CONCEPTUAL SEED

Identify the subtle conceptual thread from the original request. The concept is a **subtle, niche reference embedded within the algorithm itself** - someone familiar with the subject should feel it intuitively.

---

## STEP 3: P5.JS IMPLEMENTATION

### TECHNICAL REQUIREMENTS

**Seeded Randomness (Art Blocks Pattern)**:
```javascript
// ALWAYS use a seed for reproducibility
let seed = 12345;
randomSeed(seed);
noiseSeed(seed);
```

**Parameter Structure**:
```javascript
let params = {
  seed: 12345,  // Always include seed for reproducibility
  // Add parameters that control the algorithm:
  // - Quantities (how many?)
  // - Scales (how big? how fast?)
  // - Probabilities (how likely?)
  // - Ratios (what proportions?)
};
```

**Core Algorithm - EXPRESS THE PHILOSOPHY**:

The algorithmic philosophy should dictate what to build. Do not ask "which pattern should I use?" - ask "how to express this philosophy through code?"

If the philosophy is about **organic emergence**, use:
- Elements that accumulate or grow over time
- Random processes constrained by natural rules
- Feedback loops and interactions

If the philosophy is about **mathematical beauty**, use:
- Geometric relationships and ratios
- Trigonometric functions and harmonics

If the philosophy is about **controlled chaos**, use:
- Random variation within strict boundaries
- Order emerging from disorder

**Canvas Setup**:
```javascript
function setup() {
  createCanvas(1200, 1200);
}

function draw() {
  // Your generative algorithm
}
```

### CRAFTSMANSHIP REQUIREMENTS

- **Balance**: Complexity without visual noise, order without rigidity
- **Color Harmony**: Thoughtful palettes, not random RGB values
- **Composition**: Even in randomness, maintain visual hierarchy and flow
- **Performance**: Smooth execution, optimized for real-time if animated
- **Reproducibility**: Same seed ALWAYS produces identical output

### OUTPUT FORMAT

1. **Algorithmic Philosophy** - As a .md file
2. **Single HTML Artifact** - Self-contained interactive generative art

The HTML artifact contains everything: p5.js (from CDN), the algorithm, parameter controls, and UI - all in one file.

### INTERACTIVE FEATURES

**Required features:**
- Sliders for numeric parameters (particle count, noise scale, speed, etc.)
- Seed navigation: display current seed, Previous/Next/Random/Jump buttons
- Download PNG button
- Real-time updates when parameters change
