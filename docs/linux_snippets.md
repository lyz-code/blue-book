---
title: Linux snippets
date: 20200826
author: Lyz
---

# Bypass client SSL certificate with cli tool

Websites that require clients to authorize with an TLS certificate are difficult
to interact with through command line tools that don't support this feature.

To solve it, we can use a transparent proxy that does the exchange for us.

* Export your certificate: If you have a `p12` certificate, you first need to
    extract the key, crt and the ca from the certificate into the `site.pem`.

    ```bash
    openssl pkcs12 -in certificate.p12 -out site.key.pem -nocerts -nodes # It asks for the p12 password
    openssl pkcs12 -in certificate.p12 -out site.crt.pem -clcerts -nokeys
    openssl pkcs12 -cacerts -nokeys -in certificate.p12 -out site-ca-cert.ca

    cat site.key.pem site.crt.pem site-ca-cert.ca > site.pem
    ```

* Build the proxy ca: Then we merge the site and the client ca's into the
    `site-ca-file.cert` file:

    ```bash
    openssl s_client -connect www.site.org:443 2>/dev/null  | openssl x509 -text > site-ca-file.cert
    cat site-ca-cert.ca >> web-ca-file.cert
    ```
* Change your hosts file to redirect all requests to the proxy.

    ```vim
    # vim /etc/hosts
    [...]
    0.0.0.0 www.site.org
    ```

* Run the proxy
    ```bash
    docker run --rm \
        -v $(pwd):/certs/ \
        -p 3001:3001 \
        -it ghostunnel/ghostunnel \
            client \
            --listen 0.0.0.0:3001 \
            --target www.site.org:443 \
            --keystore /certs/site.pem \
            --cacert /certs/site-ca-file.cert \
            --unsafe-listen
    ```

* Run the command line tool using the http protocol on the port 3001:

    ```bash
    wpscan  --url http://www.site.org:3001/ --disable-tls-checks
    ```

Remember to clean up your env afterwards.

# [Allocate space for a virtual filesystem](https://askubuntu.com/questions/506910/creating-a-large-size-file-in-less-time)

```bash
fallocate -l 20G /path/to/file
```

# [Identify what a string or file contains](https://github.com/bee-san/pyWhat)

Identify anything. `pyWhat` easily lets you identify emails, IP addresses, and
more. Feed it a .pcap file or some text and it'll tell you what it is.

# [Split a file into many with equal number of lines](https://stackoverflow.com/questions/2016894/how-to-split-a-large-text-file-into-smaller-files-with-equal-number-of-lines)

You could do something like this:

```bash
split -l 200000 filename
```

Which will create files each with 200000 lines named `xaa`, `xab`, `xac`, ...

# Check if an rsync command has gone well

Sometimes after you do an `rsync` between two directories of different devices
(an usb and your hard drive for example), the sizes of the directories don't
match. I've seen a difference of a 30% less on the destination. `du`, `ncdu` and
`and` have a long story of reporting wrong sizes with advanced filesystems (ZFS,
VxFS or compressing filesystems), these do a lot of things to reduce the disk
usage (deduplication, compression, extents, files with holes...) which may lead
to the difference in space.

To check if everything went alright run `diff -r --brief source/ dest/`, and
check that there is no output.

# [List all process swap usage](https://www.cyberciti.biz/faq/linux-which-process-is-using-swap/)

```bash
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r | less
```
