---
title: Helm
date: 20200210
author: Lyz
---

[Helm](https://helm.sh/) is the package manager for Kubernetes. Through charts
it helps you define, install and upgrade even the most complex Kubernetes
applications.

<p align="center">
    <img src="/blue-book/img/helm_logo.png">
</p>

The advantages of using helm over `kubectl apply` are the easiness of:

- Repeatable application installation.
- CI integration.
- Versioning and sharing.

Charts are a group of Go templates of kubernetes yaml resource manifests, they
are easy to create, version, share, and publish.

Helm alone lacks some features, that are satisfied through some external
programs:

- [Helmfile](helmfile.md) is used to declaratively configure your charts, so
  they can be versioned through git.
- [Helm-secrets](helm_secrets.md) is used to remove hardcoded credentials from `values.yaml`
  files. Helm has an [open issue](https://github.com/helm/helm/issues/2196) to
  integrate it into it's codebase.
- [Helm-git](helm_git.md) is used to install helm charts directly from Git
  repositories.

# Usage

## Download a chart 

If the chart is using an `oci` url:
```bash
helm pull oci://registry-1.docker.io/bitnamicharts/postgresql --version 8.10.X --untar -d postgres8
```

If it's using an `https` url:

```bash
helm pull cost-analyzer --repo https://kubecost.github.io/cost-analyzer/ --version 2.7.2
```

## Get the values of a chart

```bash
helm show values zammad --repo https://zammad.github.io/zammad-helm --version 14.0.1
```

# Troubleshooting

## [UPGRADE FAILED: another operation (install/upgrade/rollback) is in progress](https://stackoverflow.com/questions/71599858/upgrade-failed-another-operation-install-upgrade-rollback-is-in-progress)

This error can happen for few reasons, but it most commonly occurs when there is an interruption during the upgrade/install process as you already mentioned.

To fix this one may need to, first rollback to another version, then reinstall or helm upgrade again.

Try below command to list the available charts:

```bash
helm ls --namespace <namespace>
```

You may note that when running that command ,it may not show any columns with information. If that's the case try to check the history of the previous deployment

```bash
helm history <release> --namespace <namespace>
```

This provides with information mostly like the original installation was never completed successfully and is pending state something like STATUS: `pending-upgrade` state.

To escape from this state, use the rollback command:

```bash
helm rollback <release> <revision> --namespace <namespace>
```

`revision` is optional, but you should try to provide it.

You may then try to issue your original command again to upgrade or reinstall.

# Links

- [Homepage](http://www.helm.sh/)
- [Docs](https://docs.helm.sh)
- [Git](https://github.com/kubernetes/helm)
- [Chart hub](https://hub.helm.sh)
- [Git charts repositories](https://github.com/kubernetes/charts)
