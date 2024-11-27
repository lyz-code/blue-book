[koel](https://koel.dev/) is a personal music streaming server.

Note: Use [`mopidy`](mopidy.md) instead

# Installation

There are [docker-compose files](https://github.com/koel/docker) to host the service. Although they behave a little bit weird

For example, you need to [specify the DB_PORT](https://github.com/koel/docker/issues/168). It has had several PR to fix it but weren't merged [1](https://github.com/koel/docker/pull/165/files), [2](https://github.com/koel/docker/pull/162/files).

# API

The API is [not very well documented](https://github.com/koel/koel/issues/535):

- [Here you can see how to authenticate](https://github.com/X-Ryl669/kutr/wiki/Communication-API#authentication)
- [Here are the api docs](https://github.com/koel/koel/blob/master/api-docs/api.yaml#L763)

# References

- [Home](https://koel.dev/)
- [Docs](https://docs.koel.dev/#using-docker)
- [Source](https://github.com/koel/koel)
