---
title: AWS Snippets
date: 20220221
author: Lyz
---

# [Find if external IP belongs to you](https://aws.amazon.com/premiumsupport/knowledge-center/vpc-find-owner-unknown-ip-addresses/)

You can list the network interfaces that match the IP you're searching for

```bash
aws ec2 describe-network-interfaces --filters Name=association.public-ip,Values="{{ your_ip_address}}"
```
