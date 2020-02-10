---
title: Helmfile
date: 20200210
author: Lyz
---

[Helmfile](https://github.com/roboll/helmfile) is a declarative spec for
deploying Helm charts. It lets you:

* Keep a directory of chart value files and maintain changes in version control.
* Apply CI/CD to configuration changes.
* Periodically sync to avoid skew in environments.

To avoid upgrades for each iteration of helm, the helmfile executable delegates
to helm - as a result, helm must be installed.

All information is saved in the `helmfile.yaml` file.

In case we need custom yamls, we'll use
[kustomize](https://github.com/kubernetes-sigs/kustomize).

## Deployment

Helmfile is not yet in the distribution package managers, so you'll need to
install it manually.

Gather [the latest release number](https://github.com/roboll/helmfile/releases).

```bash
wget {{ bin_url }} -O helmfile_linux_amd64
chmod +x helmfile_linux_amd64
mv helmfile_linux_amd64 ~/.local/bin/helmfile
```

## Debugging helmfile

### Error: "release-name" has no deployed releases

This may happen when you try to install a chart and it fails. The best solution
until [this issue is resolved](https://github.com/roboll/helmfile/issues/471) is
to use `helm delete --purge {{ release-name }}` and then `apply` again.
