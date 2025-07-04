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

- Simple and easy to use: WireGuard aims to be as easy to configure and deploy
  as SSH. A VPN connection is made by exchanging public keys – exactly like
  exchanging SSH keys – and all the rest is transparently handled by
  WireGuard. It's even capable of roaming between IP addresses, like
  Mosh. There is no need to manage connections, worry about state,
  manage daemons, or worry about what's under the hood. WireGuard presents a
  basic yet powerful interface.

- Cryptographically Sound: WireGuard uses state-of-the-art cryptography, such as
  the Noise protocol framework, Curve25519, ChaCha20, Poly1305, BLAKE2,
  SipHash24, HKDF, and secure trusted constructions. It makes conservative and
  reasonable choices and has been reviewed by cryptographers.

- Minimal Attack Surface: WireGuard is designed with ease-of-implementation and
  simplicity in mind. It's meant to be implemented in very few lines of code,
  and auditable for security vulnerabilities. Compared to behemoths like
  \*Swan/IPsec or OpenVPN/OpenSSL, in which auditing the gigantic codebases is
  an overwhelming task even for large teams of security experts, WireGuard is
  meant to be comprehensively reviewable by single individuals.

- High Performance: A combination of extremely high-speed cryptographic
  primitives and the fact that WireGuard lives inside the Linux kernel means
  that secure networking can be very high-speed. It is suitable for both small
  embedded devices like smartphones and fully loaded backbone routers.

- Well Defined & Thoroughly Considered: WireGuard is the result of a lengthy and
  thoroughly considered academic process, resulting in the technical
  whitepaper, an academic research paper which clearly defines the protocol
  and the intense considerations that went into each decision.

Plus it's created by the same guy as `pass`, which uses Gentoo, I like this guy.

# [Installation](https://linuxize.com/post/how-to-set-up-wireguard-vpn-on-ubuntu-20-04/)

## Debian

WireGuard is available from the default repositories. To install it, run the following commands:

```bash
sudo apt install wireguard
```

### Configuring Wireguard

The `wg` and `wg-quick` command-line tools allow you to configure and manage the WireGuard interfaces.

Each device in the WireGuard VPN network needs to have a private and public key. Run the following command to generate the key pair:

```bash
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
```

The files will be generated in the `/etc/wireguard` directory.

Wireguard also supports a pre-shared key, which adds an additional layer of symmetric-key cryptography. This key is optional and must be unique for each peer pair.

The next step is to configure the tunnel device that will route the VPN traffic.

The device can be set up either from the command line using the `ip` and `wg` commands, or by creating the configuration file with a text editor.

Create a new file named `wg0.conf` and add the following contents:

```bash
sudo nano /etc/wireguard/wg0.conf
```

```ini
[Interface]
Address = 10.0.0.1/24
SaveConfig = true
ListenPort = 51820
PrivateKey = SERVER_PRIVATE_KEY
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE
```

The interface can be named anything, however it is recommended to use something like `wg0` or `wgvpn0`. The settings in the interface section have the following meaning:

- Address: A comma-separated list of v4 or v6 IP addresses for the wg0 interface. Use IPs from a range that is reserved for private networks (10.0.0.0/8, 172.16.0.0/12 or 192.168.0.0/16).
- ListenPort - The listening port.
- PrivateKey - A private key generated by the `wg genkey` command. (To see the contents of the file type: `sudo cat /etc/wireguard/privatekey`)
- SaveConfig - When set to true, the current state of the interface is saved to the configuration file when shutdown.
- PostUp - Command or script that is executed before bringing the interface up. In this example, we’re using iptables to enable masquerading. This allows traffic to leave the server, giving the VPN clients access to the Internet.

  Make sure to replace `ens3` after `-A POSTROUTING` to match the name of your public network interface. You can easily find the interface with:

  ```bash
  ip -o -4 route show to default | awk '{print $5}'
  ```

- PostDown - command or script which is executed before bringing the interface down. The iptables rules will be removed once the interface is down.

The `wg0.conf` and `privatekey` files should not be readable to normal users. Use `chmod` to set the permissions to `600`:

```bash
sudo chmod 600 /etc/wireguard/{privatekey,wg0.conf}
```

Once done, bring the `wg0` interface up using the attributes specified in the configuration file:

```bash
sudo wg-quick up wg0
```

The command will produce an output similar to the following:

```bash
[#] ip link add wg0 type wireguard
[#] wg setconf wg0 /dev/fd/63
[#] ip -4 address add 10.0.0.1/24 dev wg0
[#] ip link set mtu 1420 up dev wg0
[#] iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
```

To check the interface state and configuration, enter:

```bash
sudo wg show wg0

interface: wg0
  public key: r3imyh3MCYggaZACmkx+CxlD6uAmICI8pe/PGq8+qCg=
  private key: (hidden)
```

You can also run `ip` a show `wg0` to verify the interface state:

```bash
ip a show wg0

4: wg0: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1420 qdisc noqueue state UNKNOWN group default qlen 1000
    link/none
    inet 10.0.0.1/24 scope global wg0
       valid_lft forever preferred_lft forever
```

WireGuard can also be managed with Systemd.

To bring the WireGuard interface at boot time, run the following command:

```bash
sudo systemctl enable wg-quick@wg0
```

### [Server Networking and Firewall Configuration](https://linuxize.com/post/how-to-set-up-wireguard-vpn-on-ubuntu-20-04/#server-networking-and-firewall-configuration)

IP forwarding must be enabled for NAT to work. Open the `/etc/sysctl.conf` file and add or uncomment the following line:

```bash
sudo vi /etc/sysctl.conf
```

```ini
net.ipv4.ip_forward=1
```

Save the file and apply the change:

```bash
sudo sysctl -p

net.ipv4.ip_forward = 1
```

If you are using UFW to manage your firewall you need to open UDP traffic on port 51820:

```bash
sudo ufw allow 51820/udp
```

### [Client setup ](https://linuxize.com/post/how-to-set-up-wireguard-vpn-on-ubuntu-20-04/#linux-and-macos-clients-setup)

Also install `wireguard` in your clients. The process for setting up a client is pretty much the same as you did for the server.

If the client is on Android, [the official app](https://www.wireguard.com/install/) is not on F-droid, but you can get it through the Aurora store

First generate the public and private keys:

```bash
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
```

Create the file `wg0.conf` and add the following contents:

```bash
sudo vi /etc/wireguard/wg0.conf
```

```ini
[Interface]
PrivateKey = CLIENT_PRIVATE_KEY
Address = 10.0.0.2/24

[Peer]
PublicKey = SERVER_PUBLIC_KEY
Endpoint = SERVER_IP_ADDRESS:51820
AllowedIPs = 0.0.0.0/0
```

The settings in the interface section have the same meaning as when setting up the server:

- Address: A comma-separated list of v4 or v6 IP addresses for the `wg0` interface.
- PrivateKey: To see the contents of the file on the client machine run: `sudo cat /etc/wireguard/privatekey`

The peer section contains the following fields:

- PublicKey: A public key of the peer you want to connect to. (The contents of the server’s `/etc/wireguard/publickey` file).
- Endpoint: An IP or hostname of the peer you want to connect to followed by a colon, and then a port number on which the remote peer listens to.
- AllowedIPs: A comma-separated list of v4 or v6 IP addresses from which incoming traffic for the peer is allowed and to which outgoing traffic for this peer is directed. We’re using 0.0.0.0/0 because we are routing the traffic and want the server peer to send packets with any source IP.

If you need to configure additional clients, just repeat the same steps using a different private IP address.

### [Add the client IP to the server ](https://linuxize.com/post/how-to-set-up-wireguard-vpn-on-ubuntu-20-04/#add-the-client-peer-to-the-server)

The last step is to add the client’s public key and IP address to the server. To do that, run the following command on the Ubuntu server:

```bash
sudo wg set wg0 peer CLIENT_PUBLIC_KEY allowed-ips 10.0.0.2
```

Make sure to change the `CLIENT_PUBLIC_KEY` with the public key you generated on the client machine (`sudo cat /etc/wireguard/publickey`) and adjust the client IP address if it is different.

Once done, go back to the client machine and bring up the tunneling interface.

```bash
sudo wg-quick up wg0
```

Now you should be connected to the Ubuntu server, and the traffic from your client machine should be routed through it. You can check the connection with:

```bash
sudo wg

interface: wg0
  public key: gFeK6A16ncnT1FG6fJhOCMPMeY4hZa97cZCNWis7cSo=
  private key: (hidden)
  listening port: 53527
  fwmark: 0xca6c

peer: r3imyh3MCYggaZACmkx+CxlD6uAmICI8pe/PGq8+qCg=
  endpoint: XXX.XXX.XXX.XXX:51820
  allowed ips: 0.0.0.0/0
  latest handshake: 53 seconds ago
  transfer: 3.23 KiB received, 3.50 KiB sent
```

You can also open your browser, type “what is my ip”, and you should see your server IP address.

To stop the tunneling, bring down the wg0 interface:

```bash
sudo wg-quick down wg0
```

### [Allow the access to the local network](https://wiki.archlinux.org/title/WireGuard)

If you want to let the peer access a server of your local network you could add it to the `allowed-ips`.

```bash
sudo wg set wg0 peer CLIENT_PUBLIC_KEY allowed-ips 10.0.0.2,192.168.3.123/32
```

Then you need to add the routes:

```bash
ip route add 192.168.3.123 dev wg0
```

## NixOS

Follow the guides of the next references:

- https://nixos.wiki/wiki/WireGuard
- https://wiki.archlinux.org/title/WireGuard
- https://alberand.com/nixos-wireguard-vpn.html

# Operation

## [Check the status of the tunnel](https://www.vmwaremine.com/2020/10/01/how-to-check-vpn-link-status-on-wireguard/)

One method is to do ping between VPN IP addresses or run command `wg show`` from the server or from the client.
Below you can see `wg show`` command output where VPN is _not_ up.

```bash
$: wg show
interface: wg0
  public key: qZ7+xNeXCjKdRNM33Diohj2Y/KSOXwvFfgTS1LRx+EE=
  private key: (hidden)
  listening port: 45703

peer: mhLzGkqD1JujPjEfZ6gkbusf3sfFzy+1KXBwVNBRBHs=
  endpoint: 3.133.147.235:51820
  allowed ips: 10.100.100.1/32
  transfer: 0 B received, 592 B sent
  persistent keepalive: every 21 seconds
```

The below output from the `wg show` command indicates the VPN link is up. See the line with `last handshake time`

```bash
$: wg show
interface: wg0
  public key: qZ7+xNeXCjKdRNM33Diohj2Y/KSOXwvFfgTS1LRx+EE=
  private key: (hidden)
  listening port: 49785

peer: 6lf4SymMbY+WboI4jEsM+P9DhogzebSULrkFowDTt0M=
  endpoint: 3.133.147.235:51820
  allowed ips: 10.100.100.1/32
  latest handshake: 14 seconds ago
  transfer: 732 B received, 820 B sent
  persistent keepalive: every 21 seconds
```

## [Remove a peer](https://forum.netgate.com/topic/165845/enable-disable-wireguard-peer-by-cli/5)

```bash
wg show (find the peer, note the interface and peer key)
wg set <interface> peer <key> remove
```

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

- This packet is meant for 192.168.30.8. Which peer is that? Let me look...
  Okay, it's for peer ABCDEFGH. (Or if it's not for any configured peer, drop
  the packet.)
- Encrypt entire IP packet using peer ABCDEFGH's public key.
- What is the remote endpoint of peer ABCDEFGH? Let me look... Okay, the
  endpoint is UDP port 53133 on host 216.58.211.110.
- Send encrypted bytes from step 2 over the Internet to 216.58.211.110:53133
  using UDP.

When the interface receives a packet, this happens:

- I just got a packet from UDP port 7361 on host 98.139.183.24. Let's decrypt
  it!
- It decrypted and authenticated properly for peer LMNOPQRS. Okay, let's
  remember that peer LMNOPQRS's most recent Internet endpoint is
  98.139.183.24:7361 using UDP.
- Once decrypted, the plain-text packet is from 192.168.43.89. Is peer LMNOPQRS
  allowed to be sending us packets as 192.168.43.89?
- If so, accept the packet on the interface. If not, drop it.

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

# [Improve logging](https://www.procustodibus.com/blog/2021/03/wireguard-logs/)

WireGuard doesn’t do any logging by default. If you use the WireGuard Linux kernel module (on kernel versions 5.6 or newer), you can turn on WireGuard’s dyndbg logging, which sends log messages to the kernel message buffer, kmsg. You can then use the standard dmesg utility to read these messages. Also, many Linux systems have a logging daemon like rsyslogd or journald that automatically captures and stores these messages.

First, enable WireGuard `dyndbg` logging with the following commands:

```bash
modprobe wireguard
echo module wireguard +p > /sys/kernel/debug/dynamic_debug/control
```

Once you do that, you’ll be able to see WireGuard log messages in the kernel message facility, if your system is set up with `rsyslogd`, `journald`, or a similar logging daemon. With `rsyslogd`, check the `/var/log/kern.log` or `/var/log/messages` file. With `journald`, run `journalctl -ek`.

# User management

Wireguard's default user management is not very user friendly as it's difficult to know which key belongs to what user.

I've been looking for WireGuard admin interface UI that is actively maintained but also isn't cloud-based and [between all solutions](https://www.reddit.com/r/selfhosted/comments/18nrbnf/wireguard_admin_interface_ui_that_is_actively/) I found [wg-easy](wg-easy.md) the best candidate because:

- It has just the features I need:
  - Clean User management: add, remove, disable
  - Clean UI interface
- Actively maintained: last commit 7h ago
- [Really popular: 17.7k stars, 1.7k forks](https://github.com/wg-easy/wg-easy/tree/master)
- It's installable either with docker or [docker-compose](https://github.com/wg-easy/wg-easy/blob/production/docker-compose.yml)
- It exports [prometheus metrics](https://github.com/wg-easy/wg-easy/issues/1510)
- It has [good documentation](https://github.com/wg-easy/wg-easy/wiki).
- It has [an ansible playbook](https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-Ansible)
- It has [a grafana dashboard](https://grafana.com/grafana/dashboards/21733-wireguard/)
- It has [a clean release process](https://github.com/wg-easy/wg-easy/tree/master)
- It's a stable project: 3 years and 10 months old

If `wg-easy` doesn't work, I'd look at the next projects:

- [WGDashboard](https://github.com/donaldzou/WGDashboard?tab=readme-ov-file) ([Docs](https://donaldzou.dev/WGDashboard-Documentation/index_topic.html))
- [easy-wg-quick](https://github.com/burghardt/easy-wg-quick)
- [wireguard-ui](https://github.com/ngoduykhanh/wireguard-ui)
- [wg-tool](https://github.com/gene-git/wg_tool) and [wg-client](https://github.com/gene-git/wg-client)

# Monitor wireguard

See [the wg-easy page](wg-easy.md#monitoring).

# [Configure the kill switch](https://git.zx2c4.com/wireguard-tools/about/src/man/wg-quick.8)

You can configure a kill-switch in order to prevent the flow of unencrypted packets through the non-WireGuard interfaces, by adding the following two lines ‘PostUp‘ and ‘PreDown‘ lines to the ‘[Interface]‘ section:

```
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
```

The ‘PostUp’ and ‘PreDown’ fields have been added to specify an iptables command which, when used with interfaces that have a peer that specifies 0.0.0.0/0 as part of the ‘AllowedIPs’, works together with wg-quick’s fwmark usage in order to drop all packets that are either not coming out of the tunnel encrypted or not going through the tunnel itself. Note that this continues to allow most DHCP traffic through, since most DHCP clients make use of PF_PACKET sockets, which bypass Netfilter. When IPv6 is in use, additional similar lines could be added using ip6tables.

If you want to allow the traffic to your LAN while keeping your kill-switch you can use:

```
PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && iptables -I OUTPUT -p tcp -d 192.168.0.0/24 -j ACCEPT
PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && iptables -D OUTPUT -p tcp -d 192.168.0.0/24 -j ACCEPT
```

Here I'm assuming that your LAN is defined by `192.168.0.0/24`.

[One way to test if the kill switch works](https://www.ivpn.net/knowledgebase/linux/linux-wireguard-kill-switch/) is by deleting the IP address from the wireguard interface

```bash
sudo ip a del [IP address] dev [interface]
```

Where the `[IP address]` can be seen using the `ip a` command.

To gracefully recover from this, you will likely have to use the wg-quick command to take the connection down, then bring it back up.

# [Rosenpass](https://rosenpass.eu/)

Rosenpass is free and open-source software based on the latest research in the field of cryptography. It is intended to be used with WireGuard VPN, but can work with all software that uses pre-shared keys. It uses two cryptographic methods (Classic McEliece and Kyber) to secure systems against attacks with quantum computers.

- [Source code](https://github.com/rosenpass/rosenpass)
- [Docs](https://rosenpass.eu/docs/)

# Troubleshooting

## [Failed to resolve interface "tun": No such device](https://askubuntu.com/questions/1376573/failed-to-resolve-interface-tun-no-such-device)

```bash
sudo apt purge resolvconf
```

# References

- [Home](https://www.wireguard.com/)
- [Awesome wireguard](https://github.com/cedrickchee/awesome-wireguard)
