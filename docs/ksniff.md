---
title: Ksniff
date: 20220307
author: Lyz
---

[Ksniff](https://github.com/eldadru/ksniff) is a Kubectl plugin to ease sniffing
on kubernetes pods using tcpdump and wireshark.

# [Installation](https://github.com/eldadru/ksniff#installation)

Recommended installation is done via [krew](krew.md)

```bash
kubectl krew install sniff
```

For manual installation, download the latest release package, unzip it and use
the attached makefile:

```bash
unzip ksniff.zip
make install
```

(I tried doing it manually and it failed for me).

# [Usage](https://github.com/eldadru/ksniff#usage)

```bash
kubectl sniff <POD_NAME> [-n <NAMESPACE_NAME>] [-c <CONTAINER_NAME>] [-i <INTERFACE_NAME>] [-f <CAPTURE_FILTER>] [-o OUTPUT_FILE] [-l LOCAL_TCPDUMP_FILE] [-r REMOTE_TCPDUMP_FILE]

POD_NAME: Required. the name of the kubernetes pod to start capture it's traffic.
NAMESPACE_NAME: Optional. Namespace name. used to specify the target namespace to operate on.
CONTAINER_NAME: Optional. If omitted, the first container in the pod will be chosen.
INTERFACE_NAME: Optional. Pod Interface to capture from. If omitted, all Pod interfaces will be captured.
CAPTURE_FILTER: Optional. specify a specific tcpdump capture filter. If omitted no filter will be used.
OUTPUT_FILE: Optional. if specified, ksniff will redirect tcpdump output to local file instead of wireshark. Use '-' for stdout.
LOCAL_TCPDUMP_FILE: Optional. if specified, ksniff will use this path as the local path of the static tcpdump binary.
REMOTE_TCPDUMP_FILE: Optional. if specified, ksniff will use the specified path as the remote path to upload static tcpdump to.
```

You'll need to remove the pods manually once you've finished analyzing the
traffic.

# Issues

## [`WTAP_ENCAP = 0`](https://github.com/eldadru/ksniff/issues/138)

Upgrade your [wireshark](wireshark.md) to a version greater or equal to `3.3.0`.

# References

* [Git](https://github.com/eldadru/ksniff)
