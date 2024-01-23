[inotify](https://pypi.org/project/inotify/) is a python library that acts as a bridge to the `inotify` linux kernel which allows you to register one or more directories for watching, and to simply block and wait for notification events. This is obviously far more efficient than polling one or more directories to determine if anything has changed.

# Installation

```bash
pip install inotify
```

# Usage

## Basic example using a loop

Code for monitoring a simple, flat path:

```python
import inotify.adapters

def _main():
    i = inotify.adapters.Inotify()

    i.add_watch('/tmp')

    with open('/tmp/test_file', 'w'):
        pass

    for event in i.event_gen(yield_nones=False):
        (_, type_names, path, filename) = event

        print("PATH=[{}] FILENAME=[{}] EVENT_TYPES={}".format(
              path, filename, type_names))

if __name__ == '__main__':
    _main()
```

Output:

```
PATH=[/tmp] FILENAME=[test_file] EVENT_TYPES=['IN_MODIFY']
PATH=[/tmp] FILENAME=[test_file] EVENT_TYPES=['IN_OPEN']
PATH=[/tmp] FILENAME=[test_file] EVENT_TYPES=['IN_CLOSE_WRITE']
```

## Basic example without a loop

```python
import inotify.adapters

def _main():
    i = inotify.adapters.Inotify()

    i.add_watch('/tmp')

    with open('/tmp/test_file', 'w'):
        pass

    events = i.event_gen(yield_nones=False, timeout_s=1)
    events = list(events)

    print(events)

if __name__ == '__main__':
    _main()
```

The wait will be done in the `list(events)` line
# References

- [Source](https://github.com/dsoprea/PyInotify)
