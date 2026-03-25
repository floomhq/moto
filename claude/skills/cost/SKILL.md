---
name: cost
description: >
  Estimate and analyze costs for AI/cloud services, infrastructure, or feature implementations.
  Use when user asks "how much will this cost", "cost estimate", "cost analysis",
  "what's the pricing", "budget for this", or wants to understand the financial impact
  of a technical decision. Covers LLM API costs, cloud hosting, and SaaS tools.
---

# Cost Skill

## LLM API Pricing (as of early 2026)

Always verify current prices at the provider's pricing page - these change frequently.

### Anthropic Claude
| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|-------|----------------------|------------------------|
| Claude Opus 4 | ~$15 | ~$75 |
| Claude Sonnet 4 | ~$3 | ~$15 |
| Claude Haiku 3.5 | ~$0.80 | ~$4 |

### OpenAI
| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|-------|----------------------|------------------------|
| GPT-4o | ~$2.50 | ~$10 |
| GPT-4o mini | ~$0.15 | ~$0.60 |

### Google Gemini
| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|-------|----------------------|------------------------|
| Gemini 2.5 Pro | ~$1.25 | ~$10 |
| Gemini 2.5 Flash | ~$0.15 | ~$0.60 |

## Token Estimation

Rough approximations:
- 1 token ≈ 4 characters ≈ 0.75 words
- 1 page of text ≈ 750 tokens
- Average email ≈ 200-400 tokens
- Short code file ≈ 500-2000 tokens

## Cost Calculation

```python
def estimate_cost(
    input_tokens: int,
    output_tokens: int,
    input_price_per_million: float,
    output_price_per_million: float
) -> float:
    input_cost = (input_tokens / 1_000_000) * input_price_per_million
    output_cost = (output_tokens / 1_000_000) * output_price_per_million
    return input_cost + output_cost

# Example: 1000 requests with 500 input tokens, 200 output tokens each
# Using Claude Sonnet ($3 in, $15 out per 1M)
total_input = 1000 * 500   # 500K tokens
total_output = 1000 * 200  # 200K tokens
cost = estimate_cost(total_input, total_output, 3, 15)
# = $0.15 + $3.00 = $3.15 for 1000 requests
```

## Cloud Hosting (rough estimates)

| Service | Small | Medium | Large |
|---------|-------|--------|-------|
| Vercel (hobby) | Free | $20/mo | $150+/mo |
| Render (web service) | $7/mo | $25/mo | $85+/mo |
| Hetzner VPS | €5/mo | €20/mo | €80+/mo |
| AWS EC2 (t3) | $15/mo | $60/mo | $250+/mo |

## Analysis Framework

When asked to estimate costs:

1. **Identify usage patterns**: How many requests/day? Batch or real-time?
2. **Estimate token counts**: Input context size + expected output size
3. **Calculate monthly volume**: requests/day × 30
4. **Apply pricing**: Use the table above or current pricing page
5. **Add buffer**: Add 20-30% for variance and growth
6. **Compare alternatives**: Show cost at different models/providers

## Output Format

```
COST ESTIMATE: [Feature/Service]

Assumptions:
- [usage volume]
- [average token counts]
- [model/provider]

Monthly estimate:
- API calls: [N] × $[X] = $[Y]/month
- Hosting: $[Z]/month
- Total: ~$[TOTAL]/month

At scale (10x):
- Total: ~$[10x TOTAL]/month

Recommendation: [cheapest option that meets requirements]
```
