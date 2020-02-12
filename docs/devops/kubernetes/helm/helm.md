---
title: Helm
date: 20200210
author: Lyz
---

[Helm](https://helm.sh/) is the package manager for Kubernetes. Through charts
it helps you define, install and upgrade even the most complex Kubernetes
applications.

Charts are a group of Go templates of kubernetes yaml resource manifests, they
are easy to create, version, share, and publish.

Helm alone lacks some features, that are satisfied through some external
programs:

* [Helmfile](helmfile.md) is used to declaratively configure your charts, so
  they can be versioned through git.
* [Helm-secrets](helm_secrets.md) is used to remove hardcoded credentials from `values.yaml`
  files. Helm has an [open issue](https://github.com/helm/helm/issues/2196) to
  integrate it into it's codebase.

# Links

* [Homepage](http://www.helm.sh/)
* [Docs](https://docs.helm.sh)
* [Git](https://github.com/kubernetes/helm)
* [Chart hub](https://hub.helm.sh)
* [Chart indexer](https://kubeapps.com/)
* [Git charts repositories](https://github.com/kubernetes/charts)
