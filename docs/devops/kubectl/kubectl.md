---
title: Kubectl
date: 20200302
author: Lyz
---

!!! quote "[Kubectl Definition](https://kubernetes.io/docs/reference/kubectl/overview/)"
    Kubectl is a command line tool for controlling Kubernetes clusters.

    `kubectl` looks for a file named config in the $HOME/.kube directory. You
    can specify other kubeconfig files by setting the KUBECONFIG environment
    variable or by setting the --kubeconfig flag.

# [Resource types and it's aliases](https://kubernetes.io/docs/reference/kubectl/overview/#resource-types)

| Resource Name            | Short Name |
| ---                      | ---        |
| clusters                 |            |
| componentstatuses        | cs         |
| configmaps               | cm         |
| daemonsets               | ds         |
| deployments              | deploy     |
| endpoints                | ep         |
| event                    | ev         |
| horizontalpodautoscalers | hpa        |
| ingresses                | ing        |
| jobs                     |            |
| limitranges              | limits     |
| namespaces               | ns         |
| networkpolicies          | netpol     |
| nodes                    | no         |
| statefulsets             | sts        |
| persistentvolumeclaims   | pvc        |
| persistentvolumes        | pv         |
| pods                     | po         |
| podsecuritypolicies      | psp        |
| podtemplates             |            |
| replicasets              | rs         |
| replicationcontrollers   | rc         |
| resourcequotas           | quota      |
| cronjob                  |            |
| secrets                  |            |
| serviceaccount           | sa         |
| services                 | svc        |
| storageclasses           |            |
| thirdpartyresources      |            |

# Usage

## [Port forward / Tunnel to an internal service](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/)

If you have a service running in kubernetes and you want to directly access it
instead of going through the usual path, you can use `kubectl port-forward`.


`kubectl port-forward` allows using resource name, such as a pod name, service
replica set or deployment, to select the matching resource to port forward to.
For example, the next commands are equivalent:

```bash
kubectl port-forward mongo-75f59d57f4-4nd6q 28015:27017
kubectl port-forward deployment/mongo 28015:27017
kubectl port-forward replicaset/mongo-75f59d57f4 28015:27017
kubectl port-forward service/mongo 28015:27017
```

The output is similar to this:

```bash
Forwarding from 127.0.0.1:28015 -> 27017
Forwarding from [::1]:28015 -> 27017
```

If you don't need a specific local port, you can let `kubectl` choose and
allocate the local port and thus relieve you from having to manage local port
conflicts, with the slightly simpler syntax:

```bash
$: kubectl port-forward deployment/mongo :27017

Forwarding from 127.0.0.1:63753 -> 27017
Forwarding from [::1]:63753 -> 27017
```

## [Run a command against a specific context](https://stackoverflow.com/questions/55938630/how-to-run-a-command-against-a-specific-context-with-kubectl)

If you have multiple contexts and you want to be able to run commands against
a context that you have access to but is not your active context you can use the
`--context` global option for all `kubectl` commands:

```bash
kubectl get pods --context <context_B>
```

To get a list of available contexts use `kubectl config get-contexts`

# Links

* [Overview](https://kubernetes.io/docs/reference/kubectl/overview/).
* [Cheatsheet](https://kubernetes.io/docs/user-guide/kubectl-cheatsheet/).
* [Kbenv](https://github.com/alexppg/kbenv): Virtualenv for kubectl.
