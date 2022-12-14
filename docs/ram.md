---
title: RAM
date: 20221014
author: Lyz
---

[RAM](https://en.wikipedia.org/wiki/Random-access_memory) is a form of computer
memory that can be read and changed in any order, typically used to store
working data and machine code.

A random-access memory device allows data items to be read or written in almost
the same amount of time irrespective of the physical location of data inside the
memory, in contrast with other direct-access data storage media (such as hard
disks), where the time required to read and write data items varies
significantly depending on their physical locations on the recording medium, due
to mechanical limitations such as media rotation speeds and arm movement.

They are the faster device either to read or to write your data.

# Properties

RAM sticks vary on:

- Size: the amount of data that they can hold, measured in GB.

- Frequency: how often the RAM is accessed per second, measured in MHz.

- Clock latency (CL): number of cycles before the RAM responds.

- Type: as the technology evolves there are different types, such as DDR4.

- Form factor: There are different types of RAM in regards of the devices
  they'll fit in:

  - 260-pin SO-DIMMs: laptop RAM, shorter, slower, more expensive, and won't fit
    in a desktop system.
  - 288-pin DIMMs: desktop RAM - required for most desktop motherboards.

- [ECC](#ecc): Whether it has error correction code.

## [Speed](https://www.reddit.com/r/buildapc/comments/xuqwku/what_does_the_mhz_on_a_ram_stick_mean_and_what/)

RAM's speed is measured as a combination of frequency and clock latency. More
cycles per second means the RAM is 'faster', but you also have to consider
latency as well. If you compare MHz and CL, you can get an idea of actual speed.
For example, 3600 MHz CL18 and 3200 MHz CL16 are the same speed on paper since
the faster 3600 MHz takes more clocks to respond, but there are more clocks per
second, so the response time is actually the same.

!!! note In reality, faster RAM will be a little bit faster in modern
architectures. Also, Ryzen specifically prefers 3600 MHz RAM because of how its
FCLK works it likes whole-number multipliers, so if it can run at 1800 MHz (x2 =
3600 MHz with the RAM), then it will run 2-3% faster than equivalent 3200 MHz
RAM.

Summing up, the higher the speed, and the lower the CL, the better the overall
performance.

```
RAM latency (lower the better) = (CAS Latency (CL) x 2000 ) / Frequency (MHz)
```

### [ECC](https://en.wikipedia.org/wiki/ECC_memory)

Error correction code memory (ECC memory) is a type of computer data storage
that uses an error correction code to detect and correct n-bit data corruption
which occurs in memory. ECC memory is used in most computers where data
corruption cannot be tolerated, for example when using [zfs](zfs.md).

# [How to choose a RAM stick](https://www.reddit.com/r/buildapc/comments/xuqwku/what_does_the_mhz_on_a_ram_stick_mean_and_what/)

## [CPU brand](https://www.cclonline.com/article/1884/Guide/Desktop-Memory/How-to-Choose-RAM-Speed-MHz-CL-vs-Capacity-GB-/?__cf_chl_f_tk=g_qEntxC5HyO6sQoJNGJGclCY0Iw3jCcjRpeVSpZbGM-1665758062-0-gaNycGzNBj0)

Depending on your CPU brand you need to take into account the next advices:

- Intel: Intel CPUs aren’t massively reliant on the performance of memory while
  running, which might explain why RAM speed support has historically been
  rather limited outside of Intel’s enthusiast chipsets (Z-Series) and capped to
  2666Mhz (at least until recently).

  If you’re the owner of an Intel CPU we certainly suggest getting a good
  quality RAM kit, but the speed of that RAM isn’t as important. Save your money
  for other components or a RAM capacity upgrade if required.

- AMD: In stark contrast to Intel, AMD’s more recent ‘Zen’ line of CPUs has RAM
  speed almost baked into the architecture of the CPU.

  AMD’s infinity fabric technology uses the speed of the RAM to pass information
  across sections of the CPU. This means that better memory will serve to boost
  the CPU performance as well as helping in those intense applications we
  mentioned earlier.

## Motherboard

Many manufacturers list specific RAM kits as ‘verified’ with their products,
meaning that the manufacturer has tested the motherboard model in question with
a specific RAM kit and has confirmed full support for that kit, at its
advertised speed and CAS latency.

Try to purchase RAM listed on your motherboard’s QVL where possible, for the
best compatibility. However, this is almost always impractical given the
availability of exact RAM kits at any given time.

## [Achieving stability](https://www.cclonline.com/article/1884/Guide/Desktop-Memory/How-to-Choose-RAM-Speed-MHz-CL-vs-Capacity-GB-/?__cf_chl_f_tk=g_qEntxC5HyO6sQoJNGJGclCY0Iw3jCcjRpeVSpZbGM-1665758062-0-gaNycGzNBj0)

Speed, CAS latency, module size, and module quantity; in order to avoid running
into problems you should balance these factors when considering your purchase.

For example, 16GB of 3600MHz CL16 memory is much more likely to be stable than
32GB of the same modules, even if the settings in BIOS remain the same.

Consider another example - you may want to run 64GB of RAM at 3600MHz, but to
get it to run properly you need to lower the speed to 3000MHz.

## Conclusion

In summary, a high-performance 3600MHz memory kit is ideal for AMD Ryzen CPUs.
Decide the size, speed, if you need ECC and make sure which type of RAM does
your CPU and motherboard combo support (ie, DDR3, DDR4, or DDR5), and that
you're choosing the correct form factor. Then, buy a kit that is in line with
your budget.

You're probably looking for DDR4, probably `2x8 = 16 GB`. The sweet spot there
will likely be 3600 MHz CL18 or 3200 MHz CL16 for $55 or so. Technically, you
should check your motherboard's QVL (list of RAM that is guaranteed to work),
but most big-name brands should work. There are other things to consider - like,
does your cooler interfere with RAM? But, generally only top-tier coolers have
RAM fitment issues.

# References

- [How to choose RAM: Speed vs Capacity](https://www.cclonline.com/article/1884/Guide/Desktop-Memory/How-to-Choose-RAM-Speed-MHz-CL-vs-Capacity-GB-/?__cf_chl_f_tk=g_qEntxC5HyO6sQoJNGJGclCY0Iw3jCcjRpeVSpZbGM-1665758062-0-gaNycGzNBj0)
