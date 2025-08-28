---
title: Introduction to Kubernetes
date: 20200210
author: Lyz
---

[Kubernetes](https://en.wikipedia.org/wiki/Kubernetes) (commonly stylized as
k8s) is an open-source container-orchestration system for automating application
deployment, scaling, and management. Developed by Google in Go under the Apache
2.0 license, it was first released on June 7, 2014 reaching 1.0 by July 21, 2015. It works with a range of container tools, including Docker. Many cloud
services offer a Kubernetes-based platform or infrastructure as a service
([PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service) or
[IaaS](https://en.wikipedia.org/wiki/Infrastructure_as_a_service)) on which
Kubernetes can be deployed as a platform-providing service. Many vendors also
provide their own branded Kubernetes distributions.

<p align="center">
    <img src="/blue-book/img/kubernetes_logo.png">
</p>

It has become the standard infrastructure to manage containers in production
environments. [Docker Swarm](https://docs.docker.com/engine/swarm/) would be an
alternative but it falls short in features compared with Kubernetes.

These are some of the advantages of using Kubernetes:

- Widely used in production and actively developed.
- Ensure high availability of your services with autohealing and autoscaling.
- Easy, quickly and predictable deployment and promotion of applications.
- Seamless roll out of features.
- Optimize hardware use while guaranteeing resource isolation.
- Easiest way to build multi-cloud and baremetal environments.

Several companies have used Kubernetes to release their own
[PaaS](https://en.wikipedia.org/wiki/Platform_as_a_service):

- [OpenShift](https://en.wikipedia.org/wiki/OpenShift) by Red Hat.
- [Tectonic](https://coreos.com/tectonic/) by CoreOS.
- [Rancher labs](https://en.wikipedia.org/wiki/Rancher_Labs) by Rancher.

# Learn roadmap

K8s is huge, and growing at a pace that most mortals can't stay updated unless
you work with it daily.

This is how I learnt, but probably [there are better resources
now](https://github.com/ramitsurana/awesome-kubernetes#starting-point):

- Read [containing container chaos kubernetes](https://opensource.com/life/16/9/containing-container-chaos-kubernetes).
- Test the [katacoda lab](https://www.katacoda.com/courses/kubernetes).
- Install Kubernetes in laptop with
  [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/).
- Read [K8s concepts](https://kubernetes.io/docs/concepts).
- Then [K8s tasks](https://kubernetes.io/docs/tasks/).
- I didn't like the book [Getting started with kubernetes](https://www.packtpub.com/eu/virtualization-and-cloud/getting-started-kubernetes-third-edition)
- I'd personally avoid the book [Getting started with
  kubernetes](https://www.packtpub.com/eu/virtualization-and-cloud/getting-started-kubernetes-third-edition),
  I didn't like it `¯\(°_o)/¯`.

# [Tools to test](https://filippobuletto.github.io/kubernetes-toolbox/)

- [stakater/reloader](https://github.com/stakater/Reloader): A Kubernetes controller to watch changes in ConfigMap and Secrets and do rolling upgrades on Pods with their associated Deployment, StatefulSet, DaemonSet and DeploymentConfig. Useful for not that clever applications that need a reboot when a configmap changes.
- [Popeye](https://github.com/derailed/popeye) is a utility that scans live
  Kubernetes cluster and reports potential issues with deployed resources and
  configurations. It sanitizes your cluster based on what's deployed and not
  what's sitting on disk. By scanning your cluster, it detects
  misconfigurations and helps you to ensure that best practices are in place,
  thus preventing future headaches. It aims at reducing the cognitive overload
  one faces when operating a Kubernetes cluster in the wild. Furthermore, if
  your cluster employs a metric-server, it reports potential resources
  over/under allocations and attempts to warn you should your cluster run out
  of capacity.

  Popeye is a readonly tool, it does not alter any of your Kubernetes
  resources in any way!

- [Stern](https://github.com/wercker/stern) allows you to tail multiple pods on
  Kubernetes and multiple containers within the pod. Each result is color
  coded for quicker debugging.

  The query is a regular expression so the pod name can easily be filtered and
  you don't need to specify the exact id (for instance omitting the deployment
  id). If a pod is deleted it gets removed from tail and if a new pod is added
  it automatically gets tailed.

  When a pod contains multiple containers Stern can tail all of them too
  without having to do this manually for each one. Simply specify the
  container flag to limit what containers to show. By default all containers
  are listened to.

- [Fairwinds' Polaris](https://github.com/FairwindsOps/polaris) keeps your
  clusters sailing smoothly. It runs a variety of checks to ensure that
  Kubernetes pods and controllers are configured using best practices, helping
  you avoid problems in the future.

- [kube-hunter](https://github.com/aquasecurity/kube-hunter) hunts for security
  weaknesses in Kubernetes clusters. The tool was developed to increase
  awareness and visibility for security issues in Kubernetes environments.
- [IceKube](https://twitter.com/clintgibler/status/1732459956669214784):
  Finding complex attack paths in Kubernetes clusters

  Bloodhound for Kubernetes

  Uses Neo4j to store & analyze Kubernetes resource relationships → identify attack paths & security misconfigs

# Snippets

## Cordon all arm64 nodes

```bash
kubectl get nodes -l kubernetes.io/arch=arm64 -o jsonpath='{.items[*].metadata.name}' | xargs kubectl cordon
```
## Search all the container images in use that match a desired string

```bash
#!/bin/bash

set -e

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

usage() {
  echo "Usage: $0"
  echo "Describes all pods in all namespaces and greps for images containing 'bitnami'"
  exit 1
}

check_dependencies() {
  if ! command -v kubectl >/dev/null 2>&1; then
    log "Error: kubectl command not found"
    exit 1
  fi

  # Test kubectl connectivity
  if ! kubectl cluster-info >/dev/null 2>&1; then
    log "Error: Cannot connect to Kubernetes cluster"
    exit 1
  fi
}

find_bitnami_images() {
  log "Getting all pods from all namespaces..."

  # Get all pods from all namespaces and describe them
  kubectl get pods --all-namespaces -o wide --no-headers | while read -r namespace name ready status restarts age ip node nominated readiness; do
    log "Describing pod: $namespace/$name"

    # Describe the pod and grep for bitnami images
    description=$(kubectl describe pod "$name" -n "$namespace" 2>/dev/null)

    # Look for image lines containing bitnami
    bitnami_images=$(echo "$description" | grep -i "image:" | grep -i "bitnami" || true)

    if [[ -n "$bitnami_images" ]]; then
      echo "========================================="
      echo "Pod: $namespace/$name"
      echo "Status: $status"
      echo "Bitnami Images Found:"
      echo "$bitnami_images"
      echo "========================================="
      echo
    fi
  done
}

main() {
  if [[ $# -ne 0 ]]; then
    usage
  fi

  check_dependencies

  log "Starting search for Bitnami images in all pods across all namespaces"
  find_bitnami_images
  log "Search completed"
}

main "$@"
```

## Force the removal of a node from the cluster

To force the removal of a node from a Kubernetes cluster, you have several options depending on your situation:

To prevent new pods from being scheduled while you prepare:

```bash
# Mark node as unschedulable
kubectl cordon <node-name>
```

### 1. Graceful Node Removal (Recommended)

First, try the standard approach:

```bash
# Drain the node (moves pods to other nodes)
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data

# Remove the node from the cluster
kubectl delete node <node-name>
```

### 2. Force Removal When Node is Unresponsive

If the node is unresponsive or the graceful removal fails:

```bash
# Force drain with additional options
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data --force --grace-period=0

# Delete the node
kubectl delete node <node-name>
```

### 3. Immediate Forced Removal

For emergency situations where you need immediate removal:

```bash
# Skip the drain step entirely and force delete
kubectl delete node <node-name> --force --grace-period=0
```

### Common Drain Options

- `--ignore-daemonsets`: Ignores DaemonSet pods (they'll be recreated anyway)
- `--delete-emptydir-data`: Deletes pods using emptyDir volumes
- `--force`: Forces deletion of pods not managed by controllers
- `--grace-period=0`: Immediately kills pods without waiting
- `--timeout=300s`: Sets timeout for the drain operation

## Move a pvc between AZ in aws

```bash
#!/bin/bash

# This script migrates a PV and its PVC from one AWS AZ to another by creating a snapshot of the volume,
# creating a new volume in the target AZ from the snapshot,
# and rebinding the PVC to the new volume.
# The script assumes that the EBS CSI driver is used for the PVCs.
# The script also cleans up the old PV, volume, and snapshot.
#
# Handle with care, this script deletes resources in the AWS account.
#
# Usage: moveazPV.sh <pv-name> <new-az>
# Example: moveazPV.sh pvc-12345678-1234-1234-1234-123456789012 us-east-2a
#
# You should size to 0 the statefulset before running this script, as this is the safest way to
# ensure that the PVC is not bound to any pod and the data will be consistent.
# If you feel brave enough, the script will prompt you to delete the pod at the precise moment.
#
# Take care and choose an AZ that is not being used by any other PV in the storage cluster.

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <pv-name> <new-az>"
  exit 1
fi

PV_NAME=$1
NEW_AZ=$2

# Get Volume ID from PV
VOLUME_ID=$(kubectl get pv $PV_NAME -o jsonpath='{.spec.csi.volumeHandle}')
if [ -z "$VOLUME_ID" ]; then
  echo "Failed to get volume ID for PV $PV_NAME"
  exit 1
fi

# Get PVC name and namespace
PVC_NAME=$(kubectl get pv $PV_NAME -o jsonpath="{.spec.claimRef.name}")
NAMESPACE=$(kubectl get pv  $PV_NAME -o jsonpath="{.spec.claimRef.namespace}")

echo "PVC Name: $PVC_NAME"
echo "Namespace: $NAMESPACE"

echo "Found volume: $VOLUME_ID"


# Create snapshot
SNAPSHOT_ID=$(aws ec2 create-snapshot --volume-id $VOLUME_ID --description "Migration for $PV_NAME" --query 'SnapshotId' --output text)
echo "Snapshot created: $SNAPSHOT_ID"

# Wait for snapshot to complete
echo "Waiting for snapshot to be ready..."
aws ec2 wait snapshot-completed --snapshot-ids $SNAPSHOT_ID
echo "Snapshot $SNAPSHOT_ID is ready"

# Create new volume in the target AZ
VOLUME_TYPE=$(aws ec2 describe-volumes --volume-ids $VOLUME_ID --query 'Volumes[0].VolumeType' --output text)
NEW_VOLUME_ID=$(aws ec2 create-volume --snapshot-id $SNAPSHOT_ID --availability-zone $NEW_AZ --volume-type $VOLUME_TYPE --query 'VolumeId' --output text)
echo "New volume created: $NEW_VOLUME_ID"

# Wait for the new volume to be available
echo "Waiting for new volume to be available..."
aws ec2 wait volume-available --volume-ids $NEW_VOLUME_ID
echo "New volume $NEW_VOLUME_ID is ready"

# Generate new PV YAML
NEW_PV_NAME=${PV_NAME}-migrated
cat <<EOF > new-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $NEW_PV_NAME
spec:
  capacity:
    storage: $(kubectl get pv $PV_NAME -o jsonpath='{.spec.capacity.storage}')
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: $(kubectl get pv $PV_NAME -o jsonpath='{.spec.storageClassName}')
  csi:
    driver: ebs.csi.aws.com
    volumeHandle: $NEW_VOLUME_ID
    fsType: ext4
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: topology.ebs.csi.aws.com/zone
          operator: In
          values:
          - $NEW_AZ
EOF

echo "New PV manifest generated: new-pv.yaml"

# Apply the new PV
kubectl apply -f new-pv.yaml
echo "New PV $NEW_PV_NAME created"
# Backup old PVC before deleting
kubectl get pvc $PVC_NAME -n $NAMESPACE -o yaml > ${PVC_NAME}-backup.yaml

echo "If you haven't size to 0 the statefulset, it is the time to kill the pod to rebind the PVC"

# Delete old PVC to allow rebinding
kubectl delete pvc $PVC_NAME -n $NAMESPACE
echo "Old PVC deleted"
# Recreate PVC
cat <<EOF > new-pvc.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $PVC_NAME
  namespace: $NAMESPACE
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: $(kubectl get pv $NEW_PV_NAME -o jsonpath='{.spec.capacity.storage}')
  storageClassName: $(kubectl get pv $NEW_PV_NAME -o jsonpath='{.spec.storageClassName}')
  volumeName: $NEW_PV_NAME
EOF

echo "New PVC manifest generated: new-pvc.yaml"

# Apply the new PVC
kubectl apply -f new-pvc.yaml
echo "New PVC $PVC_NAME created and bound to new PV"


# Delete old PV (optional, can be done manually)
kubectl delete pv $PV_NAME || echo "Failed to delete PV $PV_NAME, probably was not retained"
echo "Old PV $PV_NAME deleted"

# Delete old EBS volume
echo "Deleting old volume $VOLUME_ID"
aws ec2 delete-volume --volume-id $VOLUME_ID || echo "Failed to delete volume $VOLUME_ID, probably was not retained"
echo "Old volume deleted"

# Clean up snapshot
echo "Deleting snapshot $SNAPSHOT_ID"
echo aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID
echo "Snapshot deleted"

echo -e "Migration complete.\nNew PV: $NEW_PV_NAME\nNew PVC: $PVC_NAME"
```

# # Optimizing Kubernetes Cluster Node Count: A Strategic Approach

Reducing the number of nodes in a Kubernetes cluster is a critical strategy for controlling cloud infrastructure costs without compromising system reliability. Here are key best practices to help organizations right-size their Kubernetes deployments:

## 1. Availability Zone Consolidation

Carefully evaluate the number of availability zones (AZs) used in your cluster. While multi-AZ deployments provide redundancy, using too many zones can:

- Increase infrastructure complexity
- Raise management overhead
- Unnecessarily distribute resources
- Increase cost without proportional benefit

**Recommendation**: Aim for a balanced approach, typically 3 AZs, which provides robust redundancy while allowing more efficient resource consolidation.

## 2. Intelligent Node Sizing and Management

Implement sophisticated node management strategies:

### Node Provisioning Optimization

- Use tools like Karpenter to dynamically manage node sizing
- Continuously analyze and adjust node types based on actual workload requirements
- Consolidate smaller nodes into fewer, more efficiently sized instances

### Overhead Calculation

Regularly assess system and Kubernetes overhead:

- Calculate total system resource consumption
- Identify underutilized resources
- Understand the overhead percentage for different node types
- Make data-driven decisions about node scaling

## 3. Advanced Pod Autoscaling Techniques

### Horizontal Pod Autoscaling (HPA)

- Implement HPA for workloads with variable load
- Automatically adjust pod count based on CPU/memory utilization
- Ensure efficient resource distribution across existing nodes

### Vertical Pod Autoscaling (VPA)

- Use VPA in recommendation mode initially
- Carefully evaluate automated resource adjustments
- Manually apply recommendations to prevent potential service disruptions

## 4. Workload Optimization Strategies

### High Availability Considerations

- Ensure critical workloads have robust high availability configurations
- Design applications to tolerate node failures gracefully
- Implement pod disruption budgets to maintain service reliability

### Resource Right-Sizing

- Conduct thorough analysis of actual resource utilization
- Avoid over-provisioning by matching resource requests to actual usage
- Use monitoring tools to gain insights into workload characteristics

## 5. Continuous Monitoring and Refinement

- Implement comprehensive monitoring of cluster performance
- Regularly review node utilization metrics
- Create feedback loops for continuous optimization
- Develop scripts or use tools to collect and analyze resource usage data

# References

- [Docs](https://kubernetes.io/docs/)
- [Awesome K8s](https://github.com/ramitsurana/awesome-kubernetes)
- [Katacoda playground](https://www.katacoda.com/courses/kubernetes/playground)
- [Comic](https://cloud.google.com/kubernetes-engine/kubernetes-comic)

## Diving deeper

- [Architecture](kubernetes_architecture.md)
- [Resources](kubernetes_namespaces.md)
- [Kubectl](kubectl.md)
- [Additional Components](kubernetes_namespaces.md)
- [Networking](kubernetes_networking.md)
- [Helm](helm.md)
- [Tools](kubernetes_tools.md)
- [Debugging](kubernetes_debugging.md)

## Reference

- [References](https://kubernetes.io/docs/reference/)
- [API conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/api-conventions.md)
