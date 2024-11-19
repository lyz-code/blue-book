[`aiocron`](https://github.com/gawel/aiocron?tab=readme-ov-file) is a python library to run cron jobs in python asyncronously.

# Usage

You can run it using a decorator

```python
>>> import aiocron
>>> import asyncio
>>>
>>> @aiocron.crontab('*/30 * * * *')
... async def attime():
...     print('run')
...
>>> asyncio.get_event_loop().run_forever()
```

Or by calling the function yourself

```python
>>> cron = crontab('0 * * * *', func=yourcoroutine, start=False)
```

[Here's a simple example](https://stackoverflow.com/questions/65551736/python-3-9-scheduling-periodic-calls-of-async-function-with-different-paramete) on how to run it in a script:

```python
import asyncio
from datetime import datetime
import aiocron


async def foo(param):
    print(datetime.now().time(), param)


async def main():
    cron_min = aiocron.crontab('*/1 * * * *', func=foo, args=("At every minute",), start=True)
    cron_hour = aiocron.crontab('0 */1 * * *', func=foo, args=("At minute 0 past every hour.",), start=True)
    cron_day = aiocron.crontab('0 9 */1 * *', func=foo, args=("At 09:00 on every day-of-month",), start=True)
    cron_week = aiocron.crontab('0 9 * * Mon', func=foo, args=("At 09:00 on every Monday",), start=True)

    while True:
        await asyncio.sleep(1)

asyncio.run(main())
```

You have more complex examples [in the repo](https://github.com/gawel/aiocron/tree/master/examples)
# Installation

```bash
pip install aiocron
```

# References
- [Source](https://github.com/gawel/aiocron?tab=readme-ov-file)
