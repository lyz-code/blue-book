---
title: Power supply unit
date: 20221027
author: Lyz
---

[Power supply unit](https://linuxhint.com/pc-power-supply-unit/) is the component
of the computer that sources power from the primary source (the power coming
from your wall outlet) and delivers it to its motherboard and all its
components. Contrary to the common understanding, the PSU does not supply power
to the computer; it instead converts the AC (Alternating Current) power from the
source to the DC (Direct Current) power that the computer needs.

There are two types of PSU: Linear and Switch-mode. Linear power supplies have
a built-in transformer that steps down the voltage from the main to a usable one
for the individual parts of the computer. The transformer makes the Linear PSU
bulky, heavy, and expensive. Modern computers have switched to the switch-mode
power supply, using switches instead of a transformer for voltage regulation.
They’re also more practical and economical to use because they’re smaller,
lighter, and cheaper than linear power supplies.

PSU need to deliver at least the amount of power that each component requires,
if it needs to deliver more, it simply won't work.

Another puzzling question for most consumers is, “Does a PSU supply constant
wattage to the computer?” The answer is a flat No. The wattage you see on the
PSUs casing or labels only indicates the maximum power it can supply to the
system, theoretically. For example, by theory, a 500W PSU can supply a maximum
of 500W to the computer. In reality, the PSU will draw a small portion of the
power for itself and distributes power to each of the PC components according to
its need. The amount of power the components need varies from 3.3V to 12V. If
the total power of the components needs to add up to 250W, it would only use
250W of the 500W, giving you an overhead for additional components or future
upgrades.

Additionally, the amount of power the PSU supplies varies during peak periods
and idle times. When the components are pushed to their limits, say when a video
editor maximizes the GPU for graphics-intensive tasks, it would require more
power than when the computer is used for simple tasks like web-browsing. The
amount of power drawn from the PSU would depend on two things; the amount of
power each component requires and the tasks that each component performs.

# [Power supply efficiency](https://linuxhint.com/pc-power-supply-unit/)

When PSU converts the AC power to DC, some of the power is wasted and is
converted to heat. The more heat a PSU generates, the less efficient it is.
Inefficient PSUs will likely damage the computer’s components or shorten their
lifespans in the long run. They also draw more power from the primary source
resulting in higher electricity bills for consumers.

You might’ve seen 80 PLUS stickers on PSUs or its other variants like 80 PLUS
Bronze, Silver, Gold, Platinum, and Titanium. 80 PLUS is the power supply’s
efficiency rating; the power supply must reach 80% efficiency to be certified.
It’s a voluntary standard, which means companies don’t need to abide by the
standard, but 80 PLUS certifications have become popular because a more
efficient power supply can lessen the consumers’ carbon footprint and help them
save some bucks on their electric bills. Below is the efficiency rating that
a PSU needs to achieve to get the desired rating.

| Certification Levels | Efficiency at 10% Load | Efficiency at 20% Load | Efficiency at 50% Load | Efficiency at 100% Load |
| ---                  | ---                    | ---                    | ---                    | ---                     |
| 80 PLUS (White)             | —                      | 80%                    | 80%                    | 80%                     |
| 80 PLUS Bronze       | —                      | 82%                    | 85%                    | 82%                     |
| 80 PLUS Silver       | —                      | 85%                    | 88%                    | 85%                     |
| 80 PLUS Gold         | —                      | 87%                    | 90%                    | 87%                     |
| 80 PLUS Platinum     | —                      | 90%                    | 92%                    | 89%                     |
| 80 PLUS Titanium     | 90%                    | 92%                    | 94%                    | 90%                     |

It’s important to note that the 80% efficiency does not mean that the PSU will
only supply 80% of its capacity to the computer. It means it will draw
additional power from the primary source to only 20% of power is lost or
generated as heat during the conversion. A 500W PSU will therefore draw 625W of
power from the main to make it 80% efficient.

Higher efficiency also means the internal components are subjected to less heat
and are likely to have a longer lifespan. They may cost a bit more, but higher
certified power supplies tend to be more reliable than others. Luckily, most
manufacturers offer warranties.

# [Power supply shopping tips](https://www.tomshardware.com/reviews/best-psus,4229.html)

* *Determine wattage requirements*: You don't need to purchase much more potential
    power capacity (wattage) than you’ll ever use. You can calculate roughly how
    much power your new or upgraded system will draw from the wall and look for
    a capacity point that satisfies your demands. Several power supply sellers have
    calculators that will give you a rough estimate of your system's power needs.
    You can find a few below:

    * [PCPartPicker](https://pcpartpicker.com/list/)
    * [OuterVision PSU calculator](https://outervision.com/power-supply-calculator)
    * [be quiet! PSU
        Calculator](https://www.bequiet.com/en/psucalculator)
    * [Cooler Master Power Calculator](http://www.coolermaster.com/power-supply-calculator/)
    * [Seasonic Wattage Calculator](https://seasonic.com/wattage-calculator)
    * [MSI PSU Calculator](https://www.msi.com/calculator)
    * [Newegg PSU Calculator](https://www.newegg.com/tools/power-supply-calculator/)

* *Consider upcoming GPU power requirements*: Although the best graphics cards
    are usually more power-efficient than previous generations, their power
    consumption increases overall. This is why the latest 12+4 pin connector
    that the upcoming generation graphics cards will use will provide up to 600
    W of power. Currently, a pair of PCIe 6+2 pin connectors on dedicated cables
    are officially rated for up to 300W, and three of these connectors can
    deliver up to 450W safely. You should also add the up to 75W that the PCIe
    slot can provide in these numbers.

    What troubles today's power supplies is not the maximum sustained power
    consumption of a GPU but its power spikes, and this is why various
    manufacturers suggest strong PSUs for high-end graphics cards. If the PSU's
    over current and over power protection features are conservatively set, the
    PSU can shut down once the graphics card asks for increased power, even for
    very short periods ( nanoseconds range). This is why EVGA offers two
    different OPP features in its G6 and P6 units, called firmware and hardware
    OPP. The first triggers at lower loads, in the millisecond range, while the
    latter triggers at higher loads that last for some nanoseconds. This way,
    short power spikes from the graphics card are addressed without shutting
    down the system.

    If you add the increased power demands of modern high-end CPUs, you can
    quickly figure out why strong PSUs are necessary again. Please look at our
    GPU Benchmarks and CPU Benchmarks hierarchies to see how each of these chips
    perform relative to each other.

* *Check the physical dimensions of your case before buying*: If you have
    a standard ATX case, whether or not it is one of the best PC cases, an ATX
    power supply will fit. But many higher-wattage PSUs are longer than the
    typical 5.5 inches. So you'll want to be sure of your cases' PSU clearance.
    If you have an exceptionally small or slim PC case, it may require a less
    typical (and more compact) SFX power supply.

* *Consider a modular power supply*: If your case has lots of room behind the
    motherboard, or your chassis doesn't have a window or glass side, you can
    cable-wrap the wires you don't' need and stash them inside your rig. But if
    the system you're' building doesn't' have space for this, or there is no
    easy place to hide your cable mess, it's' worth paying extra for a modular
    power supply. Modular PSUs let you only plug in the power cables you need
    and leave the rest in the box.

# Market analysis

I'm searching for a power supply unit that can deliver 264W and can grow up to
373W. This means that the load is:

| Type     | 400W | 450W | 500W |
| ---      | ---  | ---  | ---  |
| Min load | 66%  | 59%  | 52%  |
| Max load | 93%  | 83%  | 74%  |

Given that PSU look to be more efficient when they have a load of 50%, the 450W
or 500W would be better. Although if the efficiency goes over 80 PLUS Gold, the
difference is almost negligible. I'd prioritize first the efficiency. But any
PSU from 400W to 500W will work for me.

[Toms Hardware](https://www.tomshardware.com/reviews/best-psus,4229.html),
[PCGamer](https://www.pcgamer.com/best-power-supply-unit-for-pc-gaming-our-top-psu-for-pc/),
[IGN](https://www.ign.com/articles/best-power-supply)
recommends:

* Corsair CX450: It has 80 PLUS Bronze, so I'll discard it
* XPG Pylon 450: It has 80 PLUS Bronze too...

None of the suggested PSU are suited for my case. I'm going to select then which
is the brands that are more suggested:

| Brand         | Tom's recommendations | PCGamer recommendations | IGN |
| ---           | ---                   | ---                     | --- |
| Corsair       | 6                     | 2                       | 3   |
| Be quiet      | 1                     | 1                       | 1   |
| Silverstone   | 1                     | 1                       | 1   |
| Cooler Master | 1                     | 0                       | 1   |
| XPG           | 1                     | 1                       | 0   |
| EVGA          | 1                     | 0                       | 0   |
| Seasonic      | 0                     | 1                       | 0   |

It looks that the most popular are Corsair, Be quiet and Silverstone.

* [Corsair](https://www.corsair.com/ww/en/Categories/Products/Power-Supply-Units/c/Cor_Products_PowerSupply_Units?q=%3Afeatured%3ApsuPower%3A450%2BWatts%3ApsuPower%3A500%2BWatts%3ApsuPower%3A550%2BWatts&text=&pageSize=12#rotatingText)
doesn't have anyone with certification above Bronce.
* [Silverstone](https://www.corsair.com/ww/en/Categories/Products/Power-Supply-Units/c/Cor_Products_PowerSupply_Units?q=%3Afeatured%3ApsuPower%3A450%2BWatts%3ApsuPower%3A500%2BWatts%3ApsuPower%3A550%2BWatts&text=&pageSize=12#rotatingText)
    Under or equal to 500 it has one gold, at 520 it has a platinum and on the
    550W it has has 4 gold and another platinum.

    * [ET500-MG](https://www.silverstonetek.com/en/product/info/power-supplies/ET500-MG/)
    * [NJ520](https://www.silverstonetek.com/en/product/info/power-supplies/NJ520/)

* [Be quiet](https://www.bequiet.com/en/compare/powersupply/series) has both
    gold and platinum on the range of 550 and above. Gold and bronze on the 500-400W
    range.
    * [Pure Power 11 CM 500W](https://www.bequiet.com/en/powersupply/1537)
    * [Pure Power 11 500W](https://www.bequiet.com/en/powersupply/1546)
    * [SFX L Power 500W](https://www.bequiet.com/en/powersupply/1555)
    * [Straigt Power 11 450W](https://www.bequiet.com/en/powersupply/1251)

It looks like I have to forget of efficiency above Gold unless I want to go with
520W. After a quick search on the provider I see that the most interesting in
price are:

* Be Quiet! Straight Power 11 450W
* Be Quiet! Pure Power 11 CM 500W
* Be Quiet! Pure Power 11 500W

I'm also going to trust Be Quiet on the CPU cooler so I'm happy with staying on
the same brand for all fans.

| Type     | 400W | 450W | 500W |
| ---      | ---  | ---  | ---  |
| Min load | 66%  | 59%  | 52%  |
| Max load | 93%  | 83%  | 74%  |

| Model              | Pure Power 11 CM 500W     | Pure Power 11 500W        | Straight Power 11 450W |
| ---                | ---                       | ---                       | ---                    |
| Continuous Power   | 500                       | 500                       | 450                    |
| Peak Power         | 550                       | 550                       | 500                    |
| Min load (my case) | 52%                       | 52%                       | 59%                    |
| Max load (my case) | 74%                       | 74%                       | 83%                    |
| Topology           | Active Clamp / SR / DC/DC | Active Clamp / SR / DC/DC | LLC / SR / DC/DC       |
| Fan dB(A) at 20%   | 9                         | 9.3                       | 9.4                    |
| Fan dB(A) at 50%   | 9.3                       | 9.6                       | 9.8                    |
| Fan dB(A) at 100%  | 18.8                      | 21.6                      | 12.3                   |
| dB(A) Min load     | 9.68                      | -                         | 10.25                  |
| dB(A) Max load     | 13.86                     | -                         | 11.45                  |
| SIP Protection     | Yes                       | No                        | Yes                    |
| Efficiency Cert    | Gold                      | Gold                      | Gold                   |
| Efficiency 20%     | 90.6                      | 88.2                      | 91                     |
| Efficiency 50%     | 92.1                      | 91.3                      | 93.1                   |
| Efficiency 100%    | 90.1                      | 89.9                      | 91.7                   |
| Cable management   | Semi-modular              | Fixed                     | Modular                |
| Cable cm to mb     | 55                        | 55                        | 60                     |
| Max cable length   | 95                        | 95                        | 115                    |
| No. of cables      | 7                         | 7                         | 8                      |
| ATX-MB (20+4-pin)  | 1                         | 1                         | 1                      |
| P4+4 (CPU)         | 1                         | 1                         | 1                      |
| PCI-e 6+2 (GPU)    | 2                         | 2                         | 2                      |
| SATA               | 6                         | 6                         | 8                      |
| Dimensions         | 160 x 150 x 86            | 150 x 150 x 86            | 160 x 150 x 86         |
| Warranty (Years)   | 5                         | 5                         | 5                      |
| Price (EUR)        | 85.93                     | 79.02                     | 99.60                  |

I'd discard the Pure Power 11 500W because it:

* Has significantly worse efficiency
* Doesn't have SIP protection
* The fan is the loudest

Between the other two Straight Power 11 has the advantages:

* 1% more efficiency.
* Will make 0.5dB more noise at min load but 2.41dB less at max load. So I expect it to be more silent
* Cables look better
* Has more cable length
* Has more SATA cables (equal to my number of drives)

And the disadvantages:

* Is 13.66 EUR more expensive
* Has 50W less of power

It doesn't look like I'm going to need the extra power, and if I need it (if
I add a graphic card) then the 500W wouldn't work either. And the difference in
money is not that big. Therefore I'll go with the Straight Power 11 450W

# References

* [Linuxhint article on PSU](https://linuxhint.com/pc-power-supply-unit/)
