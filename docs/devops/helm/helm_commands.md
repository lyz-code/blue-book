---
Title: Commands for helm
Author: Lyz
Date: 20170406
---

Small cheatsheet on how to use the `helm` command.

# List charts

```bash
helm ls
```

# Get information of chart

```bash
helm inspect {{ package_name }}
```

# List all the available versions of a chart

```bash
helm search -l {{ package_name }}
```

# Download a chart

```bash
helm pull {{ package_name }}
```

Download and extract

```bash
helm pull --untar {{ package_name }}
```

If you want to pull it from an http repository you can use:

```bash
helm pull cost-analyzer --repo https://kubecost.github.io/cost-analyzer/ --version 2.7.2
```

However if it's an `oci` one you need to use the next syntax:

```bash
helm pull oci://public.ecr.aws/karpenter/karpenter --version 1.5.0
```

Which has the format `oci://{repository}/{chart_name}`.

# Search charts

```bash
helm search {{ package_name }}
```

# Operations you should do with helmfile

The following operations can be done with helm, but consider using
[helmfile](helmfile.md) instead.

## Install chart

Helm deploys all the pods, replication controllers and services. The pod will be
in a pending state while the Docker Image is downloaded and until a Persistent
Volume is available. Once complete it will transition into a running state.

```bash
helm install {{ package_name }}
```

### Give it a name

```bash
helm install --name {{ release_name }} {{ package_name }}
```

### Give it a namespace

```bash
helm install --namespace {{ namespace }} {{ package_name }}
```

### Customize the chart before installing

```bash
helm inspect values {{ package_name }} > values.yml
```

Edit the `values.yml`

```bash
helm install -f values.yml {{ package_name }}
```

## Upgrade a release

If a new version of the chart is released or you want to change the
configuration use

```bash
helm upgrade -f {{ config_file }} {{ release_name }} {{ package_name }}
```

### Rollback an upgrade

First check the revisions

```bash
helm history {{ release_name }}
```

Then rollback

```bash
helm rollback {{ release_name }} {{ revision }}
```

## Delete a release

```bash
helm delete --purge {{ release_name }}
```

## Working with repositories

### List repositories

```bash
helm repo list
```

### Add repository

```bash
helm repo add {{ repo_name }} {{ repo_url }}
```

### Update repositories

```bash
helm repo update
```
