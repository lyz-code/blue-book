---
title: HAProxy
date: 20201029
author: Lyz
---

[HAProxy](https://en.wikipedia.org/wiki/HAProxy) is free, open source software
that provides a high availability load balancer and proxy server for TCP and
HTTP-based applications that spreads requests across multiple servers. It is
written in C and has a reputation for being fast and efficient (in terms of
processor and memory usage).


# Installation

## Automatically ban offending traffic
Check these two posts:

- https://serverfault.com/questions/853806/blocking-ips-in-haproxy
- https://www.loadbalancer.org/blog/simple-denial-of-service-dos-attack-mitigation-using-haproxy-2/
## [Configure haproxy logs to be sent to loki](https://www.chrisk.de/blog/2023/06/haproxy-syslog-promtail-loki-grafana-logfmt/)

In the `fronted` config add the next line:

```
  # For more options look at https://www.chrisk.de/blog/2023/06/haproxy-syslog-promtail-loki-grafana-logfmt/
  log-format 'client_ip=%ci client_port=%cp frontend_name=%f backend_name=%b server_name=%s performance_metrics=%TR/%Tw/%Tc/%Tr/%Ta status_code=%ST bytes_read=%B termination_state=%tsc haproxy_metrics=%ac/%fc/%bc/%sc/%rc srv_queue=%sq  backend_queue=%bq user_agent=%{+Q}[capture.req.hdr(0)] http_hostname=%{+Q}[capture.req.hdr(1)] http_version=%HV http_method=%HM http_request_uri="%HU"'
```

At the bottom of [chrisk post](https://www.chrisk.de/blog/2023/06/haproxy-syslog-promtail-loki-grafana-logfmt/) is a table with all the available fields.

[Programming VIP also has an interesting post](https://programming.vip/docs/loki-configures-the-collection-of-haproxy-logs.html).

## Use HAProxy as a reverse proxy

[reverse proxy](https://en.wikipedia.org/wiki/Reverse_proxy) is a type of proxy
server that retrieves resources on behalf of a client from one or more servers.
These resources are then returned to the client, appearing as if they originated
from the server itself. Unlike a forward proxy, which is an intermediary for
its associated clients to contact any server, a reverse proxy is an intermediary
for its associated servers to be contacted by any client. In other words,
a proxy is associated with the client(s), while a reverse proxy is associated
with the server(s); a reverse proxy is usually an internal-facing proxy used as
a 'front-end' to control and protect access to a server on a private network.

It can be done at Web server level (Nginx, Apache, ...) or at load balancer
level.

[This HAProxy
post](https://www.haproxy.com/blog/howto-write-apache-proxypass-rules-in-haproxy/)
shows how to translate Apache's proxy pass directives to the HAProxy
configuration.

```
    frontend ft_global
     acl host_dom.com    req.hdr(Host) dom.com
     acl path_mirror_foo path -m beg   /mirror/foo/
     use_backend bk_myapp if host_dom.com path_mirror_foo
    backend bk_myapp
    [...]
    # external URL                  => internal URL
    # http://dom.com/mirror/foo/bar => http://bk.dom.com/bar
     # ProxyPass /mirror/foo/ http://bk.dom.com/bar
     http-request set-header Host bk.dom.com
     reqirep  ^([^ :]*)\ /mirror/foo/(.*)     \1\ /\2
     # ProxyPassReverse /mirror/foo/ http://bk.dom.com/bar
     # Note: we turn the urls into absolute in the mean time
     acl hdr_location res.hdr(Location) -m found
     rspirep ^Location:\ (https?://bk.dom.com(:[0-9]+)?)?(/.*) Location:\ /mirror/foo3 if hdr_location
     # ProxyPassReverseCookieDomain bk.dom.com dom.com
     acl hdr_set_cookie_dom res.hdr(Set-cookie) -m sub Domain= bk.dom.com
     rspirep ^(Set-Cookie:.*)\ Domain=bk.dom.com(.*) \1\ Domain=dom.com\2 if hdr_set_cookie_dom
     # ProxyPassReverseCookieDomain / /mirror/foo/
     acl hdr_set_cookie_path res.hdr(Set-cookie) -m sub Path=
     rspirep ^(Set-Cookie:.*)\ Path=(.*) \1\ Path=/mirror/foo2 if hdr_set_cookie_path
```

Other useful examples can be retrieved from [drmalex07
](https://gist.github.com/drmalex07/10d09c299245e3ab333c) or
[ferdinandosimonetti](https://gist.github.com/ferdinandosimonetti/23d0d9e468314a85d803bf5e2576be4d)
gists.
# Usage

## Reload haproxy
- Check the config is alright
  ```bash 
  
  service haproxy configtest
  # Or
  /usr/sbin/haproxy -c -V -f /etc/haproxy/haproxy.cfg
  ```
- Reload the service
  ```bash 
  service haproxy reload
  ```

If you want to do a better reload you can [drop the SYN before a restart](https://serverfault.com/questions/580595/haproxy-graceful-reload-with-zero-packet-loss), so that clients will
resend this SYN until it reaches the new process.

```bash
iptables -I INPUT -p tcp --dport 80,443 --syn -j DROP
sleep 1
service haproxy reload
iptables -D INPUT -p tcp --dport 80,443 --syn -j DROP
service haproxy reload
```

# [Comparison between haproxy and varnish](http://blog.haproxy.com/2012/07/04/haproxy-and-varnish-comparison/)

In the opensource world, there are some very smart products which are very
often used to build a high performance, reliable and scalable
architecture.\
**HAProxy** and **Varnish** are both in this category.

Since we can’t really compare a reverse-proxy cache and a reverse-proxy
load-balancer, I’m just going to focus in common for both software as
well as the advantage of each of them.\
The list is not exhaustive, but must only focus on most used /
interesting features. So feel free to add a comment if you want me to
complete the list.

## Common points between HAProxy and Varnish

Before comparing the differences, we can summarize the points in common:
* Reverse-proxy mode
* Advanced HTTP features
* No SSL offloading
* Client-side HTTP 1.1 with keepalive
* Tunnel mode available
* High performance
* Basic load-balancing
* Server health checking
* IPv6 ready
* Management socket (CLI)
* Professional services and training available

## Features available in HAProxy and not in Varnish

The features below are available in **HAProxy**, but aren’t in
**Varnish**:
* Advanced load-balancer
* Multiple persistence methods
* DOS and DDOS mitigation
* advanced and custom logging
* web interface
* server / application protection through queue management, slow
  start, etc…
* sNI content switching
* Named ACLs
* Full HTTP 1.1 support on server side, but keep-alive
* Can work at TCP level with any L7 protocol
* Proxy protocol for both client and server
* Powerful log analyzer tool (halog)
* &lt;private joke&gt; 2002 website design &lt;/private joke&gt;

## Features available in Varnish and not in HAProxy

The features below are available in **Varnish**, but aren’t in
**HAProxy**:
* Caching
* Grace mode (stale content delivery)
* Saint mode (manages origin server errors)
* Modular software (with a lot of modules available)
* Intuitive VCL configuration language
* HTTP 1.1 on server side
* TCP connection re-use
* Edge side includes (ESI)
* A few command line tools for stats (varnishstat, varnishhist, etc…)
* Powerful live traffic analyzer (varnishlog)
* &lt;private joke&gt; 2012 website design &lt;/private joke&gt;

## Conclusion

Even if **HAProxy** can do TCP proxying, it is often used in front of
web application, exactly where we find **Varnish** :).\
They complete very well together: **Varnish** will make the website
faster by offloading static object delivery to itself, while **HAProxy**
can ensure a smooth load-balancing with smart persistence and DDOS
mitigation.
Basically, **HAProxy** and **Varnish** completes very well, despite
being “competitors” on a few features, each on them has its own domain
of expertise where it performs very well: **HAProxy is a reverse-proxy
Load-Balancer** and **Varnish is a Reverse-proxy cache**.

To be honest, when, at HAProxy Technologies, we work on infrastructures
where [Aloha Load
balancer](http://www.haproxy.com/en/aloha-load-balancer-appliance-rack-1u "Aloha load-balancer")
or **HAProxy** is deployed, we often see **Varnish** deployed. And if it
is not the case, we often recommend the customer to deploy one if we
feel it would improve its website performance.\
Recently, I had a discussion with
[Ruben](https://twitter.com/#!/ruben_varnish "ruben_varnish") and
[Kristian](https://twitter.com/#!/kristianlyng "kristian") when they
came to Paris and they told me that they also often see an **HAProxy**
when they work on infrastructure where **Varnish** is deployed.

So the real question is: **Since Varnish and HAProxy are a bit similar
but complete so well, how can we use them together???**\
The response could be very long, so stay tuned, I’ll try to answer this
question in an article coming soon.

# Update letsencrypt certificates with zero downtime

https://github.com/janeczku/haproxy-acme-validation-plugin

# References

* [Homepage](http://www.haproxy.com/ "HAProxy Technologies")
* [Aloha load balancer: HAProxy based LB appliance](http://www.haproxy.com/en/aloha-load-balancer-appliance-rack-1u "Aloha load balancer")
* [HAPEE: HAProxy Enterprise Edition](http://www.haproxy.com/en/haproxy-enterprise-edition-hapee "HAPEE: HAProxy Enterprise Edition")
* [Guidelines for HAProxy termination in AWS](https://github.com/jvehent/haproxy-aws)
