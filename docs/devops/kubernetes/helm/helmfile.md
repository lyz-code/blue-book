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

# Installation

Helmfile is not yet in the distribution package managers, so you'll need to
install it manually.

Gather [the latest release number](https://github.com/roboll/helmfile/releases).

```bash
wget {{ bin_url }} -O helmfile_linux_amd64
chmod +x helmfile_linux_amd64
mv helmfile_linux_amd64 ~/.local/bin/helmfile
```

# Usage

## How to deploy a new chart

* Create a directory with the `{{ chart_name }}`
  ```bash
  mkdir {{ chart_name }}
  ```
* Get a copy of the chart values inside that directory
  ```bash
  helm inspect values {{ package_name }} > {{ chart_name }}/values.yaml
  ```
* Edit the `values.yaml` file according to the chart documentation
* Execute the changes
  ```bash
  helmfile apply
  ```

## Keep charts updated

[TBD](https://github.com/roboll/helmfile/issues/1107)

## Uninstall charts

Helmfile still doesn't [remove charts](https://github.com/roboll/helmfile/issues/194)
if you remove them from your `helmfile.yaml`. To remove them you have to either
set `installed: false` in the release candidate and execute `helmfile apply` or
delete the release definition from your helmfile and remove it using standard
[helm](helm.md) commands.

## Force the reinstallation of everything

If you manually changed the deployed resources and want to reset the cluster
state to the helmfile one, use `helmfile sync` which will reinstall all the
releases.

# Debugging helmfile

## Error: "release-name" has no deployed releases

This may happen when you try to install a chart and it fails. The best solution
until [this issue is resolved](https://github.com/roboll/helmfile/issues/471) is
to use `helm delete --purge {{ release-name }}` and then `apply` again.

## Error: failed to download "stable/metrics-server" (hint: running `helm repo update` may help)

I had this issue if `verify: true` in the helmfile.yaml file. Comment it or set
it to false.

# Links

* [Git](https://github.com/roboll/helmfile)
