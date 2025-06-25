---
title: Kubernetes Debugging
date: 20220307
author: Lyz
---

# PVC or PV is stuck deleting

When PVs and PVCs get stuck during deletion, it's usually due to finalizers that prevent the cleanup process from completing. Here are several approaches to resolve this:

## Check for Finalizers

First, examine what's preventing the deletion:

```bash
kubectl get pv <pv-name> -o yaml | grep finalizers -A 5
kubectl get pvc <pvc-name> -n <namespace> -o yaml | grep finalizers -A 5
```

## Remove Finalizers (Most Common Solution)

If you see finalizers like `kubernetes.io/pv-protection` or `kubernetes.io/pvc-protection`, you can remove them:

```bash
# For PVC
kubectl patch pvc <pvc-name> -n <namespace> -p '{"metadata":{"finalizers":null}}'

# For PV
kubectl patch pv <pv-name> -p '{"metadata":{"finalizers":null}}'
```

# Network debugging

NOTE: maybe [kubeshark](https://github.com/kubeshark/kubeshark) is a better solution

Sometimes you need to monitor the network traffic that goes between pods to
solve an issue. There are different ways to see it:

- [Using Mizu](mizu.md)
- [Running tcpdump against a running container](#running-tcpdump-against-a-running-container)
- [Using ksniff](ksniff.md)
- [Using ephemeral debug containers](#using-ephemeral-debug-containers)

Of all the solutions, the cleaner and easier is to use [Mizu](mizu.md).

## [Running tcpdump against a running container](https://dev.to/downey/capturing-network-traffic-from-a-kubernetes-pod-with-ephemeral-debug-containers-57md)

If the pod you want to analyze has root permissions (bad idea) you'll be able to
install `tcpdump` (`apt-get install tcpdump`) and pipe it into `wireshark` on
your local machine.

```bash
kubectl exec my-app-pod -- tcpdump -i eth0 -w - | wireshark -k -i -
```

There's some issues with this, though:

- You have to `kubectl exec` and install arbitrary software from the internet on
  a running Pod. This is fine for internet-connected dev environments, but
  probably not something you'd want to do (or be able to do) in production.
- If this app had been using a minimal `distroless` base image or was built with
  a `buildpack` you won't be able to install `tcpdump`.

## [Using ephemeral debug containers](https://dev.to/downey/capturing-network-traffic-from-a-kubernetes-pod-with-ephemeral-debug-containers-57md)

Kubernetes 1.16 has a new Ephemeral Containers feature that is perfect for our
use case. With Ephemeral Containers, we can ask for a new temporary container
with the image of our choosing to run inside an existing Pod. This means we can
keep the main images for our applications lightweight and then bolt on a heavy
image with all of our favorite debug tools when necessary.

```bash
kubectl debug -it pod-to-debug-id --image=nicolaka/netshoot --target=pod-to-debug -- tcpdump -i eth0 -w - | wireshark -k -i
```

Where `nicolaka/netshoot` is an optimized network troubleshooting docker.

There's some issues with this too, for example, as of Kubernetes 1.21 Ephemeral
containers are not enabled by default, so chances are you won't have access to
them yet in your environment.
