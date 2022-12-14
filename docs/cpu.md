---
title: CPU
date: 20221014
author: Lyz
---

[A central processing unit or
CPU](https://en.wikipedia.org/wiki/Central_processing_unit), also known as the
brain of the server, is the electronic circuitry that executes instructions
comprising a computer program. The CPU performs basic arithmetic, logic,
controlling, and input/output (I/O) operations specified by the instructions in
the program.

The main processor factors you should consider the most while buying a server are:

* Clock speed: Is measured in gigahertz (GHz). The higher the clock speed,
    the faster the processor will calculate. The
    clock speed along with the bit width conveys us that in a single second how
    much data can flow. If a processor has a speed of 2.92 GHz and the bit width
    of 32 bits, then it means that it can process almost 3 billion units of 32
    bits of data per second.
* Cores: Every processor core handles individual processing tasks. A multi-core
    processor can process multiple computing instructions in parallel..
* Threads: Threads refer to the number of processors a chip can handle
    simultaneously. The difference between threads and cores is that cores are
    physical processing units in charge of computing processes. In contrast,
    threads are virtual components that run tasks as software would.
* Cache: Used by the processor to speed up the access to instructions and data
    between the processor and the RAM. There are three types of cache you will
    come across while looking at the specification sheet:

    * L1: Is the fastest, but cramped.
    * L2: Is roomier, but slower.
    * L3: Is spacious, but comparatively slower than above two.

# Speed

To achieve the same speed you can play with the speed of a core and the number
of cores.

Having more cores and lesser clock speed has the next advantages:

* Processors with higher cores deliver higher performance and are cost-effective.
* Applications supporting multi-threading would benefit from a higher number of cores.
* Multi-threading support for applications will continue to enhance over time.
* Easily run more applications without experiencing the performance drop.
* Great for virtualization and running multiple virtual machines.

With the disadvantages that it offers lower single threaded performance.

On the other hand, using fewer cores and higher clock speed gives the next
advantages:

* Offers better single threaded performance.
* Lower cost.

And the next disadvantages

* Due to the lower number of cores, it becomes difficult to split between
    applications.
* Not so strong as multi-threading performance.

# Providers

## [AMD](https://www.digitaltrends.com/computing/best-ryzen-cpu/)

The Ryzen family is broken down into four distinct branches:

* Ryzen 3: entry-level.
* Ryzen 5: mainstream.
* Ryzen 7: performance
* Ryzen 9:  high-end

They're all great chips in their own ways, but some certainly offer more value
than others, and for many, the most powerful chips will be complete overkill.

# Market analysis

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
bandwidth. Therefore I'd go with the [Ryzen 7 5700x](https://www.amd.com/en/products/cpu/amd-ryzen-7-5700x).

# [CPU coolers](https://www.tomshardware.com/reviews/cooling-buying-guide,6105.html)

One of the most important decisions when building your PC, especially if you
plan on overclocking, is choosing the best CPU cooler. The cooler is often
a limiting factor to your overclocking potential, especially under sustained
loads. Your cooler choice can also make a substantial difference in noise
output. So buying a cooler that can handle your best CPU’s thermal output/heat,
(be it at stock settings or when overclocked) is critical to avoiding throttling
and achieving your system’s full potential, while keeping the whole system
quiet.

CPU Coolers come in dozens of shapes and sizes, but most fall into these
categories:

* Air: made of some combination of metal heatsinks and fans, come in all shapes
    and sizes and varying thermal dissipation capacities (sometimes listed as
    TDP). High-end air coolers these days rival many all-in-one (AIO) liquid
    coolers that have become popular in the market over the past several years.
* Closed-loop
* All-in one (AIO)custom

AIO or closed-loop coolers can be (but aren’t always) quieter than air coolers,
without requiring the complications of cutting and fitting custom tubes and
maintaining coolant levels after setup. AIOs have also become increasingly
resistant to leaks over the years, and are easier to install. But they require
room for a radiator, so may require a larger case than some air coolers.

Here’s a quick comparison of some of the pros and cons of air and liquid cooling.

Liquid Cooling Pros:

* Highest cooling potential	.
* Fewer clearance issues around the socket.

Liquid Cooling Cons:

* Price is generally higher (and price to performance ratio is typically lower
    as well).
* (Slim) possibility of component-damaging leaks.

Air Cooling Pros:

* Price is generally lower (better price to performance ratio).
* No maintenance required.
* Zero chance for leaks.

Air Cooling Cons:

* Limited cooling potential.
* Increased fitment issues around the socket with memory, fans, etc).
* Can be heavy/difficult to mount.

## Quick shopping tips

* Own a recent Ryzen CPU?: You may not need to buy a cooler, even for
    overclocking. All Ryzen 300- and 2000-series processors and some older Ryzen
    models ship with coolers, and many of them can handle moderate overclocks.
    If you want the best CPU clock speed possible, you’ll still want to buy an
    aftermarket cooler, but for many Ryzen owners, that won’t be necessary.

* Check clearances before buying: Big air coolers and low-profile models can
    bump up against tall RAM and even VRM heat sinks sometimes. And tall coolers
    can butt up against your case door or window. Be sure to check the
    dimensions and advertised clearances of any cooler and your case before
    buying.

* More fans=better cooling, but more noise: The coolers that do the absolute
    best job of moving warm air away from your CPU and out of your case are also
    often the loudest. If fan noise is a problem for you, you’ll want a cooler
    that does a good job of balancing noise and cooling.

* Make sure you can turn off RGB: Many coolers these days include RGB fans and
    / or lighting. This can be a fun way to customize the look of your PC. But
    be sure there’s a way, either via a built-in controller or when plugging the
    cooler into a compatible RGB motherboard header, to turn the lights off
    without turning off the PC.

* Check that the CPU has GPU if you don't want to use an external graphic card.
    Otherwise the BIOS won't start.

## Market analysis

After a quick review I'm deciding between the [Dark Rock
4](https://www.bequiet.com/en/cpucooler/1376) and the [Enermax ETS-T50
Axe](https://www.enermaxeu.com/products/cpu-cooling/air-cooling/ets-t50-axe/).
The analysis is done after reading Tomshardware reviews
([1](https://www.tomshardware.com/reviews/be-quiet-dark-rock-4-cpu-cooler,5563-2.html),
[2](https://www.tomshardware.com/reviews/enermax-ets-t50-axe-cpu-cooler-review,5426-2.html)).

They are equal in:

* CPU core and motherboard temperatures.
* Have installation videos.

The Enermax has the advantages:

* Is much more silent (between 2 and 4 dB).
* It has better acoustic efficiency (Relative temperature against Relative
    Noise) between 15% and 29%.
* More TDP
* Much cheaper (25 EUR)
* If you have a Phillips screwdriver (normal cross screwdriver) you don't get
    another one.

All in all the Enermax ETS-T50 Axe is a better one, but after checking the
sizes, my case limit on the height of the CPU cooler is 160mm and the Enermax is
163mm... The Cooler Master Masterair ma610p has 166mm, so it's out of the
question too. The Dark Rock 4 max height is 159mm. I don't know if I should bargain.

To be in the safe side I'll go with the [Dark Rock 4](https://www.bequiet.com/en/cpucooler/1376)

## [Ryzen recommended coolers](https://www.amd.com/en/processors/ryzen-thermal-solutions)

# [CPU Thermal paste](https://www.tomshardware.com/best-picks/best-thermal-paste)

Thermal paste is designed to minimize microscopic air gaps and irregularities
between the surface of the cooler and the CPU's IHS (integrated heat spreader),
the piece of metal which is built into the top of the processor.

Good thermal paste can have a profound impact on your performance, because it
will allow your processor to transfer more of its waste heat to your cooler,
keeping your processor running cool.

Most pastes are comprised of ceramic or metallic materials suspended within
a proprietary binder which allows for easy application and spread as well as
simple cleanup.

These thermal pastes can be electrically conductive or non-conductive, depending
on their specific formula. Electrically conductive thermal pastes can carry
current between two points, meaning that if the paste squeezes out onto other
components, it can cause damage to motherboards and CPUs when you switch on the
power. A single drop out of place can lead to a dead PC, so extra care is
imperative.

Liquid metal compounds are almost always electrically conductive, so while these
compounds provide better performance than their paste counterparts, they require
more focus and attention during application. They are very hard to remove if you
get some in the wrong place, which would fry your system.

In contrast, traditional thermal paste compounds are relatively simple for every
experience level. Most, but not all, traditional pastes are electrically
non-conductive.

Most cpu coolers come with their own thermal paste, so check yours before buying
another one.

## Market analysis

| Model                 | ProlimaTech PK-3 | Thermal Grizzly Kryonaut | Cooler Master MasterGel Pro v2 |
| ---                   | ---              | ---                      | ---                            |
| Electrical conductive | No               | No                       | No                             |
| Thermal Conductivity  | 11.2 W/mk        | 12.5 W/mk                | 9 W/mk                         |
| Ease of Use           | 4.5              | 4.5                      | 4.5                            |
| Relative Performance  | 4.0              | 4.0                      | 3.5                            |
| Price per gram        | 6.22             | 9.48                     | 2.57                           |

The best choice would be the ProlimaTech but the package sold are expensive
because it has many grams.

In my case, my cooler comes with the thermal paste so I'd start with that before
spending 20$ more.

# Installation

When installing an AM4 CPU in the motherboard, rotate the CPU so that the small
arrow on one of the corners of the chip matches the arrow on the corner of the
motherboard socket.

# References

* [Tom's hardware CPU guide](https://www.tomshardware.com/reviews/cpu-buying-guide,5643.html)
* [Tom's hardware CPU cooling guide](https://www.tomshardware.com/reviews/cooling-buying-guide,6105.html)
* [How to select the best processor for your server](https://www.techmaish.com/how-to-select-the-best-processor-for-your-server/)
* [Cloudzy best server processor](https://cloudzy.com/best-server-processor/)
