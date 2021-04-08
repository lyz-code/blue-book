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

# Use HAProxy as a reverse proxy

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

# References

* [Guidelines for HAProxy termination in AWS](https://github.com/jvehent/haproxy-aws)
