---
name: seo
description: >
  Technical SEO auditor for programmatic pages, landing pages, and content clusters.
  Use when user says "seo audit", "check seo", "seo review", "technical seo",
  "schema.org check", "sitemap review", "indexability", "seo skill", or when reviewing
  any plan/code that involves search engine optimization, programmatic page generation,
  structured data, or organic traffic strategy. Covers: on-page SEO, schema.org validation,
  sitemap/robots analysis, internal linking, thin content detection, keyword cannibalization,
  international SEO (hreflang), SERP feature targeting, and Core Web Vitals impact.
---

# SEO Audit Framework

Systematic technical SEO review for web pages and programmatic SEO plans.

## Audit Process

Run every check in order. Score each dimension 0-10. Final score = average of all dimensions.

---

## Dimension 1: Crawlability & Indexability

### Checks
- [ ] **robots.txt**: Does it allow crawling of target pages? Any accidental Disallow?
- [ ] **Meta robots**: No unintended `noindex` on production pages. Preview/staging HAS `noindex`.
- [ ] **X-Robots-Tag header**: Consistent with meta robots (belt and suspenders for staging).
- [ ] **Sitemap**: All target pages included. `lastModified` accurate. `changeFrequency` appropriate.
- [ ] **Sitemap size**: Under 50,000 URLs per sitemap. Split if larger.
- [ ] **Canonical URLs**: Every page has `<link rel="canonical">`. No duplicates pointing to same canonical.
- [ ] **HTTP status codes**: Target pages return 200. Invalid slugs return 404 (not soft 404).
- [ ] **Redirect chains**: No chain > 2 hops. No redirect loops.
- [ ] **Pagination**: If paginated, proper `rel="next"`/`rel="prev"` or "view all" page.
- [ ] **JavaScript rendering**: Content visible without JS? Google renders JS but delays indexing.

### Red Flags
- Pages returning 200 with empty/minimal content (soft 404)
- robots.txt blocking CSS/JS files Google needs to render
- Sitemap URLs not matching canonical URLs
- Orphan pages (no internal links pointing to them)

---

## Dimension 2: On-Page SEO

### Checks
- [ ] **Title tag**: Under 60 chars. Contains primary keyword. Unique per page.
- [ ] **Meta description**: 120-160 chars. Contains keyword + CTA. Unique per page.
- [ ] **H1**: One per page. Contains primary keyword. Not identical to title tag.
- [ ] **URL structure**: Short, descriptive, keyword-containing. Hyphens between words.
- [ ] **Content depth**: > 300 words of unique content per page. NOT just a widget/CTA.
- [ ] **Keyword in first 100 words**: Primary keyword appears naturally in opening text.
- [ ] **Image alt text**: All images have descriptive alt text with keywords where natural.
- [ ] **Internal links**: At least 2-3 contextual internal links per page.
- [ ] **External links**: Relevant outbound links (adds trust, E-E-A-T signal).
- [ ] **Content uniqueness**: No two pages targeting same keyword (cannibalization).

### Title Tag Formula for Programmatic Pages
```
{Primary Keyword}: {Secondary Keyword} & {Differentiator} | {Brand}
Example: "Flights Berlin to London: Flight Time, Airlines & Safety | YourBrand"
```

### Thin Content Scoring
Every programmatic page needs a minimum content score:
| Content Element | Points |
|----------------|-------:|
| Unique data (prices, times, distances) | 3 |
| Safety/quality analysis (unique to your site) | 3 |
| FAQ with 4+ substantive answers | 2 |
| Contextual internal links | 1 |
| Media (images, charts, maps) | 1 |
| **Minimum to publish** | **7** |

Pages scoring < 7 are thin content candidates. Either enrich or don't publish.

---

## Dimension 3: Schema.org / Structured Data

### Checks
- [ ] **JSON-LD format**: Using `<script type="application/ld+json">` (not microdata/RDFa).
- [ ] **Valid JSON**: No syntax errors. Test with Google Rich Results Test.
- [ ] **Correct @type**: Using appropriate schema types for content.
- [ ] **Required properties**: All required properties for the @type are present.
- [ ] **No schema spam**: Only schema types that match actual page content.
- [ ] **BreadcrumbList**: Present on all pages below root. Matches visual breadcrumb.
- [ ] **FAQPage**: Questions and answers are visible on the page (not hidden). Google requires this.
- [ ] **Nesting**: Nested schemas use correct parent-child relationships.

### Schema Types for Common Page Types
| Page Type | Schema Types |
|-----------|-------------|
| Route/flight page | FAQPage + BreadcrumbList |
| Index/listing page | ItemList + BreadcrumbList |
| How-to/methodology | HowTo + BreadcrumbList |
| Product page | Product + AggregateOffer + BreadcrumbList |
| Article/blog | Article + BreadcrumbList |
| Contact page | FAQPage + ContactPoint |

### FAQPage Requirements (Google)
- Questions MUST be visible on the page (not accordion-only, not behind JS)
- Answers must be substantive (not "click here to find out")
- Max 3-5 questions per page for best PAA targeting
- Questions should match real PAA queries (check SERPs)

---

## Dimension 4: International SEO

### Checks
- [ ] **hreflang tags**: Present on every page. All locales cross-referenced.
- [ ] **x-default**: Set for the primary/fallback locale.
- [ ] **Return links**: If page A has hreflang to page B, page B has hreflang to page A.
- [ ] **Language-region codes**: Using correct format (e.g., `en`, `de`, not `en_US` unless targeting region).
- [ ] **URL structure**: Consistent pattern (`/en/page`, `/de/page` or subdomain).
- [ ] **Canonical per locale**: Each locale version has its OWN canonical (not all pointing to EN).
- [ ] **Content quality per locale**: Non-primary locales have adequate translation quality.
- [ ] **Locale in sitemap**: `alternates.languages` object in sitemap entries.

### Common Mistakes
- All locales sharing one canonical URL (kills non-EN indexing)
- Machine-translated content triggering "auto-generated content" penalty
- Missing hreflang return links (orphaned locale versions)
- Mixing `en` and `en-US` format in hreflang tags

---

## Dimension 5: Internal Linking

### Checks
- [ ] **Hub-and-spoke**: Topic cluster has a pillar/hub page linking to all child pages.
- [ ] **Bidirectional**: Child pages link back to hub. Hub links to children.
- [ ] **Cross-cluster links**: Related clusters link to each other where relevant.
- [ ] **Anchor text**: Descriptive, keyword-containing (not "click here").
- [ ] **Crawl depth**: Target pages reachable in <= 3 clicks from homepage.
- [ ] **No orphan pages**: Every page has at least 1 internal link pointing to it.
- [ ] **Breadcrumbs**: Visual breadcrumbs match BreadcrumbList schema.
- [ ] **Footer/nav links**: Key pages accessible from global navigation.

### Linking Architecture for Programmatic SEO
```
Homepage
  --> /flights (index hub, in footer/nav)
        --> /flights/berlin-to-london (route pages)
              --> /safety/[zone] (cross-cluster to safety)
              --> /flights/london-to-berlin (reverse route)
              --> / (CTA to search)
        --> /flights/from-berlin (origin hub, Phase 2)
  --> /safety (existing cluster)
        --> /safety/[zone] (zone detail)
              --> /flights/[route] (cross-cluster to routes near zone)
```

---

## Dimension 6: SERP Feature Targeting

### Checks
- [ ] **PAA targeting**: FAQPage schema questions match actual PAA queries from SERPs.
- [ ] **Featured snippet format**: Answer paragraphs are concise (40-60 words), immediately follow the question.
- [ ] **Table snippets**: Structured data in tables for comparison queries.
- [ ] **Knowledge panel**: Organization schema complete and accurate.
- [ ] **Sitelinks**: Clear nav hierarchy helps Google generate sitelinks.
- [ ] **Image search**: Images have alt text, are high quality, unique filenames.

### PAA Optimization
1. Research actual PAA questions for target keywords (use DataForSEO SERP API)
2. Use those EXACT questions as FAQ entries
3. Answer in first sentence (featured snippet extraction)
4. Add detail in following sentences
5. Wrap in FAQPage schema

---

## Dimension 7: Performance & Core Web Vitals

### Checks
- [ ] **LCP (Largest Contentful Paint)**: < 2.5s. No render-blocking resources above fold.
- [ ] **FID/INP (Interaction to Next Paint)**: < 200ms. Minimal JS on programmatic pages.
- [ ] **CLS (Cumulative Layout Shift)**: < 0.1. No images without dimensions. No dynamic content injection above fold.
- [ ] **Page weight**: < 500KB total for programmatic pages (text-heavy, minimal JS).
- [ ] **Server response time**: < 200ms TTFB. ISR/SSG helps.
- [ ] **Image optimization**: WebP/AVIF format, lazy loading below fold, explicit dimensions.
- [ ] **Font loading**: `font-display: swap` or `optional`. No FOIT.

### ISR Considerations
- `revalidate` period: 3600s (1 hour) is good for daily-updated content
- `generateStaticParams` for high-traffic pages only (pre-render)
- `dynamicParams = true` for long-tail pages (ISR on first visit)

---

## Dimension 8: Programmatic SEO Specific

### Checks
- [ ] **No duplicate content across pages**: Each page has unique H1, title, meta description, and body content.
- [ ] **Template variation**: Pages don't look identical. Content sections vary based on data.
- [ ] **Value-add over manual pages**: Programmatic pages offer data/analysis not available elsewhere.
- [ ] **Noindex thin pages**: If a page can't reach content score 7, it gets `noindex`.
- [ ] **Cannibalization audit**: No two pages target the same primary keyword.
- [ ] **Freshness signals**: "Updated [date]" visible, `lastModified` in sitemap, regular content updates.
- [ ] **Error states**: Pages handle missing data gracefully (not empty/broken).
- [ ] **404 for invalid slugs**: Random URLs return proper 404, not empty 200.

### Google's Programmatic SEO Guidelines (Helpful Content Update)
1. Each page must demonstrate E-E-A-T (Experience, Expertise, Authoritativeness, Trustworthiness)
2. Content must be created primarily for users, not search engines
3. Pages must provide substantial value beyond what's available elsewhere
4. Auto-generated content at scale requires quality controls
5. Thin/duplicate pages in the same topic can drag down the entire domain

---

## Scoring

After running all checks, score each dimension:
| Dimension | Score | Notes |
|-----------|------:|-------|
| 1. Crawlability & Indexability | /10 | |
| 2. On-Page SEO | /10 | |
| 3. Schema.org | /10 | |
| 4. International SEO | /10 | |
| 5. Internal Linking | /10 | |
| 6. SERP Feature Targeting | /10 | |
| 7. Performance & CWV | /10 | |
| 8. Programmatic SEO | /10 | |
| **Overall** | **/10** | Average |

**Passing score: 8/10 overall, no dimension below 6/10.**

---

## Quick Audit Command

When invoked as `/seo`, run the full 8-dimension audit against the current plan or code changes. Output the scoring table with specific findings per dimension.
