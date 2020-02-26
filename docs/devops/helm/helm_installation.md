---
title: Helm Installation
date: 20200210
author: Lyz
---

There are two usable versions of Helm, v2 and v3, the latter is quite new so
some of the things we need to install as of 2020-01-27 are not yet supported
(Prometheus operator), so we are going to stick to the version 2.

Helm has a client-server architecture, the server is installed in the Kubernetes
cluster and the client is a Go executable installed in the user computer.

# Helm client

You'll first need to configure kubectl.

The binary is still not available in the distribution package managers, so check the
latest version in [the releases of their git
repository](https://github.com/kubernetes/helm/releases), and get the download
link of the `tar.gz`.

```bash
wget {{ url_to_tar_gz }} -O helm.tar.gz
tar -xvf helm.tar.gz
mv linux-amd64/helm ~/.local/bin/
```

We are going to use some plugins inside [Helmfile](helmfile.md), so
install them with:

```bash
helm plugin install https://github.com/futuresimple/helm-secrets
helm plugin install https://github.com/databus23/helm-diff
```

Finally initialize the environment

```bash
helm init
```

Now that you've got Helm installed, you'll probably want to install
[Helmfile](helmfile.md).
