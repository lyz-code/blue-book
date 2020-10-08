---
title: Kubernetes Dashboard
date: 20200225
author: Lyz
---

!!! quote "[Dashboard definition](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)"
    Dashboard is a web-based Kubernetes user interface. You can use Dashboard to
    deploy containerized applications to a Kubernetes cluster, troubleshoot your
    containerized application, and manage the cluster resources. You can use
    Dashboard to get an overview of applications running on your cluster, as
    well as for creating or modifying individual Kubernetes resources (such as
    Deployments, Jobs, DaemonSets, etc). For example, you can scale
    a Deployment, initiate a rolling update, restart a pod or deploy new
    applications using a deploy wizard.

    Dashboard also provides information on the state of Kubernetes resources in
    your cluster and on any errors that may have occurred.

![ ](kubernetes-dashboard-ui.png)

# Deployment

The best way to install it is with the [stable/kubernetes-dashboard](https://github.com/helm/charts/tree/master/stable/kubernetes-dashboard)
chart with
[helmfile](helmfile.md).

# Links

* [Git](https://github.com/kubernetes/dashboard)
* [Documentation](https://github.com/kubernetes/dashboard/tree/master/docs)
* [Kubernetes introduction to the dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
* [Hasham Haider guide](https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard)
