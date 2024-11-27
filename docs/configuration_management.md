---
title: Configuration management
date: 20221231
author: Lyz
---

Configuring your devices is boring, disgusting and complex. Specially when your
device dies and you need to reinstall. You usually don't have the time or energy
to deal with it, you just want it to work.

To have a system that allows you to recover from a disaster it's expensive in
both time and knowledge, and many people have different solutions.

This article shows the latest step of how I'm doing it.

# Linux devices

## Operating System installation

I don't use PEX or anything, just burn the ISO in an USB and manually install
it.

## Main skeleton

I use the same Ansible playbook to configure all my devices. Using a monolith
playbook is usually not a good idea in enterprise environments, you'd better use
a [`cruft`](cruft.md) template and a playbook for each server. At your home
you'd probably have a limited number of devices and maintaining many playbooks
and a cruft template is not worth your time. Ansible is flexible enough to let
you manage the differences of the devices while letting you reuse common parts.

The playbook configures the skeleton of the device namely:

- Configure the disks [with OpenZFS](zfs.md).
- Install the packages.
- Configure the firewall.

In that playbook I use roles in these ways:

- The ones that can be cloned without configuration from a clean environment are
  defined in the `requirements.yml` file and installed with `ansible-galaxy`.
- The ones that can't be cloned but are developed by other people are cloned
  using git submodules in the `roles` directory.
- The ones I make live in the `roles` directory of the playbook and don't have
  tests. Again, managing your own roles this way is a *bad idea* in enterprise
  environments, you should use `cruft`, a separate repository for each role,
  test them with `molecule` and version it in the `requirements.yml` of the
  playbook pinning it to a specific version. This of course is an overkill for a
  home deployment. You'd spend much more time writing the tests and debugging
  issues than using the `roles` directory directly.

## Home configuration
