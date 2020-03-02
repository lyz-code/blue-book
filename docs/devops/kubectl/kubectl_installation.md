---
title: Kubectl Installation
date: 20200302
author: Lyz
---

Kubectl is not yet in the distribution package managers, so we'll need to
install it manually.

```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(\
  curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt\
  )/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl ~/.local/bin/kubectl
```

# Configure kubectl

## Set editor
```bash
# File ~/.bashrc
KUBE_EDITOR="vim"
```

## Set auto completion

```bash
# File ~/.bashrc
source <(kubectl completion bash)
```

## Configure EKS cluster

To configure the access to an existing cluster, we'll let aws-cli create the
required files:

```bash
aws eks update-kubeconfig --name {{ cluster_name }}
```
