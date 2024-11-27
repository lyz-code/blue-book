---
title: Kubernetes annotations
date: 20200302
author: Lyz
---

[Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/)
are non-identifying metadata key/value pairs attached to objects, such as pods.
Annotations are intended to give meaningful and relevant information to
libraries and tools.

Annotations, like labels, are key/value maps:

```yaml
"annotations": {
  "key1" : "value1",
  "key2" : "value2"
}
```

Here are some examples of information that could be recorded in annotations:

* Fields managed by a declarative configuration layer. Attaching these fields
  as annotations distinguishes them from default values set by clients or
  servers, and from auto generated fields and fields set by auto sizing or
  auto scaling systems.
* Build, release, or image information like timestamps, release IDs, git
  branch, PR numbers, image hashes, and registry address.
* Pointers to logging, monitoring, analytics, or audit repositories.
* Client library or tool information that can be used for debugging purposes,
  for example, name, version, and build information.
* User or tool/system provenance information, such as URLs of related objects
  from other ecosystem components.
* Lightweight rollout tool metadata: for example, config or checkpoints.
