---
title: Tenacity
date: 20211119
author: Lyz
---

[Tenacity](https://github.com/jd/tenacity) is an Apache 2.0 licensed general-purpose retrying library, written in Python, to simplify the task of adding retry behavior to just about anything.

# [Installation](https://tenacity.readthedocs.io/en/latest/#installation)

```bash
pip install tenacity
```

# Usage

Tenacity isn't api compatible with retrying but adds significant new
functionality and fixes a number of longstanding bugs.

The simplest use case is retrying a flaky function whenever an Exception occurs
until a value is returned.

```python
import random
from tenacity import retry

@retry
def do_something_unreliable():
    if random.randint(0, 10) > 1:
        raise IOError("Broken sauce, everything is hosed!!!111one")
    else:
        return "Awesome sauce!"

print(do_something_unreliable())
```

## [Basic Retry](https://tenacity.readthedocs.io/en/latest/#basic-retry)

As you saw above, the default behavior is to retry forever without waiting when an exception is raised.

```python
@retry
def never_gonna_give_you_up():
    print("Retry forever ignoring Exceptions, don't wait between retries")
    raise Exception
```


## [Stopping](https://tenacity.readthedocs.io/en/latest/#stopping)

Let’s be a little less persistent and set some boundaries, such as the number of attempts before giving up.

```python
@retry(stop=stop_after_attempt(7))
def stop_after_7_attempts():
    print("Stopping after 7 attempts")
    raise Exception
```

We don’t have all day, so let’s set a boundary for how long we should be retrying stuff.

```python
@retry(stop=stop_after_delay(10))
def stop_after_10_s():
    print("Stopping after 10 seconds")
    raise Exception
```

You can combine several stop conditions by using the `|` operator:

```python
@retry(stop=(stop_after_delay(10) | stop_after_attempt(5)))
def stop_after_10_s_or_5_retries():
    print("Stopping after 10 seconds or 5 retries")
    raise Exception
```

## [Waiting before retrying](https://tenacity.readthedocs.io/en/latest/#waiting-before-retrying)

Most things don’t like to be polled as fast as possible, so let’s just wait 2 seconds between retries.

```python
@retry(wait=wait_fixed(2))
def wait_2_s():
    print("Wait 2 second between retries")
    raise Exception
```

Some things perform best with a bit of randomness injected.

```python
@retry(wait=wait_random(min=1, max=2))
def wait_random_1_to_2_s():
    print("Randomly wait 1 to 2 seconds between retries")
    raise Exception
```

Then again, it’s hard to beat exponential backoff when retrying distributed services and other remote endpoints.

```python
@retry(wait=wait_exponential(multiplier=1, min=4, max=10))
def wait_exponential_1():
    print("Wait 2^x * 1 second between each retry starting with 4 seconds, then up to 10 seconds, then 10 seconds afterwards")
    raise Exception
```

Then again, it’s also hard to beat combining fixed waits and jitter (to help avoid thundering herds) when retrying distributed services and other remote endpoints.

```python
@retry(wait=wait_fixed(3) + wait_random(0, 2))
def wait_fixed_jitter():
    print("Wait at least 3 seconds, and add up to 2 seconds of random delay")
    raise Exception
```

When multiple processes are in contention for a shared resource, exponentially increasing jitter helps minimise collisions.

```python
@retry(wait=wait_random_exponential(multiplier=1, max=60))
def wait_exponential_jitter():
    print("Randomly wait up to 2^x * 1 seconds between each retry until the range reaches 60 seconds, then randomly up to 60 seconds afterwards")
    raise Exception
```

## [Whether to retry](https://tenacity.readthedocs.io/en/latest/#whether-to-retry)

We have a few options for dealing with retries that raise specific or general exceptions, as in the cases here.

```python
@retry(retry=retry_if_exception_type(IOError))
def might_io_error():
    print("Retry forever with no wait if an IOError occurs, raise any other errors")
    raise Exception
```

We can also use the result of the function to alter the behavior of retrying.

```python
def is_none_p(value):
    """Return True if value is None"""
    return value is None

@retry(retry=retry_if_result(is_none_p))
def might_return_none():
    print("Retry with no wait if return value is None")
```

We can also combine several conditions:

```python
def is_none_p(value):
    """Return True if value is None"""
    return value is None

@retry(retry=(retry_if_result(is_none_p) | retry_if_exception_type()))
def might_return_none():
    print("Retry forever ignoring Exceptions with no wait if return value is None")
```

Any combination of stop, wait, etc. is also supported to give you the freedom to mix and match.

It’s also possible to retry explicitly at any time by raising the `TryAgain` exception:

```python
@retry
def do_something():
    result = something_else()
    if result == 23:
       raise TryAgain
```

# References

* [Git](https://github.com/jd/tenacity)
