---
name: browse
description: >
  Browse the web, read pages, extract information, and interact with websites.
  Use when user asks to "look up", "browse to", "check the website", "read this URL",
  "search for", "find information about", or needs current information from the web.
  Handles navigation, content extraction, form interaction, and screenshots.
---

# Browse Skill

## Tool Selection

Three browser tool sets may be available. Use the right one for the task:

| Tool set | Use for |
|----------|---------|
| **claude-in-chrome** | Page reading, clicking, form filling, screenshots, navigation |
| **chrome-devtools** | Performance tracing, Lighthouse, network inspection |
| **authenticated-browser** | Playwright scripts, complex multi-step flows |

**Default to `claude-in-chrome`** for standard browse/read/click/screenshot tasks.

## Common Patterns

### Reading a web page

1. Navigate to the URL
2. Take a snapshot (a11y tree) to understand the page structure
3. Extract the relevant content
4. If content is incomplete, scroll or click to load more

### Searching for information

1. Navigate to a search engine or the site's search
2. Enter the search query
3. Read the results
4. Navigate to the most relevant result
5. Extract the needed information

### Filling out a form

1. Navigate to the page
2. Take a snapshot to identify form fields
3. Fill each field
4. Verify the filled values before submitting
5. Submit and confirm success

### Handling blocked URLs

If WebFetch is blocked (paywalled, Reddit, etc.), try:
```bash
# Gemini fallback for web content
bash ~/.claude/scripts/gemini-fetch.sh "https://blocked-url.com"
```

## Content Extraction Tips

- Use `get_page_text` for article-heavy pages (blog posts, documentation, news)
- Use `take_snapshot` for interactive pages where you need to find elements
- Use `take_screenshot` to verify visual state
- For JavaScript-heavy SPAs: wait for `networkidle` before extracting

## Privacy & Security

- Never enter passwords or sensitive credentials
- Be cautious with forms on unfamiliar sites
- Do not click "Accept all cookies" on cookie banners - decline or dismiss
- Do not download files without explicit user permission

## Output Format

When reporting what was found:
- Summarize key information (don't reproduce entire pages)
- Quote specific short passages when precision matters (fewer than 15 words per quote)
- Provide the source URL
- Note if information may be outdated
