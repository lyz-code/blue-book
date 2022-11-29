---
title: pythonping
date: 20221126
author: Lyz
---

[pythonping](https://github.com/alessandromaggio/pythonping) is simple way to
ping in Python. With it, you can send ICMP Probes to remote devices like you
would do from the terminal.

Warning: Since using `pythonping` requires root permissions or granting
`cap_net_raw` capability to the python interpreter, try to measure the latency
to a server by other means such as using `requests`.

# Installation

```bash
pip install pythonping
```

By default it requires
[root permissions](https://github.com/alessandromaggio/pythonping/issues/27) to
run because Operating systems are designed to require root for creating raw IP
packets, and sniffing the traffic on the network card. These actions are
required to do the ping.

If you don't want to run your script with root, you can use the
[capabilities framework](https://wiki.archlinux.org/index.php/Capabilities). You
can give Python the same capabilities as `/bin/ping` by doing:

```bash
sudo setcap cap_net_raw+ep $(readlink -f $(which python))
```

This will allow Python to capture raw packets, without having to give it full
root permission.

If you want to
[remove the permissions](https://unix.stackexchange.com/questions/303423/unset-setcap-additional-capabilities-on-excutable)
you can do:

```bash
sudo setcap -r $(readlink -f $(which python))
```

You can check that you've removed it with:

```bash
sudo getcap $(readlink -f $(which python))
```

If it doesn't return any output is that it doesn't have any capabilities.

# [Usage](https://github.com/alessandromaggio/pythonping#basic-usage)

If you want to see the output immediately, emulating what happens on the
terminal, use the verbose flag as below. Otherwise it won't show any information
on the `stdout`.

```python
from pythonping import ping

ping("127.0.0.1", verbose=True)
```

This will yield the following result.

```
Reply from 127.0.0.1, 9 bytes in 0.17ms
Reply from 127.0.0.1, 9 bytes in 0.14ms
Reply from 127.0.0.1, 9 bytes in 0.12ms
Reply from 127.0.0.1, 9 bytes in 0.12ms
```

Regardless of the verbose mode, the ping function will always return a
`ResponseList` object. This is a special iterable object, containing a list of
`Response` items. In each `Response`, you can find the packet received and some
meta information, like:

- `error_message`: contains a string describing the error this response
  represents. For example, an error could be “Network Unreachable” or
  “Fragmentation Required”. If you got a successful response, this property is
  None..
- `success`: is a bool indicating if the response is successful.
- `time_elapsed`: and time_elapsed_ms indicate how long it took to receive this
  response, respectively in seconds and milliseconds..

On top of that, `ResponseList` adds some intelligence you can access from its
own members. The fields are self-explanatory:

- `rtt_min` and `rtt_min_ms`.
- `rtt_max` and `rtt_max_ms`.
- `rtt_avg` and `rtt_avg_ms`.

You can also tune your ping by using some of its additional parameters:

- `size`: is an integer that allows you to specify the size of the ICMP payload
  you desire.
- `timeout`: is the number of seconds you wish to wait for a response, before
  assuming the target is unreachable.
- `payload`: allows you to use a specific payload (bytes).
- `count`: specify allows you to define how many ICMP packets to send.
- `interval`: the time to wait between pings, in seconds.
- `sweep_start` and `sweep_end`: allows you to perform a ping sweep, starting
  from payload size defined in sweep_start and growing up to size defined in
  sweep_end. Here, we repeat the payload you provided to match the desired size,
  or we generate a random one if no payload was provided. Note that if you
  defined size, these two fields will be ignored. df is a flag that, if set to
  True, will enable the Don't Fragment flag in the IP header verbose enables the
  verbose mode, printing output to a stream (see out) out is the target stream
  of verbose mode. If you enable the verbose mode and do not provide out,
  verbose output will be send to the sys.stdout stream. You may want to use a
  file here.
- `match`: is a flag that, if set to True, will enable payload matching between
  a ping request and reply (default behaviour follows that of Windows which
  counts a successful reply by a matched packet identifier only; Linux behaviour
  counts a non equivalent payload with a matched packet identifier in reply as
  fail, such as when pinging 8.8.8.8 with 1000 bytes and the reply is truncated
  to only the first 74 of request payload with a matching packet identifier).

# References

- [Git](https://github.com/alessandromaggio/pythonping)
- [ictshore article on pythonping](https://www.ictshore.com/python/python-ping-tutorial/)
