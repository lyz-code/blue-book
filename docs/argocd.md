[Argo CD](https://argo-cd.readthedocs.io/en/stable/) is a declarative, GitOps continuous delivery tool for Kubernetes.

Argo CD follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state. Kubernetes manifests can be specified in several ways:

- kustomize applications
- helm charts
- jsonnet files
- Plain directory of YAML/json manifests
- Any custom config management tool configured as a config management plugin, for example with [helmfile](#using-helmfile)

Argo CD automates the deployment of the desired application states in the specified target environments. Application deployments can track updates to branches, tags, or pinned to a specific version of manifests at a Git commit. See tracking strategies for additional details about the different [tracking strategies available](https://argo-cd.readthedocs.io/en/stable/user-guide/tracking_strategies/).

# [Using helmfile](https://github.com/travisghansen/argo-cd-helmfile)

[`helmfile`](helmfile.md) is not yet supported officially, but you can use it through [this plugin](https://github.com/travisghansen/argo-cd-helmfile).


# References

* [Docs](https://argo-cd.readthedocs.io/en/stable/)
