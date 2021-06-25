---
title: Selenium
date: 20210624
author: Lyz
---

[Selenium](https://en.wikipedia.org/wiki/Selenium_%28software%29) is a portable
framework for testing web applications. It also provides a test domain-specific
language (Selenese) to write tests in a number of popular programming
languages.

# Web driver backends

Selenium can be used with many browsers, such as [Firefox](#firefox),
[Chrome](#chrome) or
[PhantomJS](#phantomjs). But first, install `selenium`:

```bash
pip install selenium
```

## Firefox

Assuming you've got firefox already installed, you need to download the
[geckodriver](https://github.com/mozilla/geckodriver/releases), unpack the tar
and add the `geckodriver` binary somewhere in your `PATH`.

```python
from selenium import webdriver

driver = webdriver.Firefox()

driver.get("https://duckduckgo.com/")
```

!!! note "If you need to get the status code of the requests use [Chrome](#chrome) instead"
    There is an issue with Firefox that doesn't support this feature.

## Chrome

We're going to use Chromium instead of Chrome. Download the
[chromedriver](https://sites.google.com/a/chromium.org/chromedriver/downloads)
of the same version as your Chromium, unpack the tar and add the `chromedriver`
binary somewhere in your `PATH`.

```python
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
opts = Options()
opts.binary_location = '/usr/bin/chromium'
driver = webdriver.Chrome(options=opts)

driver.get("https://duckduckgo.com/")
```

If you don't want to see the browser, you can run it in headless mode adding the
next line when defining the `options`:

```python
opts.add_argument("--headless")
```

## [PhantomJS](https://realpython.com/headless-selenium-testing-with-python-and-phantomjs/)

!!! warning "PhantomJS is abandoned -> Don't use it"
    The [development stopped in 2018](https://github.com/ariya/phantomjs/issues/15344)

PhantomJS is a headless Webkit, in conjunction with Selenium WebDriver, it can
be used to run tests directly from the command line. Since PhantomJS eliminates
the need for a graphical browser, tests run much faster.

[Don't install phantomjs from
the official repos](https://stackoverflow.com/questions/36770303/unable-to-load-atom-find-element)
as it's not a working release -.-. `npm install -g phantomjs` didn't work
either. I had to download the tar from the [downloads
page](https://phantomjs.org/download.html), which didn't work either. The
project is [abandoned](https://github.com/ariya/phantomjs/issues/15344), so
don't use this.

# Usage

Assuming that you've got a configured `driver`, to get the url you're in after
javascript has done it's magic use the `driver.current_url` method. To return
the HTML of the page use `driver.page_source`.

## [Get the status code of a response](https://stackoverflow.com/questions/5799228/how-to-get-status-code-by-using-selenium-py-python-code)

Surprisingly this is not as easy as with requests, there is no `status_code`
method on the driver, you need to dive into the browser log to get it. Firefox
has an [open issue](https://github.com/mozilla/geckodriver/issues/284) since
2016 that prevents you from [getting this
information](https://stackoverflow.com/questions/59026421/python-selenium-unable-to-get-browser-console-logs).
Use Chromium if you need this functionality.

```python
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities

capabilities = DesiredCapabilities.CHROME.copy()
capabilities['goog:loggingPrefs'] = {'performance': 'ALL'}

driver = webdriver.Chrome(desired_capabilities=capabilities)

driver.get("https://duckduckgo.com/")
logs = driver.get_log("performance")
status_code = get_status(driver.current_url, logs)
```

Where `get_status` is:

```python
def get_status(url: str, logs: List[Dict[str, Any]]) -> int:
    """Get the url response status code.

    Args:
        url: url to search
        logs: Browser driver logs
    Returns:
        The status code.
    """
    for log in logs:
        if log["message"]:
            data = json.loads(log["message"])
            with suppress(KeyError):
                if data["message"]["params"]["response"]["url"] == url:
                    return data["message"]["params"]["response"]["status"]
    raise ValueError(f"Error retrieving the status code for url {url}")
```

You have to use `driver.current_url` to handle well urls that redirect to other
urls.

If your url is not catched and you get a `ValueError`, use the next snippet
inside the `with suppress(KeyError)` statement.

```python
content_type = (
    "text/html"
    in data["message"]["params"]["response"]["headers"]["content-type"]
)
response_received = (
    data["message"]["method"] == "Network.responseReceived"
)
if content_type and response_received:
    __import__("pdb").set_trace()  # XXX BREAKPOINT
    pass
```
And try to see why `url != data["message"]["params"]["response"]["url"]`.
Sometimes servers redirect the user to a url without the `www.`.

## Close the browser

```python
driver.close()
```

# Issues

* [Firefox driver doesn't have access to the
    log](https://github.com/mozilla/geckodriver/issues/284): Update the section
    above and start using Firefox instead of Chrome when you need to get the
    status code of the responses.
