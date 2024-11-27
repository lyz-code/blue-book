---
title: Kubernetes Namespaces
date: 20200302
author: Lyz
---


[Namespaces](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
are virtual clusters backed by the same physical cluster. It's the first level
of isolation between applications.

## When to Use Multiple Namespaces

Namespaces are intended for use in environments with many users spread across
multiple teams, or projects. For clusters with a few to tens of users, you
should not need to create or think about namespaces at all. Start using
namespaces when you need the features they provide.

Namespaces provide a scope for names. Names of resources need to be unique
within a namespace, but not across namespaces.

Namespaces are a way to divide cluster resources between multiple uses (via
resource quota).

It is not necessary to use multiple namespaces just to separate slightly
different resources, such as different versions of the same software: use
labels to distinguish resources within the same namespace.

