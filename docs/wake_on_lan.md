---
title: Wake on LAN
date: 20201227
author: Lyz
---

[Wake on LAN](https://wiki.archlinux.org/index.php/Wake-on-LAN) (WoL) is
a feature to switch on a computer via the network.

# Usage

## Host configuration

On the host you want to activate the wake on lan execute:

```bash
$: ethtool *interface* | grep Wake-on

Supports Wake-on: pumbag
Wake-on: d
```

The Wake-on values define what activity triggers wake up: d (disabled), p (PHY
activity), u (unicast activity), m (multicast activity), b (broadcast activity),
a (ARP activity), and g (magic packet activity). The value g is required for WoL
to work, if not, the following command enables the WoL feature in the driver:

```bash
$: ethtool -s interface wol g
```

If it was not enabled check in the [Arch
wiki](https://wiki.archlinux.org/index.php/Wake-on-LAN) how to make the change
persistent.

To trigger WoL on a target machine, its MAC address must be known. To obtain it,
execute the following command from the machine:

```bash
$: ip link

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default
   link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp1s0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc fq_codel master br0 state UP group default qlen 1000
    link/ether 48:05:ca:09:0e:6a brd ff:ff:ff:ff:ff:ff
```

Here the MAC address is `48:05:ca:09:0e:6a`.

In its simplest form, Wake-on-LAN broadcasts the magic packet as an ethernet
frame, containing the MAC address within the current network subnet, below the
IP protocol layer. The knowledge of an IP address for the target computer is not
necessary, as it operates on layer 2 (Data Link).

If used to wake up a computer over the internet or in a different subnet, it
typically relies on the router to relay the packet and broadcast it. In this
scenario, the external IP address of the router must be known. Keep in mind that
most routers by default will not relay subnet directed broadcasts as a safety
precaution and need to be explicitly told to do so.

## Client trigger

If you are connected directly to another computer through a network cable, or
the traffic within a LAN is not firewalled, then using Wake-on-LAN should be
straightforward since there is no need to worry about port redirects.

If it's firewalled you need to configure the client firewall to allow the
outgoing UDP traffic to the port 9.

In the simplest case the default broadcast address 255.255.255.255 is used:

```bash
$ wakeonlan *target_MAC_address*
```

To broadcast the magic packet only to a specific subnet or host, use the `-i`
switch:

```bash
$ wakeonlan -i *target_IP* *target_MAC_address*
```

# References

* [Arch wiki post](https://wiki.archlinux.org/index.php/Wake-on-LAN)
