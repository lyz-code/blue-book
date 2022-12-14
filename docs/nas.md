---
title: NAS
date: 20221006
author: Lyz
---

[Network-attached storage](https://en.wikipedia.org/wiki/Network-attached_storage)
or NAS, is a computer data storage server connected to a computer network
providing data access to many other devices. Basically a computer where you can
attach many hard drives.

A quick search revealed two kind of solutions:

- Plug and play.
- Do It Yourself.

The first ones are servers that some companies like Synology or Qnap sell with
their own software. They're meant for users that want to have something that
works and does not give too much work at the expense of being restricted to what
the provider gives you. The second ones are similar servers but you need to
build it from scratch with existent tools like Linux or [ZFS](zfs.md). I
personally feel a bit constrained and vendor locked by the first. For example
they are not user-repairable, so
[if a part breaks after warranty, you have to replace the whole server](https://mtlynch.io/budget-nas/).
Or you may use without knowing their proprietary storage format, that may mean
that it's difficult to
[recover the data once you want to move away from their solution](https://kb.synology.com/en-us/DSM/tutorial/How_can_I_recover_data_from_my_DiskStation_using_a_PC)
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

TrueNAS core looked good but I still felt a bit constrained and out of control,
so I discarded it.

## [Unraid](https://en.wikipedia.org/wiki/Unraid)

[Unraid](https://en.wikipedia.org/wiki/Unraid) is a proprietary Linux-based
operating system designed to run on home media server setups that operates as a
network-attached storage device, application server, and virtualization host.
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

Warning: If you pursue the beautiful and hard path of building one yourself,
don't just buy the components online, there are thousands of things that can go
wrong that will make you loose money. Instead go to your local hardware store
and try to build the server with them. Even if it's a little bit more expensive
you'll save energy and peace of mind.

## Disks

[ZFS](zfs.md) tutorials suggest buying
[everything all at once](https://www.themoviedb.org/movie/545611-everything-everywhere-all-at-once)
for the final stage of your server. Knowing the disadvantages it entails, I'll
start with a solution for 16TB that supports to easily expand in the future.
I'll start with 5 disks of 8TB, make sure you read the
[ZFS section on storage planning](zfs.md#storage-planning) to understand why.
[The analysis of choosing the disks to hold data](zfs.md#choosing-the-disks-to-hold-data)
gave two IronWolf Pro and two Exos 7E8 for a total amount of 1062$. I'll add
another IronWolf Pro as a cold spare.

## RAM

Most [ZFS](zfs.md) resources suggest using ECC RAM. The provider gives me two
options:

- Kingston Server Premier DDR4 3200MHz 16GB CL22
- Kingston Server Premier DDR4 2666MHz 16GB CL19

I'll go with two modules of 3200MHz CL22 because it has a smaller
[RAM latency](ram.md#speed).

Which was a bummer, as it turned out that my motherboard doesn't support
Registered ECC ram, but only Unregistered ECC ram.

## Motherboard

After reading these
reviews([1](https://reviewsgarage.com/best-motherboards-for-nas/),
[2](https://pcper.com/2020/03/asrock-x570m-pro4-micro-atx-motherboard-review/))
I've come to the decision to purchase the
[ASRock X570M Pro4](https://www.asrock.com/MB/AMD/X570M%20Pro4/index.asp)
because, It supports:

- 8 x SATA3 disks
- 2 x M.2 disks
- 4 x DDR4 RAM slots with speeds up to 4200+ and ECC support
- 1 x AMD AM4 Socket Ryzen™ 2000, 3000, 4000 G-Series, 5000 and 5000 G-Series
  Desktop Processors
- Supports NVMe SSD as boot disks
- Micro ATX Form Factor.

And it gives me room enough to grow:

- It supports PCI 4.0 for the M.2 which is said to be capable of perform twice
  the speed compared to previous 3rd generation. the chosen M2 are of 3rd
  generation, so if I need more speed I can change them.
- I'm only going to use 2 slots of RAM giving me 32GB, but I could grow 32 more
  easily.

## CPU

After doing some [basic research](cpu.md) I've chosen the
[Ryzen 7 5700x](https://www.amd.com/en/products/cpu/amd-ryzen-7-5700x).

## CPU cooler

After doing some [basic research](cpu.md#cpu-coolers) I've chosen the
[Dark Rock 4](https://www.bequiet.com/en/cpucooler/1376) but just because the
[Enermax ETS-T50 AXE Silent Edition](https://www.enermaxeu.com/products/cpu-cooling/air-cooling/ets-t50-axe/)
doesn't fit my case :(.

## Graphic card

As it's going to be a server and I don't need it for transcoding or gaming, I'll
start without a graphic card.

## [Server Case](https://graphicscardhub.com/case-with-lots-of-hdd/)

Computer cases are boxes that hold all your computer components together.

I'm ruling out the next ones:

- [Fractal Design R6](https://www.fractal-design.com/products/cases/define/define-r6/blackout/):
  More expensive than the Node 804 and it doesn't have hot swappable disks.
- Silverstone Technology SST-CS381: Even though it's gorgeous it's too
  expensive.
- Silverstone DS380: It only supports Mini-ITX which I don't have.

The remaining are:

| Model             | Fractal Node 804         | Silverstone CS380   |
| ----------------- | ------------------------ | ------------------- |
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

I like the
[Fractal Node 804](https://www.fractal-design.com/products/cases/node/node-804/black/)
better and it's cheaper.

## Power supply unit

Using [PCPartPicker](https://pcpartpicker.com/list/) I've seen that with 4 disks
it consumes approximately 264W, when I have the 8 disks, it will consume up to
344W, if I want to increase the ram then it will reach 373W. So in theory I can
go with a 400W power supply unit.

You need to make sure that it has enough wires to connect to all the disks.
Although that usually is not a problem as there are adapters:

- [Molex to sata](https://www.amazon.com/CB-44SATA-Individually-Sleeved-Connector-Premium/dp/B0036ORCIA/ref=sr_1_13?ie=UTF8&qid=1409942557&sr=8-13&keywords=sleeved+molex+to+sata&tag=linus21-20)
- [Sata to sata](https://www.amazon.com/dp/B0086OGN9E/ref=wl_it_dp_o_pd_nS_ttl?_encoding=UTF8&colid=2IW6VX45YF9B0&coliid=I1QUIF5VMSN2SG&psc=1&tag=linus21-20)

After an [analysis on the different power supply units](psu.md), I've decided to
go with
[Be Quiet! Straight Power 11 450W Gold](https://www.bequiet.com/en/powersupply/1251)

## Wires

Usually disks come without sata wires, so you have to buy them

## Hardware conclusion

| Piece                       | Purpose       | Number | Total price ($) |
| --------------------------- | ------------- | ------ | --------------- |
| Seagate IronWolf Pro (8TB)  | Data disk     | 3      |                 |
| Seagate Exos 7E8 (8TB)      | Data disk     | 2      | 438             |
| WD Red SN700 (1TB)          | M.2 disks     | 2      | 246             |
| Kingston Server DDR4 (16GB) | ECC RAM       | 2      | 187             |
| AsRock X570M Pro4           | Motherboard   | 1      | 225             |
| Ryzen 7 5700x               | CPU           | 1      | 274             |
| Fractal Node 804            | Case          | 1      | 137             |
| Dark Rock 4                 | CPU Cooler    | 1      |                 |
| Be Quiet! Straight Power 11 | PSU           | 1      | 99              |
| Sata wires                  | Sata          | 3      | 6.5             |
| No graphic card             | Graphic card  | 0      | 0               |
| CPU thermal paste           | thermal paste | 0      | 0               |

# References

- [mtlynch NAS building guide](https://mtlynch.io/budget-nas/)
- [NAS master building guide](https://www.nasmaster.com/everything-you-need-to-build-your-own-nas/)
