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
I'll start with 5 disks of 8TB, make sure you read the [ZFS section on storage
planning](zfs.md#storage-planning) to understand why. [The analysis of choosing the disks
to hold data](zfs.md#choosing-the-disks-to-hold-data) gave two IronWolf Pro and
two Exos 7E8 for a total amount of 1062$. I'll add another IronWolf Pro as
a cold spare.

## RAM

Most [ZFS](zfs.md) resources suggest using ECC RAM. The provider gives me two
options:

* Kingston Server Premier DDR4 3200MHz 16GB CL22
* Kingston Server Premier DDR4 2666MHz 16GB CL19

I'll go with two modules of 3200MHz CL22 because it has a smaller [RAM
latency](ram.md#speed).

## Motherboard

After reading these
reviews([1](https://reviewsgarage.com/best-motherboards-for-nas/), [2](https://pcper.com/2020/03/asrock-x570m-pro4-micro-atx-motherboard-review/)) I've
come to the decision to purchase the [ASRock X570M
Pro4](https://www.asrock.com/MB/AMD/X570M%20Pro4/index.asp) because, It
supports:

* 8 x SATA3 disks
* 2 x M.2 disks
* 4 x DDR4 RAM slots with speeds up to 4200+ and ECC support
* 1 x AMD AM4 Socket Ryzen™ 2000, 3000, 4000 G-Series, 5000 and 5000 G-Series
    Desktop Processors
* Supports NVMe SSD as boot disks
* Micro ATX Form Factor.

And it gives me room enough to grow:

* It supports PCI 4.0 for the M.2 which is said to be capable of perform twice
    the speed compared to previous 3rd generation. the chosen M2 are of 3rd
    generation, so if I need more speed I can change them.
* I'm only going to use 2 slots of RAM giving me 32GB, but I could grow 32 more
    easily.

## CPU

After doing some [basic research](cpu.md) I'm between:

| Property        | Ryzen 7 5800x | Ryzen 5 5600x  | Ryzen 7 5700x | Ryzen 5 5600G  |
| ---             | ---           | ---            | ---           | ---            |
| Cores           | 8             | 6              | 8             | 6              |
| Threads         | 16            | 12             | 16            | 12             |
| Clock           | 3.8           | 3.7            | 3.4           | 3.9            |
| Socket          | AM4           | AM4            | AM4           | AM4            |
| PCI             | 4.0           | 4.0            | 4.0           | 3.0            |
| Thermal         | Not included  | Wraith Stealth | Not included  | Wraith Stealth |
| Default TDP     | 105W          | 65W            | 65W           | 65W            |
| System Mem spec | >= 3200 MHz   | >= 3200 MHz    | >= 3200 MHz   | >= 3200 MHz    |
| Mem type        | DDR4          | DDR4           | DDR4          | DDR4           |
| Price           | 315           | 232            | 279           | 179            |

The data was extracted from [AMD's official
page](https://www.amd.com/en/products/specifications/compare/processors/10466,11826,10471,11176).

They all support the chosen RAM and the motherboard.

I'm ruling out Ryzen 7 5800x because it's too expensive both on monetary and
power consumption terms. Also ruling out Ryzen 5 5600G because it has
comparatively bad properties.

Between Ryzen 5 5600x and Ryzen 7 5700x, after checking these comparisons
([1](https://nanoreview.net/en/cpu-compare/amd-ryzen-7-5700x-vs-amd-ryzen-5-5600x),
[2](https://www.amd.com/en/products/specifications/compare/processors/10466,11826,10471,11176))
it looks like:

* Single core performance is similar.
* 7 wins when all cores are involved.
* 7 is more power efficient.
* 7 is better rated.
* 7 is newer (1.5 years).
* 7 has around 3.52 GB/s (7%) higher theoretical RAM memory bandwidth
* They have the same cache
* 7 has 5 degrees less of max temperature
* They both support ECC
* 5 has a greater market share
* 5 is 47$ cheaper

I think that for 47$ it's work the increase on cores and theoretical RAM memory
bandwidth.

## CPU cooler

It looks that the [Ryzen CPUs don't require a cooler to work
well](cpu.md#quick-shopping-tips). Usually it adds another 250W to the
consumption. I don't plan to overclock it and I've heard that ZFS doesn't use
too much CPU, so I'll start without it and monitor the temperature.

If I were to take one, I'd go with air cooling with something like the [Dark
Rock 4](https://www.bequiet.com/en/cpucooler/1376) but I've also read that
Noctua are a good provider.

## Graphic card

As it's going to be a server and I don't need it for transcoding or gaming, I'll
start without a graphic card.

## [Server Case](https://graphicscardhub.com/case-with-lots-of-hdd/)

Computer cases are boxes that hold all your computer components together.

I'm ruling out the next ones:

* [Fractal Design
    R6](https://www.fractal-design.com/products/cases/define/define-r6/blackout/):
    More expensive than the Node 804 and it doesn't have hot swappable disks.
* Silverstone Technology SST-CS381: Even though it's gorgeous it's too
    expensive.
* Silverstone DS380: It only supports Mini-ITX which I don't have.

The remaining are:

| Model             | Fractal Node 804         | Silverstone CS380   |
| ---               | ---                      | ---                 |
| Form factor       | Micro - ATX              | Mid tower           |
| Motherboard       | Micro ATX                | Micro ATX           |
| Drive bays        | 8 x 3.5", 2 x 2.5"       | 8 x 3.5", 2 x 5.25" |
| Hot-swap          | No                       | yes                 |
| Expansion Slots   | 5                        | 7                   |
| CPU cooler height | 160mm                    | 146 mm              |
| PSU compatibility | ATX                      | ATX                 |
| Fans              | Front: 4, Top: 4, Rear 3 | Side: 2, Rear: 1    |
| Price             | 115                      | 184                 |
| Size              | 34 x 31 x 39 cm          | 35 x 28 x 21 cm     |

I like the Fractal Node 804 better and it's cheaper.

## Power supply unit

Using [PCPartPicker](https://pcpartpicker.com/list/) I've seen that with 4 disks
it consumes approximately 254W, when I have the 8 disks, it will consume up to
334W, so I can go with a 400W power supply unit.

## Wires

Usually disks come without sata wires, so you have to buy them

## Hardware conclusion

| Piece                       | Purpose      | Number | Total price ($) |
| ---                         | ---          | ---    | ---             |
| Seagate IronWolf Pro (8TB)  | Data disk    | 3      | 762             |
| Seagate Exos 7E8 (8TB)      | Data disk    | 2      | 554             |
| WD Red SN700 (1TB)          | M.2 disks    | 2      | 254             |
| Kingston Server DDR4 (16GB) | ECC RAM      | 2      | 206             |
| AsRock X570M Pro4           | Motherboard  | 1      | 271             |
| Ryzen 7 5700x               | CPU          | 1      | 280             |
| Fractal Node 804            | Case         | 1      | 116             |
| No cooler                   | CPU Cooler   | 0      | 0               |
| No graphic card             | Graphic card | 0      | 0               |

# References

* [mtlynch NAS building guide](https://mtlynch.io/budget-nas/)
* [NAS master building guide](https://www.nasmaster.com/everything-you-need-to-build-your-own-nas/)
