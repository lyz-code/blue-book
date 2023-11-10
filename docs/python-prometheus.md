[prometheus-client](https://github.com/prometheus/client_python) is the official Python client for [Prometheus](prometheus.md).

# Installation

```bash
pip install prometheus-client
```

# Usage

Here is a simple script:

```python
from prometheus_client import start_http_server, Summary
import random
import time

# Create a metric to track time spent and requests made.
REQUEST_TIME = Summary('request_processing_seconds', 'Time spent processing request')

# Decorate function with metric.
@REQUEST_TIME.time()
def process_request(t):
    """A dummy function that takes some time."""
    time.sleep(t)

if __name__ == '__main__':
    # Start up the server to expose the metrics.
    start_http_server(8000)
    # Generate some requests.
    while True:
        process_request(random.random())
```

Then you can visit http://localhost:8000/ to view the metrics.

From one easy to use decorator you get:

- `request_processing_seconds_count`: Number of times this function was called.
- `request_processing_seconds_sum`: Total amount of time spent in this function.

Prometheus's rate function allows calculation of both requests per second, and latency over time from this data.

In addition if you're on Linux the process metrics expose CPU, memory and other information about the process for free.

# References

- [Source](https://github.com/prometheus/client_python)
- [Docs](https://github.com/prometheus/client_python)
