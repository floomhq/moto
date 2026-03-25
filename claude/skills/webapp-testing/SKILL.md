---
name: webapp-testing
description: Toolkit for interacting with and testing local web applications using Playwright. Supports verifying frontend functionality, debugging UI behavior, capturing browser screenshots, and viewing browser logs.
---

# Web Application Testing

To test local web applications, write native Python Playwright scripts.

## Decision Tree: Choosing Your Approach

```
User task → Is it static HTML?
    ├─ Yes → Read HTML file directly to identify selectors
    │         ├─ Success → Write Playwright script using selectors
    │         └─ Fails/Incomplete → Treat as dynamic (below)
    │
    └─ No (dynamic webapp) → Is the server already running?
        ├─ No → Start the server first, then write Playwright script
        └─ Yes → Reconnaissance-then-action:
            1. Navigate and wait for networkidle
            2. Take screenshot or inspect DOM
            3. Identify selectors from rendered state
            4. Execute actions with discovered selectors
```

## Starting a Server for Testing

```bash
# Start server in background, wait for it to be ready, then run automation
npm run dev &
sleep 3
python automation.py
```

Or manage the server lifecycle in the script itself:
```python
import subprocess
import time

server = subprocess.Popen(["npm", "run", "dev"])
time.sleep(3)  # Wait for server to start

try:
    # Run automation
    pass
finally:
    server.terminate()
```

## Basic Playwright Script

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto('http://localhost:5173')
    page.wait_for_load_state('networkidle')  # CRITICAL: Wait for JS to execute

    # Take screenshot for inspection
    page.screenshot(path='/tmp/inspect.png', full_page=True)

    # Inspect DOM
    content = page.content()

    # Execute actions
    page.click('button:has-text("Submit")')
    page.fill('input[name="email"]', 'test@example.com')

    # Assert results
    assert page.locator('.success-message').is_visible()

    browser.close()
```

## Reconnaissance-Then-Action Pattern

1. **Inspect rendered DOM**:
   ```python
   page.screenshot(path='/tmp/inspect.png', full_page=True)
   content = page.content()
   buttons = page.locator('button').all()
   ```

2. **Identify selectors** from inspection results

3. **Execute actions** using discovered selectors

## Common Pitfall

Do NOT inspect the DOM before waiting for `networkidle` on dynamic apps. Wait first, then inspect.

## Best Practices

- Use `sync_playwright()` for synchronous scripts
- Always close the browser when done
- Use descriptive selectors: `text=`, `role=`, CSS selectors, or IDs
- Add appropriate waits: `page.wait_for_selector()` or `page.wait_for_timeout()`
- Always launch chromium in headless mode for CI/automation
- Take screenshots at key points for debugging

## Selector Strategies

```python
# By text
page.click('text=Submit')
page.click('button:has-text("Login")')

# By role
page.get_by_role('button', name='Submit').click()
page.get_by_role('textbox', name='Email').fill('test@example.com')

# By CSS
page.click('#submit-btn')
page.click('.form-submit')

# By test ID (best for stable tests)
page.click('[data-testid="submit-button"]')
```

## Capturing Console Logs

```python
messages = []
page.on('console', lambda msg: messages.append(f'{msg.type}: {msg.text}'))
page.goto('http://localhost:3000')
# ... interact with page
print('\n'.join(messages))
```
