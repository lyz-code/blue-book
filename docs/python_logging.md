--
title: Python Logging
date: 20210423
author: Lyz
---

Logging information in your Python programs makes it possible to debug problems
when running.

For command line application that the user is going to run directly, the
`logging` module might be enough. For command line tools or APIs that are going
to be run by a server, it might fall short. `logging` will write exceptions and
breadcrumbs to a file, and unless you look at it directly most errors will pass
unnoticed.

To actively monitor and react to code exceptions use an application monitoring
platform like [sentry](https://sentry.io/welcome/). They gather de data on your
application and aggregate the errors in a user friendly way, such as:

* Showing the context of the error in a web interface.
* Gather both front and backend issues in one place.
* Show the trail of events that led to the exceptions with breadcrumbs.
* Show the probable commit that introduced the bug.
* Link problems with issue tracker issues.
* See the impact of each bug with the number of occurrences and users that are
    experiencing it.
* Visualize all the data in dashboards.
* Get notifications on the issues raised.

Check the [demo](https://try.sentry-demo.com/) to see its features.

You can [self-host sentry](https://develop.sentry.dev/self-hosted/), but it uses
a [docker-compose](https://github.com/getsentry/onpremise/blob/21.4.1/docker-compose.yml)
that depends on 12 services, including postgres, redis and kafka with a minimum
requirements of 4 cores and 8 GB of RAM.

So I've looked for a simple solution, and arrived to
[GlitchTip](https://glitchtip.com/), a similar solution that even uses the
sentry SDK, but has a smaller system footprint, and it's [open sourced, while
sentry is not anymore](https://blog.sentry.io/2019/11/06/relicensing-sentry).
Check it's [documentation](https://glitchtip.com/documentation) and [source
code](https://gitlab.com/glitchtip).

# Using the logging module

Usually you create the `log` variable in each module with the next snippet.

```python
import logging

log = logging.getLogger(__name__)
```

## Configure the logging of a program to look nice

Note: if you're going to use the [`rich`](rich.md) library check [this snippet instead](rich.md#configure-the-logging-handler).

```python
import sys

def load_logger(verbose: bool = False) -> None:  # pragma no cover
    """Configure the Logging logger.

    Args:
        verbose: Set the logging level to Debug.
    """
    logging.addLevelName(logging.INFO, "\033[36mINFO\033[0m   ")
    logging.addLevelName(logging.ERROR, "\033[31mERROR\033[0m  ")
    logging.addLevelName(logging.DEBUG, "\033[32mDEBUG\033[0m  ")
    logging.addLevelName(logging.WARNING, "\033[33mWARNING\033[0m")


    if verbose:
        logging.basicConfig(
            format="%(asctime)s %(levelname)s %(name)s: %(message)s",
            stream=sys.stderr,
            level=logging.DEBUG,
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        logging.getLogger("sh").setLevel(logging.WARN)
    else:
        logging.basicConfig(
            stream=sys.stderr, level=logging.INFO, format="%(levelname)s %(message)s"
        )
```

## Configure the logging module to use logfmt

To configure the Python `logging` module to use `logfmt` for logging output, you can use a custom logging formatter. The `logfmt` format is a structured logging format that uses key-value pairs, making it easier to parse logs. Here’s how you can set up logging with `logfmt` format:

```python
import logging

class LogfmtFormatter(logging.Formatter):
    """Custom formatter to output logs in logfmt style."""

    def format(self, record: logging.LogRecord) -> str:
        log_message = (
            f"level={record.levelname.lower()} "
            f"logger={record.name} "
            f'msg="{record.getMessage()}"'
        )
        return log_message

def setup_logging() -> None:
    """Configure logging to use logfmt format."""
    # Create a console handler
    console_handler = logging.StreamHandler()
    
    # Create a LogfmtFormatter instance
    logfmt_formatter = LogfmtFormatter()

    # Set the formatter for the handler
    console_handler.setFormatter(logfmt_formatter)

    # Get the root logger and set the level
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    logger.addHandler(console_handler)

if __name__ == "__main__":
    setup_logging()
    
    # Example usage
    logging.info("This is an info message")
    logging.warning("This is a warning message")
    logging.error("This is an error message")
```

## Configure the logging module to log directly to systemd's journal

To use `systemd.journal` in Python, you need to install the `systemd-python` package. This package provides bindings for systemd functionality.

Install it using pip:

```bash
pip install systemd-python
```
Below is an example Python script that configures logging to send messages to the systemd journal:

```python
import logging
from systemd.journal import JournalHandler

# Set up logging to use the systemd journal
logger = logging.getLogger('my_app')
logger.setLevel(logging.DEBUG)  # Set the logging level

# Create a handler for the systemd journal
journal_handler = JournalHandler()
journal_handler.setLevel(logging.DEBUG)  # Adjust logging level if needed
# Add extra information to ensure the correct identifier is used in journalctl
journal_handler.addFilter(
    lambda record: setattr(record, "SYSLOG_IDENTIFIER", "mbsync_syncer") or True
)

# Optional: Add a formatter to include additional info in the log entries
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
journal_handler.setFormatter(formatter)

# Add the handler to the logger
logger.addHandler(journal_handler)

# Example usage
logger.info("This is an info message.")
logger.error("This is an error message.")
logger.debug("Debugging information.")
```

When you run the script, the log messages will be sent to the systemd journal. You can view them using the `journalctl` command:

```bash
sudo journalctl -f
```

This command will show the latest log entries in real time. You can filter by your application name using:

```bash
sudo journalctl -f -t my_app
```

Replace `my_app` with the logger name you used (e.g., `'my_app'`).

### Additional Tips:
- **Tagging**: You can add a custom identifier for your logs by setting `logging.getLogger('your_tag')`. This will allow you to filter logs using `journalctl -t your_tag`.
- **Log Levels**: You can control the verbosity of the logs by setting different levels (e.g., `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`).

### Example Output in the Systemd Journal:

You should see entries similar to the following in the systemd journal:

```
Nov 15 12:45:30 my_hostname my_app[12345]: 2024-11-15 12:45:30,123 - my_app - INFO - This is an info message.
Nov 15 12:45:30 my_hostname my_app[12345]: 2024-11-15 12:45:30,124 - my_app - ERROR - This is an error message.
Nov 15 12:45:30 my_hostname my_app[12345]: 2024-11-15 12:45:30,125 - my_app - DEBUG - Debugging information.
```

This approach ensures that your logs are accessible through standard systemd tools and are consistent with other system logs. Let me know if you have any additional requirements or questions!
```python
```
