[Letsencrypt](https://letsencrypt.org/) is a free, automated, and open certificate authority brought to you by the nonprofit Internet Security Research Group (ISRG). Basically it gives away SSL certificates, which are required to configure webservers to use HTTPS instead of HTTP for example.

# [Configure a wildcard dns when the provider is not supported](https://certbot.eff.org/instructions?ws=nginx&os=pip)

If you’d like to obtain a wildcard certificate from Let’s Encrypt or run certbot on a machine other than your target webserver, you can use one of Certbot’s DNS plugins.

They support [some DNS providers](https://eff-certbot.readthedocs.io/en/stable/using.html#dns-plugins) and a [generic protocol](https://certbot-dns-rfc2136.readthedocs.io/) if your DNS provider is not in the first list and it doesn't either support RFC 2136 you need to set the manual renewal of certificates. Keep in mind though that [Let's Encrypt doesn't support HTTP validation](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) for wildcard domains.

To do so you first need to [install certbot](https://eff-certbot.readthedocs.io/en/stable/install.html). Of the different ways to do it, the cleanest for this case is to use [docker](docker.md) (given that you're already using it and don't mind shutting down your web application service so that let's encrypt docker can bind to ports 80 or 443). I'd prefer not to bring down the service for this purpose. Even if it is just once each 2 months, because I feel that the automation of this process will be more difficult in the end. The option we have left is to install it with `pip` but as we want a clean environment, it's better to use [`pipx`](pipx.md).

```bash
pipx install certbot
```



