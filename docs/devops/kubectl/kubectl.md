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

# Links

* [Overview](https://kubernetes.io/docs/reference/kubectl/overview/).
* [Cheatsheet](https://kubernetes.io/docs/user-guide/kubectl-cheatsheet/).
* [Kbenv](https://github.com/alexppg/kbenv): Virtualenv for kubectl.
