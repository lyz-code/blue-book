---
title: Kubectl Commands
date: 20200302
author: Lyz
---

# Configuration and context

## Add a new cluster to your kubeconf that supports basic auth

```bash
kubectl config set-credentials {{ username }}/{{ cluster_dns }} --username={{ username }} --password={{ password }}
```

## Create new context

```bash
kubectl config set-context {{ context_name }} --user={{ username }} --namespace={{ namespace }}
```

## Get current context

```bash
kubectl config current-context
```

## List contexts

```bash
kubectl config get-contexts
```

## Switch context

```bash
kubectl config use-context {{ context_name }}
```

# Creating objects

## Create Resource

```bash
kubectl create -f {{ resource.definition.yaml | dir.where.yamls.live | url.to.yaml }} --record
```

## [Create a configmap from a file](https://phoenixnap.com/kb/kubernetes-configmap-create-and-use)

```bash
kubectl create configmap {{ configmap_name }} --from-file {{ path/to/file }}
```

# Deleting resources

## Delete the pod using the type and name specified in a file

```bash
kubectl delete -f {{ path_to_file }}
```

## Delete pods and services by name

```bash
kubectl delete pod,service {{ pod_names }} {{ service_names }}
```

## Delete pods and services by label

```bash
kubectl delete pod,services -l {{ label_name }}={{ label_value }}
```

## Delete all pods and services in namespace

```bash
kubectl -n {{ namespace_name }} delete po,svc --all
```

## Delete all evicted pods

```bash
while read i; do kubectl delete pod "$i"; done < <(kubectl get pods | grep -i evicted | sed 's/ .*//g')
```
# Editing resources

## Edit a service

```bash
kubectl edit svc/{{ service_name }}
```

# Information gathering

## Get credentials

Get credentials
```bash
kubectl config view --minify
```

## Deployments

### [Restart pods without taking the service down](https://pet2cattle.com/2021/03/kubectl-rolling-pod-restart)

```bash
kubectl rollout deployment {{ deployment_name }}
```

### View status of deployments

```bash
kubectl get deployments
```

### Describe Deployments

```bash
kubectl describe deployment {{ deployment_name }}
```

### Get images of deployment

```bash
kubectl get pods --selector=app={{ deployment_name }} -o json |\
jq '.items[] | .metadata.name + ": " + .spec.containers[0].image'
```

## Nodes

### List all nodes

```bash
kubectl get nodes
```

### Check which nodes are ready

```bash
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}' \
&& kubectl get nodes -o jsonpath=$JSONPATH | grep "Ready=True"
```

### External IPs of all nodes

```bash
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
```

### Get exposed ports of node

```bash
export NODE_PORT=$(kubectl get services/kubernetes-bootcamp -o go-template='{{(index .spec.ports 0).nodePort}}')
```

## Pods

### List all pods in the current namespace

```bash
kubectl get pods
```

### List all pods in all namespaces

```bash
kubectl get pods --all-namespaces
```

### List all pods of a selected namespace

```bash
kubectl get pods -n {{ namespace }}
```

### List with more detail

```bash
kubectl get pods -o wide
```

### Get pods of a selected deployment

```bash
kubectl get pods --selector="name={{ name }}"
```

### Get pods of a given label

```bash
kubectl get pods -l {{ label_name }}
```

### [Get pods by IP](https://stackoverflow.com/questions/41563021/how-do-you-get-a-kubernetes-pods-name-from-its-ip-address)

```bash
kubectl get pods -o wide
NAME                               READY     STATUS    RESTARTS   AGE       IP            NODE
alpine-3835730047-ggn2v            1/1       Running   0          5d        10.22.19.69   ip-10-35-80-221.ec2.internal
```

### Sort pods by restart count

```bash
kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'
```

### Describe Pods

```bash
kubectl describe pods {{ pod_name }}
```

### Get name of pod

```bash
pod=$(kubectl get pod --selector={{ selector_label }}={{ selector_value }} -o jsonpath={.items..metadata.name})
```

### List pods that belong to a particular RC

```bash
sel=${$(kubectl get rc my-rc --output=json | jq -j '.spec.selector | to_entries | .[] | "\(.key)=\(.value),"')%?}
echo $(kubectl get pods --selector=$sel --output=jsonpath={.items..metadata.name})
```

## Services

### List services in namespace

```bash
kubectl get services
```

List services sorted by name
```bash
kubectl get services --sort-by=.metadata.name
```

### Describe Services

```bash
kubectl describe services {{ service_name }}
kubectl describe svc {{ service_name }}
```

## Replication controller

### List all replication controller

```bash
kubectl get rc
```

## Secrets

### View status of secrets

```bash
kubectl get secrets
```

## Namespaces

### View namespaces

```bash
kubectl get namespaces
```

## Limits

```bash
kubectl get limitrange
```

```bash
kubectl describe limitrange limits
```

## Jobs and cronjobs

### Get cronjobs of a namespace

```bash
kubectl get cronjobs -n {{ namespace }}
```

### Get jobs of a namespace

```bash
kubectl get jobs -n {{ namespace }}
```

You can then describe a specific job to get the pod it created.

```bash
kubectl describe job -n {{ namespace }} {{ job_name }}
```

And now you can see the evolution of the job with:

```bash
kubectl logs -n {{ namespace }} {{ pod_name }}
```

# Interacting with nodes and cluster

## Mark node as unschedulable

```bash
kubectl cordon {{ node_name }}
```

## Mark node as schedulable

```bash
kubectl uncordon {{ node_name }}
```

## Drain node in preparation for maintenance

```bash
kubectl drain {{ node_name }}
```

## Show metrics of all node

```bash
kubectl top node
```

## Show metrics of a node

```bash
kubectl top node {{ node_name }}
```

## Display addresses of the master and servies

```bash
kubectl cluster-info
```

## Dump current cluster state to stdout

```bash
kubectl cluster-info dump
```

## Dump current cluster state to directory

```bash
kubectl cluster-info dump --output-directory={{ path_to_directory }}
```

# Interacting with pods

## Dump logs of pod

```bash
kubectl logs {{ pod_name }}
```

## Dump logs of pod and specified container

```bash
kubectl logs {{ pod_name }} -c {{ container_name }}
```

## Stream logs of pod

```bash
kubectl logs -f {{ pod_name }}
kubectl logs -f {{ pod_name }} -c {{ container_name }}
```

Another option is to use the [kubetail](https://github.com/johanhaleby/kubetail)
program.

## Attach to running container

```bash
kubectl attach {{ pod_name }} -i
```

## Get a shell of a running container

```bash
kubectl exec {{ pod_name }} -it bash
```

## Get a debian container inside kubernetes

```bash
kubectl run --generator=run-pod/v1 -i --tty debian --image=debian -- bash
```

## [Get a root shell of a running container](http://stackoverflow.com/questions/42793382/exec-commands-on-kubernetes-pods-with-root-access)

1. Get the Node where the pod is and the docker ID
```bash
kubectl describe pod {{ pod_name }}
```

2. SSH into the node
```bash
ssh {{ node }}
```

3. Get into docker
```bash
docker exec -it -u root {{ docker_id }} bash
```

## Forward port of pod to your local machine

```bash
kubectl port-forward {{ pod_name }} {{ pod_port }}:{{ local_port }}
```

## Expose port

```bash
kubectl expose {{ deployment_name }} --type="{{ expose_type }}" --port {{ port_number }}
```

Where expose_type is one of: ['NodePort', 'ClusterIP', 'LoadBalancer', 'externalName']

## Run command on existing pod

```bash
kubectl exec {{ pod_name }} -- ls /
kubectl exec {{ pod_name }} -c {{ container_name }} -- ls /
```

## Show metrics for a given pod and it's containers

```bash
kubectl top pod {{ pod_name }} --containers
```

## Extract file from pod

```bash
kubectl cp {{ container_id }}:{{ path_to_file }} {{ path_to_local_file }}
```

# Scaling resources

## Scale a deployment with a specified size

```bash
kubectl scale deployment {{ deployment_name }} --replicas {{ replicas_number }}
```

## Scale a replicaset

```bash
kubectl scale --replicas={{ replicas_number }} rs/{{ replicaset_name }}
```

## Scale a resource specified in a file

```bash
kubectl scale --replicas={{ replicas_number }} -f {{ path_to_yaml }}
```

# Updating resources

## Namespaces

### Temporary set the namespace for a request

```bash
kubectl -n {{ namespace_name }} {{ command_to_execute }}
kubectl --namespace={{ namespace_name }} {{ command_to_execute }}
```

### Permanently set the namespace for a request

```bash
kubectl config set-context $(kubectl config current-context) --namespace={{ namespace_name }}
```

## Deployment

### Modify the image of a deployment

```bash
kubectl set image {{ deployment_name }} {{ label }}:{{ label_value }}
```
for example
```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.9.1
```

Or edit it by hand
```bash
kubectl edit {{ deployment_name }}
```

### Get the status of the rolling update

```bash
kubectl rollout status {{ deployment_name }}
```

### Get the history of the deployment

```bash
kubectl rollout history deployment {{ deployment_name }}
```

To get more details of a selected revision:
```bash
kubectl rollout history deployment {{ deployment_name }} --revision={{ revision_number }}
```

### Get back to a specified revision

To get to the last version
```bash
kubectl rollout undo deployment {{ deployment_name }}
```

To go to a specific version
```bash
kubectl rollout undo {{ deployment_name }} --to-revision={{ revision_number }}
```

## Pods

### Rolling update of pods

Is prefered to use the deployment rollout

```bash
kubectl rolling-update {{ pod_name }} -f {{ new_pod_definition_yaml }}
```

### Change the name of the resource and update the image

```bash
kubectl rolling-update {{ old_pod_name }} {{ new_pod_name }} --image=image:{{ new_pod_version }}
```

### Abort existing rollout in progress

```bash
kubectl rolling-update {{ old_pod_name }} {{ new_pod_name }} --rollback
```

### Force replace, delete and then re-create the resource

** Will cause a service outage **

```bash
kubectl replace --force -f {{ new_pod_yaml }}
```

### Add a label

```bash
kubectl label pods {{ pod_name }} new-label={{ new_label }}
```

## Autoscale a deployment

```bash
kubectl autoscale deployment {{ deployment_name }} --min={{ min_instances }} --max={{ max_instances }} [--cpu-percent={{ cpu_percent }}]
```

# [Copy resources between namespaces](https://gist.github.com/simonswine/6bf3b665e4117f42b550c3ea12dd171a)

```bash
kubectl get rs,secrets -o json --namespace old | jq '.items[].metadata.namespace = "new"' | kubectl create-f -
```
# Formatting output

## Print a table using a comma separated list of custom columns

```bash
-o=custom-columns=<spec>
```

## Print a table using the custom columns template in the <filename> file

```bash
-o=custom-columns-file=<filename>
```

## Output a JSON formatted API object

```bash
-o=json
```

## Print the fields defined in a jsonpath expression

```bash
-o=jsonpath=<template>
```

## Print the fields defined by the jsonpath expression in the <filename> file

```bash
-o=jsonpath-file=<filename>
```

## Print only the resource name and nothing else

```bash
-o=name
```

## Output in the plain-text format with any additional information, and for pods, the node name is included

```bash
-o=wide
```

## Output a YAML formatted API object

```bash
-o=yaml
```
