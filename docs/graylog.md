---
title: Graylog
date: 20211123
author: Lyz
---

[Graylog](https://www.graylog.org/) is a log management tool

# Tips

## [Send a test message to check an input](https://serverfault.com/questions/591758/send-echo-message-to-graylog2-via-gelf-tcp-12201-port)

The next line will send a test message to the TCP 12201 port of the graylog
server, if you use UDP, add the `-u` flag to the `nc` command.

```bash
echo -e '{"version": "1.1","host":"example.org","short_message":"Short message","full_message":"Backtrace here\n\nmore stuff","level":1,"_user_id":9001,"_some_info":"foo","_some_env_var":"bar"}\0' | nc -w 1 my.graylog.server 12201
```

To see if it arrives, you can check the `Input` you're trying to access, or at
a lower level, you can `ngrep` with:

```bash
ngrep -d any port 12201
```

Or if you're using UDP:


```bash
ngrep -d any '' udp port 12201
```

# References

* [Homepage](https://www.graylog.org/)
