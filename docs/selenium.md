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
[chromedriver](https://sites.google.com/chromium.org/driver/downloads)
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

## Open a URL

```python
driver.get("https://duckduckgo.com/")
```

## Get page source

```python
driver.page_source
```

## Get current url

```python
driver.current_url
```


## [Click on element](https://towardsdatascience.com/using-python-and-selenium-to-automate-filling-forms-and-mouse-clicks-f87c74ed5c0f)

Once you've opened the page you want to interact with `driver.get()`, you need
to get the Xpath of the element to click on. You can do that by using your
browser inspector, to select the element, and once on the code if you right
click there is a "Copy XPath"

Once that is done you should have something like this when you paste it down.

```python
//*[@id=”react-root”]/section/main/article/div[2]/div[2]/p/a
```

Similarly it is the same process for the input fields for username, password,
and login button.

We can go ahead and do that on the current page. We can store these xpaths as
strings in our code to make it readable.

We should have three xpaths from this page and one from the initial login.

```python
first_login = '//*[@id=”react-root”]/section/main/article/div[2]/div[2]/p/a'
username_input = '//*[@id="react-root"]/section/main/div/article/div/div[1]/div/form/div[2]/div/label/input'
password_input = '//*[@id="react-root"]/section/main/div/article/div/div[1]/div/form/div[3]/div/label/input'
login_submit = '//*[@id="react-root"]/section/main/div/article/div/div[1]/div/form/div[4]/button/div'
```

Now that we have the xpaths defined we can now tell Selenium webdriver to click
and send some keys over for the input fields.

```python
from selenium.webdriver.common.by import By

driver.find_element(By.XPATH, first_login).click()
driver.find_element(By.XPATH, username_input).send_keys("username")
driver.find_element(By.XPATH, password_input).send_keys("password")
driver.find_element(By.XPATH, login_submit).click()
```

!!! note

    Many pages suggest to use methods like `find_element_by_name`,
    `find_element_by_xpath` or `find_element_by_id`. These [are deprecated now](https://stackoverflow.com/questions/74023553/attributeerror-webdriver-object-has-no-attribute-find-elements-by-xpath-in).
    You should use `find_element(By.` instead. So, instead of:

    ```python
    driver.find_element_by_xpath("your_xpath")
    ```

    It should be now:

    ```python
    driver.find_element(By.XPATH, "your_xpath")
    ```

    Where `By` [is
    imported](https://stackoverflow.com/questions/44629970/python-selenium-webdriver-name-by-not-defined)
    with `from selenium.webdriver.common.by import By`.

## Close the browser

```python
driver.close()
```

## Change browser configuration

You can pass `options` to the initialization of the chromedriver to tweak how
does the browser behave. To get a list of the actual `prefs` you can go to
`chrome://prefs-internals`, there you can get the code you need to tweak.

### Disable loading of images

```python
options = ChromeOptions()
options.add_experimental_option(
    "prefs",
    {
        "profile.default_content_setting_values.images": 2,
        "profile.default_content_setting_values.cookies": 2,
    },
)
```

### Disable site cookies

```python
options = ChromeOptions()
options.add_experimental_option(
    "prefs",
    {
        "profile.default_content_setting_values.cookies": 2,
    },
)
```



## Bypass Selenium detectors

Sometimes web servers react differently if they notice that you're using
selenium. Browsers can be detected through different ways and some commonly used
mechanisms are as follows:

* Implementing captcha / recaptcha to detect the automatic bots.
* Non-human behaviour (browsing too fast, not scrolling to the visible elements,
    ...)
* Using an IP that's flagged as suspicious (VPN, VPS, Tor...)
* Detecting the term HeadlessChrome within headless Chrome UserAgent
* Using Bot Management service from [Distil
    Networks](http://www.distilnetworks.com/),
    [Akamai](https://www.akamai.com/us/en/products/security/bot-manager.jsp),
    [Datadome](https://datadome.co/product/).

They do it through different mechanisms:

* [Use undetected-chromedriver](#use-undetected-chromedriver)
* [Use Selenium stealth](#use-selenium-stealth)
* [Rotate the user agent](#rotate-the-user-agent)
* [Changing browser properties](#changing-browser-properties)
* [Predefined Javascript variables](#predefined-javascript-variables)
* [Don't use selenium](#dont-use-selenium)

If you've already been detected, you might get blocked for a plethora of other
reasons even after using these methods. So you may have to try accessing the site
that was detecting you using a VPN, different user-agent, etc.

### [Use undetected-chromedriver](https://github.com/ultrafunkamsterdam/undetected-chromedriver)

`undetected-chromedriver` is a python library that uses an optimized Selenium
Chromedriver patch which does not trigger anti-bot services like Distill Network
/ Imperva / DataDome / Botprotect.io Automatically downloads the driver binary
and patches it.

#### Installation

```bash
pip install undetected-chromedriver
```

#### Usage

```python
import undetected_chromedriver.v2 as uc
driver = uc.Chrome()
driver.get('https://nowsecure.nl')  # my own test test site with max anti-bot protection
```

If you want to specify the path to the browser use
`uc.Chrome(browser_executable_path="/path/to/your/file")`.

### [Use Selenium Stealth](https://github.com/diprajpatra/selenium-stealth)

`selenium-stealth` is a python package to prevent detection (by doing most of
the steps of this guide) by making selenium more stealthy.

!!! note

    It's less maintained than `undetected-chromedriver` so I'd use that other instead.
    I leave the section in case it's helpful if the other fails for you.

#### Installation

```bash
pip install selenium-stealth
```

#### Usage

```python
from selenium import webdriver
from selenium_stealth import stealth
import time

options = webdriver.ChromeOptions()
options.add_argument("start-maximized")

# options.add_argument("--headless")

options.add_experimental_option("excludeSwitches", ["enable-automation"])
options.add_experimental_option('useAutomationExtension', False)
driver = webdriver.Chrome(options=options, executable_path=r"C:\Users\DIPRAJ\Programming\adclick_bot\chromedriver.exe")

stealth(driver,
        languages=["en-US", "en"],
        vendor="Google Inc.",
        platform="Win32",
        webgl_vendor="Intel Inc.",
        renderer="Intel Iris OpenGL Engine",
        fix_hairline=True,
        )

url = "https://bot.sannysoft.com/"
driver.get(url)
time.sleep(5)
driver.quit()
```

You can test it with [antibot](https://bot.sannysoft.com/).


### [Rotate the user agent](https://stackoverflow.com/questions/33225947/can-a-website-detect-when-you-are-using-selenium-with-chromedriver)

Rotating the UserAgent in every execution of your Test Suite using
[`fake_useragent`](https://pypi.python.org/pypi/fake-useragent) module as follows:

```python
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from fake_useragent import UserAgent

options = Options()
ua = UserAgent()
userAgent = ua.random
print(userAgent)
options.add_argument(f'user-agent={userAgent}')
driver = webdriver.Chrome(chrome_options=options)
driver.get("https://www.google.co.in")
driver.quit()
```

You can also rotate it with `execute_cdp_cmd`:

```python
from selenium import webdriver

driver = webdriver.Chrome(executable_path=r'C:\WebDrivers\chromedriver.exe')
print(driver.execute_script("return navigator.userAgent;"))
# Setting user agent as Chrome/83.0.4103.97
driver.execute_cdp_cmd('Network.setUserAgentOverride', {"userAgent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36'})
print(driver.execute_script("return navigator.userAgent;"))
```

### [Changing browser properties](https://stackoverflow.com/questions/33225947/can-a-website-detect-when-you-are-using-selenium-with-chromedriver)

* Changing the property value of navigator for webdriver to undefined as follows:

    ```python
    driver.execute_cdp_cmd("Page.addScriptToEvaluateOnNewDocument", {
      "source": """
        Object.defineProperty(navigator, 'webdriver', {
          get: () => undefined
        })
      """
    })
    ```

    You can find a relevant detailed discussion in [Selenium webdriver: Modifying
    navigator.webdriver flag to prevent selenium detection](https://stackoverflow.com/questions/53039551/selenium-webdriver-modifying-navigator-webdriver-flag-to-prevent-selenium-detec/53040904#53040904)

* Changing the values of navigator.plugins, navigator.languages, WebGL, hairline feature, missing image, etc.
    You can find a relevant detailed discussion in [Is there a version of
    selenium webdriver that is not detectable?](https://stackoverflow.com/questions/56528631/is-there-a-version-of-selenium-webdriver-that-is-not-detectable/56529616#56529616)

* Changing the conventional [Viewport](https://www.w3schools.com/css/css_rwd_viewport.asp)

    You can find a relevant detailed discussion in [How to bypass Google captcha
    with Selenium and python?](https://stackoverflow.com/questions/58872451/how-to-bypass-google-captcha-with-selenium-and-python/58876531#58876531)


### [Predefined Javascript variables](https://stackoverflow.com/questions/33225947/can-a-website-detect-when-you-are-using-selenium-with-chromedriver)

One way of detecting Selenium is by checking for predefined JavaScript variables
which appear when running with Selenium. The bot detection scripts usually look
anything containing word `selenium`, `webdriver` in any of the variables (on
window object), and also document variables called `$cdc_` and `$wdc_`. Of course,
all of this depends on which browser you are on. All the different browsers
expose different things.

In Chrome, what people had to do was to ensure that `$cdc_` didn't
exist as a document variable.

You don't need to go compile the `chromedriver` yourself, if you open the file
with `vim` and execute `:%s/cdc_/dog_/g` where `dog` can be any three
characters that will work. With perl you can achieve the same result with:

```bash
perl -pi -e 's/cdc_/dog_/g' /path/to/chromedriver
```

### Don't use selenium

Even with `undetected-chromedriver`, sometimes servers [are able to detect that
you're using
selenium](https://github.com/ultrafunkamsterdam/undetected-chromedriver/issues/816).

A uglier but maybe efective way to go is not using selenium and do
a combination of working directly with the chrome devtools protocol with
[`pycdp`](https://py-cdp.readthedocs.io/en/latest/overview.html) (using [this
maintained fork](https://github.com/HMaker/python-cdp)) and doing the
clicks with [`pyautogui`](https://pyautogui.readthedocs.io/en/latest/). See an
[example on this
answer](https://github.com/ultrafunkamsterdam/undetected-chromedriver/issues/816).

Keep in mind though that these tools don't look to be actively maintained, and
that the approach is quite brittle to site changes. Is there really not other
way to achieve what you want?

## [Set timeout of a response](https://stackoverflow.com/questions/17533024/how-to-set-selenium-python-webdriver-default-timeout)

For Firefox and Chromedriver:

```python
driver.set_page_load_timeout(30)
```

The rest:

```python
driver.implicitly_wait(30)
```

This will throw a `TimeoutException` whenever the page load takes more than 30
seconds.

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

# Troubleshooting

## Chromedriver hangs up unexpectedly

[Some say that adding the `DBUS_SESSION_BUS_ADDRESS` environmental
variable](https://bugs.chromium.org/p/chromedriver/issues/detail?id=1699) fixes
it:

```python
os.environ["DBUS_SESSION_BUS_ADDRESS"] = "/dev/null"
```

But it still hangs for me. Right now the only solution I see is to assume it's
going to hang and add functionality in your program to resume the work instead
of starting from scratch. Ugly I know...

# Issues

* [Firefox driver doesn't have access to the
    log](https://github.com/mozilla/geckodriver/issues/284): Update the section
    above and start using Firefox instead of Chrome when you need to get the
    status code of the responses.
