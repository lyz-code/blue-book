---
title: goaccess
date: 20220125
author: Lyz
---

[goaccess](https://goaccess.io/) is a fast terminal-based log analyzer.

Its core idea is to quickly analyze and view web server statistics in real time
without needing to use your browser (great if you want to do a quick analysis of
your access log via SSH, or if you simply love working in the terminal).

While the terminal output is the default output, it has the capability to
generate a complete, self-contained real-time HTML report (great for analytics,
monitoring and data visualization), as well as a JSON, and CSV report.

# [Installation](https://goaccess.io/get-started)

```bash
apt-get install goaccess
```

# Usage

## [Custom log format](https://goaccess.io/man#custom-log)

Sometimes the log format isn't supported, then you'll have to specify the log
format. For example:

```bash
goaccess \
    --log-format='%^,%^,%^: %h:%^ %^ [%d:%t.%^] %^ %^/%^ %^/%^/%^/%^/%^ %s %b - - ---- %^/%^/%^/%^/%^ %^/%^ {%v|} %^ %m ""%U"" "%q"' \
    --date-format '%d/%b/%Y' \
    --time-format '%H:%M:%S' \
    file.log
```

# References

* [Home](https://goaccess.io/)
* [Git](https://goaccess.io/github)
* [Docs](https://goaccess.io/man)

* [Tweaking goaccess for analytics post](https://www.thedroneely.com/posts/tweaking-goaccess-for-analytics/)
