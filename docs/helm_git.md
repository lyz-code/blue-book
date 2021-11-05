---
title: helm-git
date: 20201118
author: Lyz
---

[helm-git](https://github.com/aslafy-z/helm-git) is a helm downloader plugin
that provides GIT protocol support.

This fits the following use cases:

* Need to keep charts private.
* Doesn't want to package charts before installing.
* Charts in a sub-path, or with another ref than master.
* Pull values files directly from (private) Git repository.

# [Installation](https://github.com/aslafy-z/helm-git#install)

```bash
helm plugin install https://github.com/aslafy-z/helm-git --version 0.11.1
```

# [Usage](https://github.com/aslafy-z/helm-git#usage)

`helm-git` will package any chart that is not so you can directly reference
paths to original charts.

Here's the Git urls format, followed by examples:

```
git+https://[provider.com]/[user]/[repo]@[path/to/charts][?[ref=git-ref][&sparse=0][&depupdate=0]]
git+ssh://git@[provider.com]/[user]/[repo]@[path/to/charts][?[ref=git-ref][&sparse=0][&depupdate=0]]
git+file://[path/to/repo]@[path/to/charts][?[ref=git-ref][&sparse=0][&depupdate=0]]

git+https://github.com/jetstack/cert-manager@deploy/charts?ref=v0.6.2&sparse=0
git+ssh://git@github.com/jetstack/cert-manager@deploy/charts?ref=v0.6.2&sparse=1
git+ssh://git@github.com/jetstack/cert-manager@deploy/charts?ref=v0.6.2
git+https://github.com/istio/istio@install/kubernetes/helm?ref=1.5.4&sparse=0&depupdate=0
```

Add your repository:

```bash
helm repo add cert-manager git+https://github.com/jetstack/cert-manager@deploy/charts?ref=v0.6.2
```

You can use it as any other Helm chart repository. Try:

```bash
$ helm search cert-manager
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
cert-manager/cert-manager               v0.6.6          v0.6.2          A Helm chart for cert-manager

$ helm install cert-manager/cert-manager --version "0.6.6"
```

Fetching also works:

```bash
helm fetch cert-manager/cert-manager --version "0.6.6"
helm fetch git+https://github.com/jetstack/cert-manager@deploy/charts/cert-manager-v0.6.2.tgz?ref=v0.6.2
```

# References

* [Git](https://github.com/aslafy-z/helm-git)
