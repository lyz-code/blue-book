[Playwright](https://playwright.dev/python/) is a modern automation library developed by Microsoft (buuuuh!) for testing web applications. It provides a powerful API for controlling web browsers, allowing developers to perform end-to-end testing, automate repetitive tasks, and gather insights into web applications. Playwright supports multiple browsers and platforms, making it a versatile tool for ensuring the quality and performance of web applications.

## Key features

### Cross-browser testing

Playwright supports testing across major browsers including:

- Google Chrome and Chromium-based browsers
- Mozilla Firefox
- Microsoft Edge
- WebKit (the engine behind Safari)

This cross-browser support ensures that your web application works consistently across different environments.

### Headless mode

Playwright allows you to run browsers in headless mode, which means the browser runs without a graphical user interface. This is particularly useful for continuous integration pipelines where you need to run tests on a server without a display.

### Auto-waiting

Playwright has built-in auto-waiting capabilities that ensure elements are ready before interacting with them. This helps in reducing flaky tests caused by timing issues and improves test reliability.

### Network interception

Playwright provides the ability to intercept and modify network requests. This feature is valuable for testing how your application behaves with different network conditions or simulating various server responses.

### Powerful selectors

Playwright offers a rich set of selectors to interact with web elements. You can use CSS selectors, XPath expressions, and even text content to locate elements. This flexibility helps in accurately targeting elements for interaction.

### Multiple language support

Playwright supports multiple programming languages including:

- JavaScript/TypeScript
- Python
- C#
- Java

This allows teams to write tests in their preferred programming language.


# Installation

To get started with Playwright, you'll need to install it via pip. Here's how to install Playwright for Python:

```bash
pip install playwright
playwright install chromium
```

The last line installs the browsers inside `~/.cache/ms-playwright/`.

# Usage

## Basic example

Here's a simple example of using Playwright with Python to automate a browser:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    # Launch a new browser instance
    browser = p.chromium.launch()
    
    # Create a new browser context and page
    context = browser.new_context()
    page = context.new_page()
    
    # Navigate to a webpage
    page.goto('https://example.com')
    
    # Take a screenshot
    page.screenshot(path='screenshot.png')
    
    # Close the browser
    browser.close()
```

## [A testing example](https://playwright.dev/python/docs/intro#add-example-test)

```python
import re
from playwright.sync_api import Page, expect

def test_has_title(page: Page):
    page.goto("https://playwright.dev/")

    # Expect a title "to contain" a substring.
    expect(page).to_have_title(re.compile("Playwright"))

def test_get_started_link(page: Page):
    page.goto("https://playwright.dev/")

    # Click the get started link.
    page.get_by_role("link", name="Get started").click()

    # Expects page to have a heading with the name of Installation.
    expect(page.get_by_role("heading", name="Installation")).to_be_visible()
```

# References

- [Home](https://playwright.dev/python/)
- [Docs](https://playwright.dev/python/docs/intro)
- [Source](https://github.com/microsoft/playwright-python)
- [Video tutorials](https://playwright.dev/python/community/learn-videos)
