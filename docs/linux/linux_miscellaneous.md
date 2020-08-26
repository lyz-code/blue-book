---
title: Linux Miscellaneous
date: 20200826
author: Lyz
---

## [List all process swap usage](https://www.cyberciti.biz/faq/linux-which-process-is-using-swap/)

```bash
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r | less
```
