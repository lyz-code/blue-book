---
title: Problems encountered with AWS IAM
date: 20200212
author: Lyz
---

# MFADevice entity at the same path and name already exists

It happens when a user receives an error while creating her MFA authentication.

To solve it:

List the existing MFA physical or virtual devices

```bash
aws iam list-mfa-devices
aws iam list-virtual-mfa-devices
```

Delete the conflictive one

```bash
aws iam delete-virtual-mfa-device --serial-number {{ mfa_arn }}
```
