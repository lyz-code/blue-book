---
title: Wireguard
date: 20200918
author: Lyz
---

[Wireguard](https://www.wireguard.com/) is an simple yet fast and modern VPN
that utilizes state-of-the-art cryptography. It aims to be faster, simpler,
leaner, and more useful than IPsec, while avoiding the massive headache. It
intends to be considerably more performant than OpenVPN. WireGuard is a general
purpose VPN for running on embedded interfaces and super computers alike.
Initially released for the Linux kernel, it's now cross-platform (Windows,
macOS, BSD, iOS, Android) and widely deployable. Although it's under heavy
development, it already might be the most secure, easiest to use, and simplest
VPN solution in the industry.

Features:

* Simple and easy to use: WireGuard aims to be as easy to configure and deploy
    as SSH. A VPN connection is made by exchanging public keys – exactly like
    exchanging SSH keys – and all the rest is transparently handled by
    WireGuard. It's even capable of roaming between IP addresses, like
    Mosh. There is no need to manage connections, worry about state,
    manage daemons, or worry about what's under the hood. WireGuard presents a
    basic yet powerful interface.

* Cryptographically Sound: WireGuard uses state-of-the-art cryptography, such as
    the Noise protocol framework, Curve25519, ChaCha20, Poly1305, BLAKE2,
    SipHash24, HKDF, and secure trusted constructions. It makes conservative and
    reasonable choices and has been reviewed by cryptographers.

* Minimal Attack Surface: WireGuard is designed with ease-of-implementation and
    simplicity in mind. It's meant to be implemented in very few lines of code,
    and auditable for security vulnerabilities. Compared to behemoths like
    *Swan/IPsec or OpenVPN/OpenSSL, in which auditing the gigantic codebases is
    an overwhelming task even for large teams of security experts, WireGuard is
    meant to be comprehensively reviewable by single individuals.

* High Performance: A combination of extremely high-speed cryptographic
    primitives and the fact that WireGuard lives inside the Linux kernel means
    that secure networking can be very high-speed. It is suitable for both small
    embedded devices like smartphones and fully loaded backbone routers.

* Well Defined & Thoroughly Considered: WireGuard is the result of a lengthy and
    thoroughly considered academic process, resulting in the technical
    whitepaper, an academic research paper which clearly defines the protocol
    and the intense considerations that went into each decision.

Plus it's created by the same guy as `pass`, which uses Gentoo, I like this guy.

# [Conceptual Overview](https://www.wireguard.com/)

WireGuard securely encapsulates IP packets over UDP. You add a WireGuard
interface, configure it with your private key and your peers' public keys, and
then you send packets across it. All issues of key distribution and pushed
configurations are out of scope of WireGuard; these are issues much better left
for other layers. It mimics the model of SSH and Mosh; both parties have each
other's public keys, and then they're simply able to begin exchanging packets
through the interface.

## Simple Network Interface

WireGuard works by adding network interfaces, called wg0 (or wg1, wg2, wg3,
etc). This network interface can then be configured normally using the ordinary
networking utilities. The specific WireGuard aspects of the interface are
configured using the `wg` tool. This interface acts as a tunnel interface.

WireGuard associates tunnel IP addresses with public keys and remote endpoints.
When the interface sends a packet to a peer, it does the following:

* This packet is meant for 192.168.30.8. Which peer is that? Let me look...
    Okay, it's for peer ABCDEFGH. (Or if it's not for any configured peer, drop
    the packet.)
* Encrypt entire IP packet using peer ABCDEFGH's public key.
* What is the remote endpoint of peer ABCDEFGH? Let me look... Okay, the
    endpoint is UDP port 53133 on host 216.58.211.110.
* Send encrypted bytes from step 2 over the Internet to 216.58.211.110:53133
    using UDP.

When the interface receives a packet, this happens:

* I just got a packet from UDP port 7361 on host 98.139.183.24. Let's decrypt
    it!
* It decrypted and authenticated properly for peer LMNOPQRS. Okay, let's
    remember that peer LMNOPQRS's most recent Internet endpoint is
    98.139.183.24:7361 using UDP.
* Once decrypted, the plain-text packet is from 192.168.43.89. Is peer LMNOPQRS
    allowed to be sending us packets as 192.168.43.89?
* If so, accept the packet on the interface. If not, drop it.

Behind the scenes there is much happening to provide proper privacy,
authenticity, and perfect forward secrecy, using state-of-the-art cryptography.

## Cryptokey Routing

At the heart of WireGuard is a concept called Cryptokey Routing, which works by
associating public keys with a list of tunnel IP addresses that are allowed
inside the tunnel. Each network interface has a private key and a list of peers.
Each peer has a public key.

For example, a server computer might have this configuration:

```
[Interface]
PrivateKey = yAnz5TF+lXXJte14tji3zlMNq+hd2rYUIgJBgB3fBmk=
ListenPort = 51820

[Peer]
PublicKey = xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=
AllowedIPs = 10.192.122.3/32, 10.192.124.1/24

[Peer]
PublicKey = TrMvSoP4jYQlY6RIzBgbssQqY3vxI2Pi+y71lOWWXX0=
AllowedIPs = 10.192.122.4/32, 192.168.0.0/16

[Peer]
PublicKey = gN65BkIKy1eCE9pP1wdc8ROUtkHLF2PfAqYdyYBz6EA=
AllowedIPs = 10.10.10.230/32
```

And a client computer might have this simpler configuration:

```
[Interface]
PrivateKey = gI6EdUSYvn8ugXOt8QQD6Yc+JyiZxIhp3GInSWRfWGE=
ListenPort = 21841

[Peer]
PublicKey = HIgo9xNzJMWLKASShiTqIybxZ0U3wGLiUeJ1PKf8ykw=
Endpoint = 192.95.5.69:51820
AllowedIPs = 0.0.0.0/0
```

In the server configuration, each peer (a client) will be able to send packets
to the network interface with a source IP matching his corresponding list of
allowed IPs. For example, when a packet is received by the server from peer
gN65BkIK..., after being decrypted and authenticated, if its source IP is
10.10.10.230, then it's allowed onto the interface; otherwise it's dropped.

In the server configuration, when the network interface wants to send a packet
to a peer (a client), it looks at that packet's destination IP and compares it
to each peer's list of allowed IPs to see which peer to send it to. For example,
if the network interface is asked to send a packet with a destination IP of
10.10.10.230, it will encrypt it using the public key of peer gN65BkIK..., and
then send it to that peer's most recent Internet endpoint.

In the client configuration, its single peer (the server) will be able to send
packets to the network interface with any source IP (since 0.0.0.0/0 is
a wildcard). For example, when a packet is received from peer HIgo9xNz..., if it
decrypts and authenticates correctly, with any source IP, then it's allowed onto
the interface; otherwise it's dropped.

In the client configuration, when the network interface wants to send a packet
to its single peer (the server), it will encrypt packets for the single peer
with any destination IP address (since 0.0.0.0/0 is a wildcard). For example, if
the network interface is asked to send a packet with any destination IP, it will
encrypt it using the public key of the single peer HIgo9xNz..., and then send it
to the single peer's most recent Internet endpoint.

In other words, when sending packets, the list of allowed IPs behaves as a sort
of routing table, and when receiving packets, the list of allowed IPs behaves as
a sort of access control list.

This is what we call a Cryptokey Routing Table: the simple association of public
keys and allowed IPs.

Because all packets sent on the WireGuard interface are encrypted and
authenticated, and because there is such a tight coupling between the identity
of a peer and the allowed IP address of a peer, system administrators do not
need complicated firewall extensions, such as in the case of IPsec, but rather
they can simply match on "is it from this IP? on this interface?", and be
assured that it is a secure and authentic packet. This greatly simplifies
network management and access control, and provides a great deal more assurance
that your iptables rules are actually doing what you intended for them to do.

## Built-in Roaming

The client configuration contains an initial endpoint of its single peer (the
server), so that it knows where to send encrypted data before it has received
encrypted data. The server configuration doesn't have any initial endpoints of
its peers (the clients). This is because the server discovers the endpoint of
its peers by examining from where correctly authenticated data originates. If
the server itself changes its own endpoint, and sends data to the clients, the
clients will discover the new server endpoint and update the configuration just
the same. Both client and server send encrypted data to the most recent IP
endpoint for which they authentically decrypted data. Thus, there is full IP
roaming on both ends.
