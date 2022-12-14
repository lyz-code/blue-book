---
title: GrapheneOS
date: 20221111
author: Lyz
---

[GrapheneOS](https://grapheneos.org/) is a private and secure mobile operating
system with Android app compatibility. Developed as a non-profit open source
project.

GrapheneOS is a private and secure mobile operating system with great
functionality and usability. It starts from the strong baseline of the Android
Open Source Project (AOSP) and takes great care to avoid increasing attack
surface or hurting the strong security model. GrapheneOS makes substantial
improvements to both privacy and security through many carefully designed
features built to function against real adversaries. The project cares a lot
about usability and app compatibility so those are taken into account for all of
our features.

GrapheneOS is also hard at work on filling in gaps from not bundling Google apps
and services into the OS. We aren't against users using Google services but it
doesn't belong integrated into the OS in an invasive way. GrapheneOS won't take
the shortcut of simply bundling a very incomplete and poorly secured third party
reimplementation of Google services into the OS. That wouldn't ever be something
users could rely upon. It will also always be chasing a moving target while
offering poorer security than the real thing if the focus is on simply getting
things working without great care for doing it robustly and securely.

# [Features](https://grapheneos.org/features)

These are a subset some of the features of GrapheneOS beyond what's provided by
version 13 of the Android Open Source Project. It only covers our improvements
to AOSP and not baseline features. This section doesn't list features like the
standard app sandbox, verified boot, exploit mitigations (ASLR, SSP, Shadow Call
Stack, Control Flow Integrity, etc.), permission system (foreground-only and
one-time permission grants, scoped file access control, etc.) and so on but
rather only our improvements to modern Android.

## [Defending against exploitation of unknown vulnerabilities](https://grapheneos.org/features#exploit-protection)

The first line of defense is attack surface reduction. Removing unnecessary code
or exposed attack surface eliminates many vulnerabilities completely. GrapheneOS
avoids removing any useful functionality for end users, but we can still disable
lots of functionality by default and require that users opt-in to using it to
eliminate it for most of them. An example we landed upstream in Android is
disallowing using the kernel's profiling support by default, since it was and
still is a major source of Linux kernel vulnerabilities.

The next line of defense is preventing an attacker from exploiting a
vulnerability, either by making it impossible, unreliable or at least
meaningfully harder to develop. The vast majority of vulnerabilities are well
understood classes of bugs and exploitation can be prevented by avoiding the
bugs via languages/tooling or preventing exploitation with strong exploit
mitigations. In many cases, vulnerability classes can be completely wiped out
while in many others they can at least be made meaningfully harder to exploit.
Android does a lot of work in this area and GrapheneOS has helped to advance
this in Android and the Linux kernel.

The final line of defense is containment through sandboxing at various levels:
fine-grained sandboxes around a specific context like per site browser
renderers, sandboxes around a specific component like Android's media codec
sandbox and app / workspace sandboxes like the Android app sandbox used to
sandbox each app which is also the basis for user/work profiles. GrapheneOS
improves all of these sandboxes through fortifying the kernel and other base OS
components along with improving the sandboxing policies.

Preventing an attacker from persisting their control of a component or the OS /
firmware through verified boot and avoiding trust in persistent state also helps
to mitigate the damage after a compromise has occurred.

### [Attack surface reduction](https://grapheneos.org/features#attack-surface-reduction)

- Greatly reduced remote, local and proximity-based attack surface by stripping
  out unnecessary code, making more features optional and disabling optional
  features by default (NFC, Bluetooth, etc.), when the screen is locked
  (connecting new USB peripherals, camera access) and optionally after a timeout
  (Bluetooth, Wi-Fi)
- Option to disable native debugging (ptrace) to reduce local attack surface
  (still enabled by default for compatibility)

## Downsides

It looks that the community behind GrapheneOS is not the kindest one, they are
sometimes harsh and when they are questioned they enter a defensive position.
This can be seen in the discussions regarding whether or not to use the screen
pattern lock
([1](https://discuss.grapheneos.org/d/28-feature-request-numerous-points-screen-lock-pattern/7),
[2](https://github.com/GrapheneOS/os-issue-tracker/issues/570)).

# [Recommended devices](https://grapheneos.org/faq#recommended-devices)

They strongly recommend only purchasing one of the following devices for
GrapheneOS due to better security and a minimum 5 year guarantee from launch for
full security updates and other improvements:

- Pixel 7 Pro
- Pixel 7
- Pixel 6a
- Pixel 6 Pro
- Pixel 6

!!! note "Check [the source](https://grapheneos.org/faq#recommended-devices) as
this section is probably outdated"

Newer devices have more of their 5 year minimum guarantee remaining but the
actual support time may be longer than the minimum guarantee.

The Pixel 7 and Pixel 7 Pro are all around improvements over the Pixel 6 and
Pixel 6 Pro with a significantly better GPU and cellular radio along with an
incremental CPU upgrade. The 7th generation Pixels are far more similar to the
previous generation than any prior Pixels.

The Pixel 6 and Pixel 6 Pro are flagship phones with much nicer hardware than
previous generation devices (cameras, CPU, GPU, display, battery).

The cheaper Pixel 6 has extremely competitive pricing for the flagship level
hardware especially with the guaranteed long term support. Pixel 6 Pro has 50%
more memory (12GB instead of 8GB), a higher end screen, a 3rd rear camera with
4x optical zoom and a higher end front camera. Both devices have the same SoC
(CPU, GPU, etc.) and the same main + ultrawide rear cameras. The Pixel 6 is
quite large and the Pixel 6 Pro is larger.

The Pixel 6a is a budget device with the same 5 years of guaranteed full
security support from launch as the flagship 6th generation Pixels. It also has
the same flagship SoC as the higher end devices, the same main rear and front
cameras as the Pixel 5 and a rear wide angle lens matching the flagship 6th
generation Pixels. Compared to the 5th generation Pixels, it has 5 years of full
security support remaining instead of less than 2 years and the CPU is 2x
faster. We strongly recommend buying the Pixel 6a rather than trying to get a
deal with older generation devices. You'll be able to use the Pixel 6a much
longer before it needs to be replaced due to lack of support.

It's funny though that in the search for security and privacy you end up buying
a Google device. If you also reached this thought,
[you're not alone](https://www.reddit.com/r/PrivacyGuides/comments/yocnk7/if_grapheneos_is_the_best_os_for_mobile_how_can/).
Summing up, the Pixel's are in fact the devices that are more secure and that
potentially respect your privacy.

# [Installation](https://grapheneos.org/install/web)

I was not able to follow the [web](https://grapheneos.org/install/web)
instructions so I had to follow the [cli](https://grapheneos.org/install/cli)
ones.

Whenever I run a `fastboot` command it got stuck in `< waiting for devices >`,
so I added the next rules on the `udev` configuration at
`/etc/udev/rules.d/51-android.rules`

```
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", ATTR{idProduct}=="4ee7", MODE="0600", OWNER="myuser"
```

The `idProduct` and `idVendor` were deduced from `lsusb`. Then after a restart
everything worked fine.

## Setup Auditor

Auditor provides attestation for GrapheneOS phones and the stock operating systems on a number of devices. It uses hardware security features to make sure that the firmware and operating system have not been downgraded or tampered with.

Attestation can be done locally by pairing with another Android 8+ device or remotely using the remote attestation service. To make sure that your hardware and operating system is genuine, perform local attestation immediately after the device has been setup and prior to any internet connection.

# References

- [Home](https://grapheneos.org/)

* [Articles](https://grapheneos.org/articles/)
* [Features](https://grapheneos.org/features)
