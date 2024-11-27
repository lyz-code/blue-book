---
title: Ferdium
date: 20221104
author: Lyz
---

[Ferdium](https://ferdium.org) is a desktop application to have all your
services in one place. It's similar to Rambox, Franz or Ferdi only that it's
maintained by the community and respects your privacy.

# [Installation](https://ferdium.org/download)

Download the deb package and run

```bash
sudo dpkg -i /path/to/your/file.deb
```

# Security

In terms of security the Ferdium master password lock will only prevent an
attacker from accessing your passwords if it has very few time to do the attack.
They encrypt the password and save it in the config file along with a property
`lockingFeatureEnabled` which is set to `true` when you activate this feature.
Nevertheless if an attacker were to change this value to `false`, then they'll
be able to access your Ferdium instance.

Therefore I think that it's better to rely on locking your computer when leaving
it and encrypting your hard drive. Adding the master password will only make the
life harder for you for no substantial increase in security.

Keep in mind that Ferdium stores the cookies to automatically log in the sites
and that the information is accessible by an attacker that has access to your
device. So only add services that are not critical to you.

# References

* [Homepage](https://ferdium.org)
