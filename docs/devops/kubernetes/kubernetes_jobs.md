---
title: Kubernetes jobs
date: 20201111
author: Lyz
---

[Kubernetes
jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/) creates
one or more Pods and ensures that a specified number of them successfully
terminate. As pods successfully complete, the Job tracks the successful
completions. When a specified number of successful completions is reached, the
task (ie, Job) is complete. Deleting a Job will clean up the Pods it created.

[Cronjobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs)
creates Jobs on a repeating schedule.

This example CronJob manifest prints the current time and a hello message every
minute:

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            args:
            - /bin/sh
            - -c
            - date; echo Hello from the Kubernetes cluster
          restartPolicy: OnFailure
```

To deploy cronjobs you can use the [bambash helm
chart](https://github.com/bambash/helm-cronjobs).

Check [the kubectl commands to interact with jobs](kubectl_commands.md#jobs-and-cronjobs).

# Debugging job logs

To obtain the logs of a completed or failed job, you need to:

* Locate the cronjob you want to debug: `kubectl get cronjobs -n cronjobs`.
* Locate the associated job: `kubectl get jobs -n cronjobs`.
* Locate the associated pod: `kubectl get pods -n cronjobs`.

If the pod still exists, you can execute `kubectl logs -n cronjobs {{ pod_name
}}`. If the pod doesn't exist anymore, you need to search the pod in your log
centralizer solution.

## [Rerunning failed jobs](https://serverfault.com/questions/809632/is-it-possible-to-rerun-kubernetes-job)

If you have a job that has failed after the 6 default retries, it will show up
in your monitorization forever, to fix it, you can manually trigger the job
yourself with:

```bash
kubectl get job "your-job" -o json \
    | jq 'del(.spec.selector)' \
    | jq 'del(.spec.template.metadata.labels)' \
    | kubectl replace --force -f -
```

## [Manually creating a job from a cronjob](https://github.com/kubernetes/kubernetes/issues/47538)

```bash
kubectl create job {{ job_name }} -n {{ namespace }} \
    --from=cronjobs/{{ cronjob_name}}
```

# [Monitorization of cronjobs](https://medium.com/@tristan_96324/prometheus-k8s-cronjob-alerts-94bee7b90511)

Alerting of traditional Unix cronjobs meant sending an email if the job failed.
Most job scheduling systems that have followed have provided the same
experience, Kubernetes does not. One approach to alerting jobs is to
use the Prometheus push gateway, allowing us to push richer metrics than the
success/failure status. This approach has it’s downsides; we have to update the code
for our jobs, we also have to explicitly configure a push gateway location and
update it if it changes (a burden alleviated by the pull based metrics for long
lived workloads). You can use tools such as Sentry, but it will also require
changes to the jobs.

Jobs are powerful things allowing us to implement several different workflows,
the combination of options can be overwhelming compared to a traditional Unix
cron job. This variety makes it difficult to establish one simple rule for
alerting failed jobs. Things get easier if we restrict ourselves to a
subset of possible options. We will focus on non-concurrent jobs.

The relationship between cronjobs and jobs makes the task ahead difficult. To
make our life easier we will put one requirement on the jobs we create, they
will have to include a label that associates them with the original cronjob.

Below we present an example of our ideal cronjob (which matches what the [helm
chart](https://github.com/bambash/helm-cronjobs) deploys):

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: our-task
spec:
  schedule: "*/5 * * * *"
  successfulJobsHistoryLimit: 3
  concurrencyPolicy: Forbid
  jobTemplate:
    metadata:
      labels:
        cron: our-task # <-- match created jobs with the cronjob
    spec:
      backoffLimit: 3
      template:
        metadata:
          labels:
            cronjob: our-task
        spec:
          containers:
          - name: our-task
            command:
            - /user/bin/false
            image: alpine
          restartPolicy: Never
```

## Building our alert

We are also going to need some metrics to get us started. K8s does not provide
us any by default, but fortunately `kube-state-metrics` is installed with the
[Prometheus operator](prometheus_operator.md) chart, so we have the following
metrics:

```
kube_cronjob_labels{
  cronjob="our-task",
  namespace="default"} 1
kube_job_created{
  job="our-task-1520165700",
  namespace="default"} 1.520165707e+09
kube_job_failed{
  condition="false",
  job="our-task-1520165700",
  namespace="default"} 0
kube_job_failed{
  condition="true",
  job="our-task-1520165700",
  namespace="default"} 1
kube_job_labels{
  job="our-task-1520165700",
  label_cron="our-task",
  namespace="default"} 1
```

This shows the primary set of metrics we will be using to construct our alert.
What is not shown above is the status of the cronjob. The big challenge with K8s
cronjob alerting is that cronjobs themselves do not possess any status
information, beyond the last time the cronjob created a job. The status
information only exists on the job that the cronjob creates.

In order to determine if our cronjob is failing, our first order of business is
to find which jobs we should be looking at. A K8s cronjob creates new job
objects and keeps a number of them around to help us debug the runs of our jobs.
We have to be determine which job corresponds to the last run of our cronjob. If
we have added the cron label to the jobs as above, we can find the last run
time of the jobs for a given cronjob as follows:

```promql
max(
  kube_job_status_start_time
  * ON(job_name) GROUP_RIGHT()
  kube_job_labels{label_cron!=""}
) BY (job_name, label_cron)
```

This query demonstrates an important technique when working with
`kube-state-metrics`. For each API object it exported data on, it exports a time
series including all the labels for that object. These time series have a value
of 1. As such we can join the set of labels for an object onto the metrics about
that object by multiplication.

Depending on how your Prometheus instance is configured, the value of the job
label on your metrics will likely be `kube-state-metrics`. `kube-state-metrics`
adds a job label itself with the name of the job object. Prometheus resolves
this collision of label names by including the raw metric’s label as an
`job_name` label.

Since we are querying the start time of jobs, and there should only ever be one
job with a given name. You may wonder why we need the max aggregation. Manually
plugging the query into Prometheus may convince you that it is unnecessary.
Consider though that you may have multiple instances of `kube-state-metrics`
running for redundancy. Using max ensures our query is valid even if we have
multiple instances of kube-state-metrics running. Issues of duplicate metrics
are common when constructing production recording rules and alerts.

We can find the start time of the most recent job for a given cronjob by finding
the maximum of all job start times as follows:

```promql
max(
  kube_job_status_start_time
  * ON(job_name) GROUP_RIGHT()
  kube_job_labels{label_cron!=""}
) BY (label_cron)
```

The only difference between this and the previous query is in the labels used
for the aggregation. Now that we have the start time of each job, and the start
time of the most recent job, we can do a simple equality match to find the start
time of the most recent job for a given cronjob. We will create a metric for
this:

```promql
- record: job_cronjob:kube_job_status_start_time:max
  expr: |
      sum without (label_cron, job_name) (
          label_replace(
              label_replace(
                  max(
                      kube_job_status_start_time
                      * ON(job_name) GROUP_RIGHT()
                      kube_job_labels{label_cron!=""}
                  ) BY (job_name, label_cron)

                  == ON(label_cron) GROUP_LEFT()

                  max(
                      kube_job_status_start_time
                      * ON(job_name) GROUP_RIGHT()
                      kube_job_labels{label_cron!=""}
                  ) BY (label_cron),
                  "job", "$1", "job_name", "(.+)"
              ),
                  "cronjob", "$1", "label_cron", "(.+)"
          )
      )
```

We have also taken the opportunity to adjust the labels to be a little more
aesthetically pleasing. By copying `job_name` to `job`, `label_cron` to
`cronjob` and removing `job_name` and `label_cron`. Now that we have the most
recently started job for a given cronjob, we can find which, if any, have failed
attempts:

```promql
- record: job_cronjob:kube_job_status_failed:sum
    expr: |
      sum without (label_cron, job_name) (
          clamp_max(
              job_cronjob:kube_job_status_start_time:max,
              1
          )

          * ON(job) GROUP_LEFT()

          label_replace(
              label_replace(
                  (
                    kube_job_status_failed != 0 and
                    kube_job_status_succeeded == 0
                  ),
                  "job", "$1", "job_name", "(.+)"
              ),
              "cronjob", "$1", "label_cron", "(.+)"
          )
      )
```

The initial `clamp_max` clause is used to transform our start times metric into
a set of time series to perform label matching to filter another set of metrics.
Multiplication by 1 (or addition of 0), is a useful means of filter and merging
time series and it is well worth taking the time to understand the technique.

We get those cronjobs that have a failed job and no successful ones with the
query:

```promql
(
    kube_job_status_failed != 0 and
    kube_job_status_succeeded == 0
)
```

The `kube_job_status_succeeded == 0` it's important, otherwise once a job has
a failed instance, it doesn't matter if there's a posterior one that succeeded,
we're going to keep on receiving the alert that it failed.

We adjust the labels on the previous query to match our start time metric so
ensure the labels have the same meaning as those on our
`job_cronjob:kube_job_status_start_time:max` metric. The label matching on the
multiplication will then perform our filtering. We now have a metric containing
the set of most recently failed jobs, labeled by their parent cronjob, so we can
now construct the alert:

```promql
- alert: CronJobStatusFailed
    expr: job_cronjob:kube_job_status_failed:sum > 0
    for: 1m
    annotations:
      description: '{{ $labels.cronjob }} last run has failed {{ $value }} times.'
```

We use the `kube_cronjob_labels` here to merge in labels from the original
cronjob.
