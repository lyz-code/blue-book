---
title: Helmfile
date: 20200210
author: Lyz
---

[Helmfile](https://github.com/roboll/helmfile) is a declarative spec for
deploying Helm charts. It lets you:

* Keep a directory of chart value files and maintain changes in version control.
* Apply CI/CD to configuration changes.
* Environmental chart promotion.
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

When we want to add a new chart, the workflow would be:

* Run `helmfile deps && helmfile diff` to check that your existing charts are
  updated, if they are not, run `helmfile apply`.
* Configure the release in `helmfile.yaml` specifying:
  `name`: Deployment name.
  * `namespace`: K8s namespace to deploy.
  * `chart`: Chart release.
  * `values`: path pointing to the values file created above.
* Create a directory with the `{{ chart_name }}`.
  ```bash
  mkdir {{ chart_name }}
  ```
* Get a copy of the chart values inside that directory.
  ```bash
  helm inspect values {{ package_name }} > {{ chart_name }}/values.yaml
  ```
* Edit the `values.yaml` file according to the chart documentation. Be careful
    becase some charts specify the docker image version in the name. Comment out
    that line because upgrading the chart version without upgrading the image
    tag can break the service.
* Run `helmfile deps` to update the lock file.
* Run `helmfile diff` to check the changes.
* Run `helmfile apply` to apply the changes.

## Keep charts updated

Updating charts with `helmfile` is easy as long as you don't use environments,
you run `helmfile deps`, then `helmfile diff` and finally `helmfile apply`. The
tricky business comes when you want to use environments to reuse your helmfile
code and don't repeat yourself.

!!! note ""

    This is my suggested workflow, I've opened [an
    issue](https://github.com/roboll/helmfile/issues/1107) to see if the
    developers agree with it:

As of today, helmfile [doesn't support lock files per
environment](https://github.com/roboll/helmfile/issues/779), that means that the
lock file needs to be shared by all of them. At a first sight this is a good
idea, because it forces us to have the same versions of the charts in all the
environments.

The problem comes when you want to upgrade the charts of staging, test that they
work and then apply the same changes in production. You'd start the process by
running `helmfile deps`, which will read the helmfiles and update the lock file
to the latest version. From this point on you need to be careful on executing
the next steps in order so as not to break production.

* Tell your team that you're going to do the update operation, so that
    they don't try to run `helmfile` against any environment of the cluster.
* Run `helmfile --environment=staging diff` to review the changes to be introduced.

    To be able to see the differences of long diff files, you can filter it with
    `egrep`.

    ```bash
    helmfile diff | egrep -A20 -B20 "^.{5}(\-|\+)"
    ```

    It will show you all the changed lines with the 20 previous and next ones.
* Once you agree on them, run `helmfile --environment=staging apply` to apply
    them.
* Check that all the helm deployments are well deployed with `helm list -A
    | grep -v deployed`
* Wait 20 minutes to see if the monitoring system or your fellow partners start
    yelling at you.
* If something breaks up, try to fix it up, if you see it's going to delay you
    to the point that you're not going to be able to finish the upgrade in your
    working day, it's better to revert back to the working version of that chart and
    move on with the next steps. Keep in mind that since you run the `apply` to
    the last of the steps of this *long* process, the team is blocked by you.
    So prioritize to commit the next stable version to the version control
    repository.
* Once you've checked that all the desired upgrades are working, change the
    context to the production cluster and run `helmfile
    --environment=production diff`. This review should be quick, as it should be
    the same as the *staging* one.
* Now upgrade the production environment with `helmfile --environment=production
    apply`.
* Check that all the helm deployments are well deployed with `helm list -A
    | grep -v deployed`
* Wait another 20 minutes and check that everything is working.
* Make a commit with the new lockfile and upload it to the version control repository.

If you want the team to be involved in the review process, you can open a PR
with the lock file updated with the `WIP` state, and upload the relevant diff of
staging and production, let the discussion end and then run the apply on staging
and then on production if everything goes well.

Another *ugly* solution that I thought was to have a lockfile per environment,
and let a Makefile manage them, for example, copying it to
`helmfile.lock` before running any command.

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

# Multi-environment project structure

`helmfile` can handle environments with many different project structures. Such
as the next one:

```
├── README.md
├── helmfile.yaml
├── vars
│   ├── production_secrets.yaml
│   ├── production_values.yaml
│   ├── default_secrets.yaml
│   └── default_values.yaml
├── charts
│   ├── local_defined_chart_1
│   └── local_defined_chart_2
├── templates
│   ├── environments.yaml
│   └── templates.yaml
├── base
│   ├── README.md
│   ├── helmfile.yaml
│   ├── helmfile.lock
│   ├── repos.yaml
│   ├── chart_1
│   │   ├── secrets.yaml
│   │   ├── values.yaml
│   │   ├── production_secrets.yaml
│   │   ├── production_values.yaml
│   │   ├── default_secrets.yaml
│   │   └── default_values.yaml
│   └── chart_2
│       ├── secrets.yaml
│       ├── values.yaml
│       ├── production_secrets.yaml
│       ├── production_values.yaml
│       ├── default_secrets.yaml
│       └── default_values.yaml
└── service_1
    ├── README.md
    ├── helmfile.yaml
    ├── helmfile.lock
    ├── repos.yaml
    ├── chart_1
    │   ├── secrets.yaml
    │   ├── values.yaml
    │   ├── production_secrets.yaml
    │   ├── production_values.yaml
    │   ├── default_secrets.yaml
    │   └── default_values.yaml
    └── chart_2
        ├── secrets.yaml
        ├── values.yaml
        ├── production_secrets.yaml
        ├── production_values.yaml
        ├── default_secrets.yaml
        └── default_values.yaml
```

Where:

* There is a general `README.md` that introduces the repository.
* Optionally there could be a `helmfile.yaml` file at the root with a [glob
    pattern](https://github.com/roboll/helmfile#glob-patterns) so that it's easy
    to run commands on all children helmfiles.

    ```yaml
    helmfiles:
        - ./*/helmfile.yaml
    ```
* There is a `vars` directory to store the variables and secrets shared by
    the charts that belong to different services.
* There is a `templates` directory to store the helmfile code to reuse through
    [templates](#using-release-templates) and [layering](#layering-the-state).
* The project structure is defined by the services hosted in the Kubernetes
    cluster. Each service contains:

    * A `README.md` to document the service implementation.
    * A `helmfile.yaml` file to configure the service charts.
    * A `helmfile.lock` to lock the versions of the service charts.
    * A `repos.yaml` to define the repositories to fetch the charts from.
    * One or more chart directories that contain the environment specific and
        shared chart values and secrets.

* There is a `base` service that manages all the charts required to keep the
    cluster running, such as the ingress, csi, cni or the cluster-autoscaler.

## [Using helmfile environments](https://github.com/roboll/helmfile#environment)

To customize the contents of a `helmfile.yaml` or `values.yaml` file per
environment, add them under the `environments` key in the `helmfile.yaml`:

```yaml
environments:
  default:
  production:
```

The environment name defaults to `default`, that is, `helmfile sync` implies the
`default` environment. So it's a good idea to use staging as `default` to be
more robust against human errors. If you want to specify a non-default
environment, provide a `--environment NAME` flag to helmfile like `helmfile
--environment production sync`.

In the `environments` definition we'll load the values and secrets from the
`vars` directory with the next snippet.

```yaml
environments:
  default:
    secrets:
      - ../vars/default_secrets.yaml
    values:
      - ../vars/default_values.yaml
  production:
    secrets:
      - ../vars/production_secrets.yaml
    values:
      - ../vars/production_values.yaml
```

As this snippet is going to be repeated on every `helmfile.yaml` we'll use
a [state layering for it](#layering-the-state).

To install a release only in one environment use:

```yaml
environments:
  default:
  production:

---

releases:
- name: newrelic-agent
  installed: {{ eq .Environment.Name "production" | toYaml }}
  # snip
```

### [Using environment specific variables](https://github.com/roboll/helmfile#environment-values)

Environment Values allows you to inject a set of values specific to the selected
environment, into `values.yaml` templates or `helmfile.yaml` files. Use it to
inject common values from the environment to multiple values files, to make your
configuration DRY.

Suppose you have three files helmfile.yaml, production.yaml and values.yaml.gotmpl

!!! note "File: `helmfile.yaml`"
    ```yaml
    environments:
      production:
        values:
          - production.yaml

    ---

    releases:
    - name: myapp
      values:
        - values.yaml.gotmpl
    ```

!!! note "File: `production.yaml`"
    ```yaml
    domain: prod.example.com
    ```

!!! note "File: `values.yaml.gotmpl`"
    ```yaml
    domain: {{ .Values | get "domain" "dev.example.com" }}
    ```

Sadly you [can't use templates in the secrets
files](https://github.com/jkroepke/helm-secrets/issues/126), so you'll need to
repeat the code.

### Loading the chart variables and secrets

For each chart definition in the `helmfile.yaml` we need to load it's secrets
and values. We could use the next snippet:

```yaml
  - name: chart_1
    values:
      - ./chart_1/values.yaml
      - ./chart_1/{{ Environment.Name }}_values.yaml
    secrets:
      - ./chart_1/secrets.yaml
      - ./chart_1/{{ Environment.Name }}_secrets.yaml
```

This assumes that the `environment` variable is set, as it's going to be shared
by all the `helmfiles.yaml` you can add it to the `vars` files:

!!! note "File: `vars/production_values.yaml`"
    ```yaml
    environment: production
    ```

!!! note "File: `vars/default_values.yaml`"
    ```yaml
    environment: staging
    ```

Instead of `.Environment.Name`, in theory you could have used
`.Vars | get "environment"`, which could have prevented the variables and secrets of the default
environment will need to be called `default_values.yaml`, and
`default_secrets.yaml`, which is misleading. But you can't use `.Values` in the
`helmfile.yaml` as it's not loaded when the file is parsed, and you get an
error. A solution would be to [layer the helmfile state
files](https://github.com/roboll/helmfile/blob/8594944f6374454e6ddea61d04b201133798cd95/docs/writing-helmfile.md#layering-state-template-files)
but I wasn't able to make it work.

# Avoiding code repetition

Besides environments, `helmfile` gives other useful tricks to prevent the
illness of code repetition.

## [Using release templates](https://github.com/roboll/helmfile/blob/master/docs/writing-helmfile.md#release-template--conventional-directory-structure)

For each chart in a `helmfile.yaml` we're going to repeat the `values` and
`secrets` sections, to avoid it, we can use release templates:

```yaml
templates:
  default: &default
    # This prevents helmfile exiting when it encounters a missing file
    # Valid values are "Error", "Warn", "Info", "Debug". The default is "Error"
    # Use "Debug" to make missing files errors invisible at the default log level(--log-level=INFO)
    missingFileHandler: Warn
    values:
    - {{`{{ .Release.Name }}`}}/values.yaml
    - {{`{{ .Release.Name }}`}}/{{`{{ .Values | get "environment" }}`}}.yaml
    secrets:
    - config/{{`{{ .Release.Name }}`}}/secrets.yaml
    - config/{{`{{ .Release.Name }}`}}/{{`{{ .Values | get "environment" }}`}}-secrets.yaml

releases:
- name: chart_1
  chart: stable/chart_1
  <<: *default
- name: chart_2
  chart: stable/chart_2
  <<: *default
```

If you're not familiar with YAML anchors, `&default` names the block, then
`*default` references it. The `<<:` syntax says to "extend" (merge) that
reference into the current tree.

The `missingFileHandler: Warn` field is necessary if you don't need all the
values and secret files, but want to use the same definition for all charts.

!!! warning ""
    ``{{` {{ .Release.Name }} `}}`` is surrounded by ``{{` `` and ``}}` `` so as not to be
    executed on the loading time of `helmfile.yaml`. We need to defer it until
    each release is actually processed by the `helmfile` command, such as `diff`
    or `apply`.

For more information see [this
issue](https://github.com/roboll/helmfile/issues/428).

## [Layering the state](https://github.com/roboll/helmfile/blob/master/docs/writing-helmfile.md#layering-state-files)

You may occasionally end up with many helmfiles that shares common parts like
which repositories to use, and which release to be bundled by default.

Use Layering to extract the common parts into a dedicated library helmfiles, so
that each helmfile becomes DRY.

Let's assume that your code looks like:

!!! note "File: `helmfile.yaml`"

    ```yaml
    bases:
    - environments.yaml

    releases:
    - name: metricbeat
      chart: stable/metricbeat
    - name: myapp
      chart: mychart
    ```

!!! note "File: `environments.yaml`"

    ```yaml
    environments:
      development:
      production:
    ```

At run time, `bases` in your `helmfile.yaml` are evaluated to produce:

```yaml
---
# environments.yaml
environments:
  development:
  production:
---
# helmfile.yaml
releases:
- name: myapp
  chart: mychart
- name: metricbeat
  chart: stable/metricbeat
```

Finally the resulting YAML documents are merged in the order of occurrence, so
that your `helmfile.yaml` becomes:

```yaml
environments:
  development:
  production:

releases:
- name: metricbeat
  chart: stable/metricbeat
- name: myapp
  chart: mychart
```

Using this concept, we can reuse the [environments
section](#using-helmfile-environments) as:

!!! note "File: `vars/environments.yaml`"

    ```yaml
    environments:
      default:
        secrets:
          - ../vars/staging-secrets.yaml
        values:
          - ../vars/staging-values.yaml
      production:
        secrets:
          - ../vars/production-secrets.yaml
        values:
          - ../vars/production-values.yaml
    ```

And the [default release templates](#using-release-templates) as:

!!! note "File: `templates/templates.yaml`"
    ```yaml
    templates:
      default: &default
      values:
      - {{`{{ .Release.Name }}`}}/values.yaml
      - {{`{{ .Release.Name }}`}}/{{`{{ .Values | get "environment" }}`}}.yaml
      secrets:
      - config/{{`{{ .Release.Name }}`}}/secrets.yaml
      - config/{{`{{ .Release.Name }}`}}/{{`{{ .Values | get "environment" }}`}}-secrets.yaml
    ```

So the service's `helmfile.yaml` turns out to be:

```yaml
bases:
- ../templates/environments.yaml
- ../templates/templates.yaml

releases:
- name: chart_1
  chart: stable/chart_1
  <<: *default
- name: chart_2
  chart: stable/chart_2
  <<: *default
```

Much shorter and simple.

# Managing dependencies

Helmfile support concurrency with the option `--concurrency=N` so we can take
advantage of it and improve our deployment speed, but to ensure it works as
expected we have to define the dependencies among charts. For example, if an
application needs a database, it has to be deployed before hand.

```yaml
releases:
  - name: vpn-dashboard
    chart: incubator/raw
    needs:
      - monitoring/prometheus-operator
  - name: prometheus-operator
    namespace: monitoring
    chart: prometheus-community/kube-prometheus-stack
```

# Debugging helmfile

## Error: "release-name" has no deployed releases

This may happen when you try to install a chart and it fails. The best solution
until [this issue is resolved](https://github.com/roboll/helmfile/issues/471) is
to use `helm delete --purge {{ release-name }}` and then `apply` again.

## Error: failed to download "stable/metrics-server" (hint: running `helm repo update` may help)

I had this issue if `verify: true` in the helmfile.yaml file. Comment it or set
it to false.

## Cannot patch X field is immutable

You may think that deleting the resource, usually a deployment or daemonset will
fix it, but `helmfile apply` will end without any error, the resource won't be recreated
, and if you do a `helm list`, the deployment will be marked as failed.

The solution we've found is disabling the resource in the chart's values so that
it's uninstalled an install it again.

This can be a problem with the resources that have persistence. To patch it,
edit the volume resource with `kubectl edit pv -n namespace volume_pvc`, change
the `persistentVolumeReclaimPolicy` to `Retain`, apply the changes to uninstall,
and when reinstalling configure the chart to use that volume (easier said than
done).

# Links

* [Git](https://github.com/roboll/helmfile)
