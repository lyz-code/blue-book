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

## [Ryzen recommended coolers](https://www.amd.com/en/processors/ryzen-thermal-solutions)

## Conclusion

This section is not complete because I [decided not to use CPU cooling in my
first approach](nas.md#cpu-cooling). Keep on reading [Tom's hardware
guide](https://www.tomshardware.com/reviews/cooling-buying-guide,6105.html)
before you choose a cooling system.

# References

* [Tom's hardware CPU guide](https://www.tomshardware.com/reviews/cpu-buying-guide,5643.html)
* [Tom's hardware CPU cooling guide](https://www.tomshardware.com/reviews/cooling-buying-guide,6105.html)
* [How to select the best processor for your server](https://www.techmaish.com/how-to-select-the-best-processor-for-your-server/)
* [Cloudzy best server processor](https://cloudzy.com/best-server-processor/)
