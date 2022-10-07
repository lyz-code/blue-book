---
title: NAS
date: 20221006
author: Lyz
---

[Network-attached
storage](https://en.wikipedia.org/wiki/Network-attached_storage) or NAS, is
a computer data storage server connected to a computer network providing data
access to many other devices. Basically a computer where you can attach many
hard drives.

A quick search revealed two kind of solutions:

* Plug and play.
* Do It Yourself.

The first ones are servers that some companies like Synology or Qnap sell with their own
software. They're meant for users that want to have something that works and
does not give too much work at the expense of being restricted to what the
provider gives you. The second ones are similar servers but you need to build it
from scratch with existent tools like Linux or [ZFS](zfs.md). I personally feel
a bit constrained and vendor locked by the first. For example they are not
user-repairable, so [if a part breaks after warranty, you have to replace the
whole server](https://mtlynch.io/budget-nas/). Or you may use without knowing
their proprietary storage format, that may mean that it's difficult to [recover
the data once you want to move away from their
solution](https://kb.synology.com/en-us/DSM/tutorial/How_can_I_recover_data_from_my_DiskStation_using_a_PC)
It makes sense then to trade time and dedication for freedom.

# Software

## [TrueNAS](https://www.truenas.com/)

[TrueNAS](https://www.truenas.com/) (formerly known as FreeNAS) is one of the
most popular solution operating systems for storage servers. It’s open-source,
and it’s been around for almost 20 years, so it seemed like a reliable choice.
As you can use it on any hardware, therefore removing the vendor locking, and
it's open source. They have different solutions, being the Core the most basic.
They also have Truenas Scale with which you could even build distributed
systems. A trusted friend prevented me from going in this direction as he felt
that GlusterFS over ZFS was not a good idea.

TrueNAS core looked good but I still felt a bit constrained and out of
control, so I discarded it.

## [Unraid](https://en.wikipedia.org/wiki/Unraid)

[Unraid](https://en.wikipedia.org/wiki/Unraid) is a proprietary Linux-based
operating system designed to run on home media server setups that operates as
a network-attached storage device, application server, and virtualization host.
I've heard that it can do wonders like tweaking the speed of disks based on the
need. It's not "that expensive" but still it's a proprietary so nope.

## Debian with ZFS

This solution gives you the most freedom and if you're used to use Linux like
me, is the one where you may feel most at home.

The idea is to use a normal Debian and configure it to use [ZFS](zfs.md) to
manage the storage.

# Hardware

Depending the amount of data you need to hold and how do you expect it to grow
you need to find the solution that suits your needs. After looking to many I've
decided to make my own from scratch.

## Disks

[ZFS](zfs.md) tutorials suggest buying [everything all at
once](https://www.themoviedb.org/movie/545611-everything-everywhere-all-at-once)
for the final stage of your server. Knowing the disadvantages it entails, I'll
start with a solution for 16TB that supports to easily expand in the future.
I'll start with 4 disks of 8TB, make sure you read the [ZFS section on storage
planning](zfs.md#storage-planning) to understand why. [The analysis of choosing the disks
to hold data](zfs.md#choosing-the-disks-to-hold-data) gave two IronWolf Pro and
two Exos 7E8 for a total amount of 1062$.

## Hardware conclusion

| Piece      | Number | Total price ($) |
| ---        | ---    | ---             |
| Data disks | 4      | 1062            |
| M.2 disks  | 2      |                 |
