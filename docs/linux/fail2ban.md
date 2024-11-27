---
title: Fail2ban
date: 20200512
author: Lyz
---

# Usage

## [Unban IP](https://serverfault.com/questions/285256/how-to-unban-an-ip-properly-with-fail2ban)

```bash
fail2ban-client set {{ jail }} unbanip {{ ip }}
```

Where `jail` can be `ssh`.
