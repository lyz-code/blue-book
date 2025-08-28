[Argo CD](https://argo-cd.readthedocs.io/en/stable/) is a declarative, GitOps continuous delivery tool for Kubernetes.

Argo CD follows the GitOps pattern of using Git repositories as the source of truth for defining the desired application state. Kubernetes manifests can be specified in several ways:

- kustomize applications
- helm charts
- jsonnet files
- Plain directory of YAML/json manifests
- Any custom config management tool configured as a config management plugin, for example with [helmfile](#using-helmfile)

Argo CD automates the deployment of the desired application states in the specified target environments. Application deployments can track updates to branches, tags, or pinned to a specific version of manifests at a Git commit. See tracking strategies for additional details about the different [tracking strategies available](https://argo-cd.readthedocs.io/en/stable/user-guide/tracking_strategies/).

I'm using Argo CD as the GitOps tool, because:

1. It is a CNCF project, so it is a well maintained project.
2. I have positive feedback from other mates that are using it.
3. It is a mature project, so you can expect a good support from the community.

I also took in consideration other tools like
[Flux](https://fluxcd.io/), [spinnaker](https://spinnaker.io/) or
[Jenkins X](https://jenkins-x.io/) before taking this decision.

# Basic concepts

## [Difference between sync and refresh](https://danielms.site/zet/2023/argocd-refresh-v-sync/)

- Sync: Reconciles the current cluster state with the target state in git.
- Refresh: Fetches the latest manifests from git and compares the diff with the live state.
- Hard Refresh: Clears any caches and does a refresh.

For more information read [1](https://argo-cd.readthedocs.io/en/stable/core_concepts/), [2](https://github.com/argoproj/argo-cd/discussions/8260), [3](https://github.com/argoproj/argo-cd/discussions/12237)

# Application configuration

## [Access private git repositories with ssh keys](https://medium.com/@tiwarisan/argocd-how-to-access-private-github-repository-with-ssh-key-new-way-49cc4431971b)

## [Using helmfile](https://github.com/travisghansen/argo-cd-helmfile)

[`helmfile`](helmfile.md) is not yet supported officially, but you can use it through [this plugin](https://github.com/travisghansen/argo-cd-helmfile). Although I wouldn't recommend it.

## [Configure the git webhook to speed up the sync](https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/)

It doesn't still work [for git webhook on Applicationsets for gitea/forgejo](https://github.com/argoproj/argo-cd/issues/18798)

# ArgoCD Operations

## Import already deployed helm

TBD

- https://github.com/argoproj/argo-cd/issues/10168
- https://github.com/argoproj/argo-cd/discussions/8647
- https://github.com/argoproj/argo-cd/issues/2437#issuecomment-542244149

## Migrate from helmfile to argocd

### Migration steps

This section provides a step-by-step guide to migrate an imaginary deployment, it is not real, should be adapted to the real deployment you want to migrate, it tries to be as simpler as posible, there are some tips and tricks later in this document for complex scenarios.

1. **Select a deployment to migrate**
   Once you have decided the deployment to migrate, you have to decide where it belongs to (bootstrap, kube-system, monitoring, applications or is managed by a team).
   Go to the helmfile repository and find the deployment you want to migrate.
2. **Use any of the previous created deployments in the same section as a template**
   Just copy it with the new name, ensure it has all the components you will need:
   - The `Chart.yaml` file will handle the chart repository, version, and, in some cases, the name.
   - The `values.yaml` file will handle the shared values among environments for the deployment.
   - The `values-<env>.yaml` file will handle the environment-specific values.
   - The `secrets.yaml` file will handle the secrets for the deployment (for the current environment).
   - The `templates` folder will handle the Kubernetes resources for the deployment, in helmfile we use the raw chart for this.
3. **Create the `Chart.yaml` file**
   This file is composed by the following fields:

   ```yaml
   apiVersion: v2
   name: kube-system # The name of the deployment
   version: 1.0.0 # The version of the deployment
   dependencies: # The dependencies of the deployment
     - name: ingress-nginx # The name of the chart to deploy
       version: "4.9.1" # The version of the chart to deploy
       repository: "https://kubernetes.github.io/ingress-nginx" # The repository of the chart to deploy
   ```

   You can find the name of the chart in the `helmfile.yaml` file in the helmfile repository, it is under the `chart` key of the release. If it is named something like `ingress-nginx/ingress-nginx` , it is second part of the value, the first part is the local alias for the repository.
   For the version and the repository, the more straightforward way is to go to the `helmfile.lock` within the `helmfile.yaml` and search for its entry. The version is under the `version` key and the repository is under the `repository` key.

4. **Create the `values.yaml` and `values-<env>.yaml` files**
   For the `values.yaml` file, you can copy the `values.yaml` file from the helmfile repository, but it has to be under a key named like the chart name in the `Chart.yaml` file.
   ```yaml
   ingress-nginx:
     controller:
       service:
         annotations:
           service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
   [...]
   ```
   with the migration we have lost the go templating capabilities, so I would recommend to open the new `values.yaml` side by side with the new `values-<env>.yaml` and move the values from the `values.yaml` to the `values-<env>.yaml` when needed and fill the templated values with the real values. It is a pity, we know. Also remember that the `values-<env>.yaml` content needs to be under the same key as the `values.yaml` content.
   ```yaml
   ingress-nginx:
     controller:
       service:
         annotations:
           service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012
   [...]
   ```
   After this you can copy the content of the environment-specific values from the helmfile to the new `values-<env>.yaml` file. Remember to resolve the templated values with the real values.
5. **Create the `secrets.yaml` file**
   The `secrets.yaml` file is a file that contains the secrets for the deployment. You can copy the secrets from the helmfile repository to the `secrets.yaml` file in the Argo CD repository. But you have to do the same as we did in the `values.yaml` and `values-<env>.yaml` files, everything that is to configure the deployment of the chart has to be in a key named like the chart name.
   Just a heads up, the secrets are not shared among environments, so you have to create this file for each environment you have (staging, production, etc.).
6. **Create the `templates` folder**
   If there is any use of the raw chart in the helmfile repository, you have to copy the content of the values file used by the raw chart in a file per resource in the `templates` folder. Remember that the raw chart, requieres to have everything under a key and this is a template so you have to remove that key and unindent the file.
   As a best practice, if there were some variables in the raw chart, you still can use them here, you just have to create the variables in the `values.yaml` or `values-<env>.yaml` files at the top level of the yaml hierarchy, and the templates will be able to use them, This also works for the secrets. This helps a lot to not repeat ourselves. As an example for this you can check the next template:

   ```yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-prod
   spec:
     acme:
       email: your-email@example.org
       server: https://acme-v02.api.letsencrypt.org/directory
       privateKeySecretRef:
         name: letsencrypt-prod
       solvers:
         - selector:
             dnsZones:
               - service-{{.Values.environment}}.example.org
           dns01:
             route53:
               region: us-east-1
   ```

   And this `values-staging.yaml` file:

   ```yaml
   environment: staging
   cert-manager:
     serviceAccount:
       annotations:
         eks.amazonaws.com/role-arn: arn:aws:iam::XXXXXXXXXXXX:role/staging-cert-manager
   ```

7. **Commit your changes**
   Once you have created all the files, you have to commit them to the Argo CD repository. You can use the following commands to commit the changes:
   ```bash
   git add .
   git commit -m "Migrate deployment <my deployment> from Helmfile to Argo CD"
   git push
   ```
8. **Create the PR and wait for the review**
   Once you have committed the changes, you have to create a PR in the Argo CD repository.
   After creating the PR, you have to wait for the review and approval from the team.
9. **Merge the PR and wait for the deployment**
   Once the PR has been approved, you have to merge it and wait for the refresh to be triggered by Argo CD.
   We don't have auto-sync yet, so you have to go to the deployment, manually check the diff and sync the deployment if everything is fine.
10. **Check the deployment**
    Once the deployment has been synced, you have to check the deployment in the Kubernetes cluster to ensure that everything is working as expected.

### Tips and tricks

#### You need to deploy a docker image from a private registry

This is a common scenario, you have to deploy a chart that uses a docker image from a private registry. You have to create a template file with the credentials secret and keep the secret in the `secrets.yaml` file.

`registry-credentials.yaml`:

```yaml
---
apiVersion: v1
data:
  .dockerconfigjson: { { .Values.regcred } }
kind: Secret
metadata:
  name: regcred
  namespace: drawio
type: kubernetes.io/dockerconfigjson
```

`secrets.yaml`:

```yaml
regcred: XXXXX
```

#### You have to deploy multiple charts within the same deployment

As a limitation of our deployment strategy, on some scenarios the name of the namespace is set to the directory name of the deployment, so you have to deploy any chart within the same deployment in the same `namespace/directory`. You can do this by using multiple dependencies in the `Chart.yaml` file. For example if you want an internal docker-registry and also a docker-registry-proxy to avoid the rate limiting of dockerhub you can have:

```yaml
---
apiVersion: v2
name: infra
version: 1.0.0
dependencies:
  - name: docker-registry
    version: 2.2.2
    repository: https://helm.twun.io
    alias: docker-registry
  - name: docker-registry
    version: 2.2.2
    repository: https://helm.twun.io
    alias: docker-registry-proxy
```

values.yaml

```yaml
docker-registry:
  ingress:
    enabled: true
    className: nginx
    path: /
    hosts:
      - registry.example.org
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      cert-manager.io/cluster-issuer: letsencrypt-prod
      cert-manager.io/acme-challenge-type: dns01
    tls:
      - secretName: registry-tls
        hosts:
          - registry.example.org
docker-registry-proxy:
  ingress:
    enabled: true
    className: open-internally
    path: /
    hosts:
      - registry-proxy.example.org
    annotations:
      nginx.ingress.kubernetes.io/proxy-body-size: "0"
      cert-manager.io/cluster-issuer: letsencrypt-prod
      cert-manager.io/acme-challenge-type: dns01
    tls:
      - secretName: registry-proxy-tls
        hosts:
          - registry-proxy.example.org
```

### You need to deploy a chart in an OCI registry

It is pretty straightforward, you just have to keep in mind that the helmfile repository specifies the chart in the url and our ArgoCD definition just needs the repository and the chart name is defined in the name of the dependency. So in helmfile you will find something like this:

```yaml
- name: karpenter
  chart: oci://public.ecr.aws/karpenter/karpenter
  version: v0.32.7
  namespace: kube-system
  values:
    - karpenter/values.yaml.gotmpl
```

And in the ArgoCD repository you will find something like this:

```yaml
dependencies:
  - name: karpenter
    version: v0.32.7
    repository: "oci://public.ecr.aws/karpenter"
```

#### A object is being managed by the deployment and ArgoCD is trying to manage (delete) it

Some deployments create its objects and add its tags to them, so ArgoCD is trying to manage them, but as they are not defined in the ArgoCD repository, it is trying to delete them. You can handle this situation by telling ArgoCD to ignore the object. For example you can exclude the backups management:

```yaml
argo-cd:
  # https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml
  configs:
    # General Argo CD configuration
    ## Ref: https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/argocd-cm.yaml
    cm:
      resource.exclusions: |
        - apiGroups:
          - "*"
          kinds:
          - Backup
          clusters:
          - "*"
```

# [ArgoCD commandline](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

## [Installation ArgoCD commandline](https://argo-cd.readthedocs.io/en/stable/cli_installation/)

```bash
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
install -m 555 argocd-linux-amd64 ~/.local/bin/argocd
rm argocd-linux-amd64
```

## ArgoCD commandline usage

### [Login into the server](https://codefresh.io/learn/argo-cd/argo-cd-cli-commands-and-best-practices/)

The `argocd login` command is the first step in interacting with the Argo CD API. This command allows you to authenticate yourself, setting up a secure connection between your terminal and the Argo CD server. You’ll need to provide your server’s URL and your credentials. There are three different ways to login, I found that the `--core` is the most useful as it will use your kubernetes credentials.

```bash
argocd login your.argocd.url.com --core --name production
```

Be careful thought that you can't set different `argocd context` for different clusters using the `--core` even though [you set the `--kube-context` flag](https://github.com/argoproj/argo-cd/issues/12883). The config file `~/.config/argocd/config` shows that it's using whatever kubernetes context you're using. So be careful that you're applying it in the correct one!

### Set an argocd context

The `argocd context` command is used to manage your Argo CD contexts. A context is a configuration that represents a Kubernetes cluster, user, and namespace. You can use this command to switch Argo CD between different contexts, allowing you to manage multiple Kubernetes namespaces and clusters from a single terminal.

You can see the different contexts with `argocd context`

### Get the list of applications

```bash
argocd app list
```

### Refresh an application

```bash
argocd app get app_name --refresh
```

### Show the diff of an application

```bash
argocd app diff app_name
```

### Sync an application

```bash
argocd app sync app_name
```

# Not there yet

- Python library: I have found none
- Argocd TUI: I have found none that is updated
- [Support git webhook on Applicationsets for gitea/forgejo](https://github.com/argoproj/argo-cd/issues/18798): although you could use an ugly fix adding `spec.generators[i].requeueAfterSeconds` to change the interval that ArgoCD uses to refresh the repositories, which is 3 minutes by default.

# Troubleshooting

## When something is not syncing

If something is not syncing, you can check the logs in the `sync status` button in the Argo CD UI, this will give you a hint of what is happening. For common scenarios you can:

- Delete the failing resource (deployment, configmap, secret) and sync it again. **Never delete a statefulset** as it will delete the data.
- Set some "advanced" options in the sync, like `force`, `prune` or `replace` to force the sync of the objects unwilling to sync.

## You have to deploy the ingress so you will lost the access to the Argocd UI

This is tricky, because ingress is one of theses cases were you have to delete the deployments and sync them again, but once you delete the deployment there is no ingress so no way to access the Argo CD UI. You can handle this situation by at least two ways:

- Set a retry option in the synchronization of the deployment, so you can delete the deployment and the sync will happen again in a few seconds.
- Force a sync using kubectl, instead of the UI. You can do this by running the following command:
  ```bash
  kubectl patch application <yourDeployment> -n argocd --type=merge -p '{"operation": {"initiatedBy": { "username": "<yourUserName>"},"sync": { "syncStrategy": null, "hook": {} }}}'
  ```

# Snippets

## Recursively pull a copy of all helm charts used by an argocd repository

Including the dependencies of the dependencies.

```python
#!/usr/bin/env python3

import argparse
import logging
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Set

import yaml


class HelmChartPuller:
    def __init__(self):
        self.pulled_charts: Set[str] = set()
        self.setup_logging()

    def setup_logging(self):
        logging.basicConfig(
            level=logging.INFO,
            format="[%(asctime)s] %(levelname)s: %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
        )
        self.logger = logging.getLogger(__name__)

    def parse_chart_yaml(self, chart_file: Path) -> Dict:
        """Parse Chart.yaml file and return its contents."""
        try:
            with open(chart_file, "r", encoding="utf-8") as f:
                return yaml.safe_load(f) or {}
        except Exception as e:
            self.logger.error(f"Failed to parse {chart_file}: {e}")
            return {}

    def get_dependencies(self, chart_data: Dict) -> List[Dict]:
        """Extract dependencies from chart data."""
        return chart_data.get("dependencies", [])

    def is_chart_pulled(self, name: str, version: str) -> bool:
        """Check if chart has already been pulled."""
        chart_id = f"{name}-{version}"
        return chart_id in self.pulled_charts

    def mark_chart_pulled(self, name: str, version: str):
        """Mark chart as pulled to avoid duplicates."""
        chart_id = f"{name}-{version}"
        self.pulled_charts.add(chart_id)

    def pull_chart(self, name: str, version: str, repository: str) -> bool:
        """Pull a Helm chart using appropriate method (OCI or traditional)."""
        if self.is_chart_pulled(name, version):
            self.logger.info(f"Chart {name}-{version} already pulled, skipping")
            return True

        self.logger.info(f"Pulling chart: {name} version {version} from {repository}")

        try:
            if repository.startswith("oci://"):
                oci_url = f"{repository}/{name}"
                cmd = ["helm", "pull", oci_url, "--version", version, "--untar"]
            else:
                cmd = [
                    "helm",
                    "pull",
                    name,
                    "--repo",
                    repository,
                    "--version",
                    version,
                    "--untar",
                ]

            result = subprocess.run(cmd, capture_output=True, text=True, check=True)
            self.logger.info(f"Successfully pulled chart: {name}-{version}")
            self.mark_chart_pulled(name, version)
            return True

        except subprocess.CalledProcessError as e:
            self.logger.error(f"Failed to pull chart {name}-{version}: {e.stderr}")
            return False

    def process_chart_dependencies(self, chart_file: Path):
        """Process dependencies from a Chart.yaml file recursively."""
        self.logger.info(f"Processing dependencies from: {chart_file}")

        chart_data = self.parse_chart_yaml(chart_file)
        if not chart_data:
            return

        dependencies = self.get_dependencies(chart_data)
        if not dependencies:
            self.logger.info(f"No dependencies found in {chart_file}")
            return

        for dep in dependencies:
            name = dep.get("name", "")
            version = dep.get("version", "")
            repository = dep.get("repository", "")

            if not all([name, version, repository]):
                self.logger.warning(f"Incomplete dependency in {chart_file}: {dep}")
                continue

            if self.pull_chart(name, version, repository):
                pulled_chart_dir = Path.cwd() / name
                if pulled_chart_dir.is_dir():
                    dep_chart_file = pulled_chart_dir / "Chart.yaml"
                    if dep_chart_file.is_file():
                        self.logger.info(
                            f"Found Chart.yaml in pulled dependency: {dep_chart_file}"
                        )
                        self.process_chart_dependencies(dep_chart_file)

    def find_chart_files(self, search_dir: Path) -> List[Path]:
        """Find all Chart.yaml files in the given directory."""
        self.logger.info(f"Searching for Chart.yaml files in: {search_dir}")
        return list(search_dir.rglob("Chart.yaml"))

    def check_dependencies(self):
        """Check if required dependencies are available."""
        try:
            subprocess.run(["helm", "version"], capture_output=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            self.logger.error("helm command not found. Please install Helm.")
            sys.exit(1)

        try:
            import yaml
        except ImportError:
            self.logger.error(
                "PyYAML module not found. Install with: pip install PyYAML"
            )
            sys.exit(1)

    def run(self, target_dir: str):
        """Main execution method."""
        self.check_dependencies()

        target_path = Path(target_dir)
        if not target_path.is_dir():
            self.logger.error(f"Directory '{target_dir}' does not exist")
            sys.exit(1)

        self.logger.info(f"Starting to process Helm charts in: {target_path}")
        self.logger.info(f"Charts will be pulled to current directory: {Path.cwd()}")

        chart_files = self.find_chart_files(target_path)
        if not chart_files:
            self.logger.info("No Chart.yaml files found")
            return

        for chart_file in chart_files:
            self.logger.info(f"Found Chart.yaml: {chart_file}")
            self.process_chart_dependencies(chart_file)

        self.logger.info(
            f"Completed processing. Total unique charts pulled: {len(self.pulled_charts)}"
        )
        if self.pulled_charts:
            self.logger.info(f"Pulled charts: {', '.join(sorted(self.pulled_charts))}")


def main():
    parser = argparse.ArgumentParser(
        description="Recursively pull Helm charts and their dependencies from Chart.yaml files"
    )
    parser.add_argument("directory", help="Directory to search for Chart.yaml files")

    args = parser.parse_args()

    puller = HelmChartPuller()
    puller.run(args.directory)


if __name__ == "__main__":
    main()
```
# References

- [Docs](https://argo-cd.readthedocs.io/en/stable/)
