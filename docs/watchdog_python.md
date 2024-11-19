[watchdog](https://github.com/gorakhargosh/watchdog?tab=readme-ov-file) is a Python library and shell utilities to monitor filesystem events. 

Cons:

- The [docs](https://python-watchdog.readthedocs.io/en/stable/api.html) suck.

# Installation

```bash
pip install watchdog
```

# Usage

A simple program that uses watchdog to monitor directories specified as command-line arguments and logs events generated:

```python
import time

from watchdog.events import FileSystemEvent, FileSystemEventHandler
from watchdog.observers import Observer


class MyEventHandler(FileSystemEventHandler):
    def on_any_event(self, event: FileSystemEvent) -> None:
        print(event)


event_handler = MyEventHandler()
observer = Observer()
observer.schedule(event_handler, ".", recursive=True)
observer.start()
try:
    while True:
        time.sleep(1)
finally:
    observer.stop()
    observer.join()
```

# References
- [Source](https://github.com/gorakhargosh/watchdog?tab=readme-ov-file)
- [Docs](https://python-watchdog.readthedocs.io)


