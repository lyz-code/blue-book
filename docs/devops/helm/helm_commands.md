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
helm fetch {{ package_name }}
```

Download and extract
```bash
helm fetch --untar {{ package_name }}
```

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
