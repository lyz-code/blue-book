---
title: External DNS
date: 20200303
author: Lyz
---

The [external-dns](https://github.com/kubernetes-sigs/external-dns) resource
allows the creation of DNS records from within kubernetes inside the definition
of [service](kubernetes_services.md) and [ingress](kubernetes_ingress.md)
resources.

It currently supports the following providers:

| Provider                        | Status |
| ---                             | ---    |
| Google Cloud DNS                | Stable |
| AWS Route 53                    | Stable |
| AWS Cloud Map                   | Beta   |
| AzureDNS                        | Beta   |
| CloudFlare                      | Beta   |
| RcodeZero                       | Alpha  |
| DigitalOcean                    | Alpha  |
| DNSimple                        | Alpha  |
| Infoblox                        | Alpha  |
| Dyn                             | Alpha  |
| OpenStack Designate             | Alpha  |
| PowerDNS                        | Alpha  |
| CoreDNS                         | Alpha  |
| Exoscale                        | Alpha  |
| Oracle Cloud Infrastructure DNS | Alpha  |
| Linode DNS                      | Alpha  |
| RFC2136                         | Alpha  |
| NS1                             | Alpha  |
| TransIP                         | Alpha  |
| VinylDNS                        | Alpha  |
| RancherDNS                      | Alpha  |
| Akamai FastDNS                  | Alpha  |

There are two reasons to enable it:

* If there is any change in the ingress or service load balancer endpoint, due
  to a deployment, the dns records are automatically changed.
* It's easier for developers to connect their applications.

# [Deployment in AWS](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md)

To install it inside EKS, create the `ExternalDNSEKSIAMPolicy`.

??? note "ExternalDNSEKSIAMPolicy"
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource": [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          "Resource": [
            "*"
          ]
        }
      ]
    }
    ```

and the associated `eks-external-dns` role that will be attached to the pod
service account.

When defining `iam_role` resources that are going to be used inside EKS, you
need to use the EKS OIDC provider as trusted entity, so instead of using the
default empty role policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        }
      }
    ]
}
```

We'll use, as stated in the [Creating an IAM Role and Policy for Service
Account](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html)
and [Specifying an IAM Role for your Service
Account](https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html)
documents:

```json
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "oidc.eks.us-east-1.amazonaws.com/id/{{ cluster_fingerprint }}:sub": "system:serviceaccount:{{ service_account_namespace }}:{{ service_account_name }}"
          }
        },
        "Effect": "Allow",
        "Principal": {
          "Federated": "arn:aws:iam::{{ aws_account_id }}:oidc-provider/oidc.eks.{{ aws_zone }}.amazonaws.com/id/{{ cluster_fingerprint }}"
        }
      }
    ]
}
```

Then particularize the
[external-dns](https://github.com/helm/charts/tree/master/stable/external-dns)
[helm](helm.md) chart.

There are two ways of attaching the IAM role to `external-dns`, using the
`asumeRoleArn` attribute on the `aws` values.yaml key or under the `rbac`
`serviceAccountAnnotations`. I've tried the first but it gave an error because
the cluster IAM role didn't have permissions to execute the assume role on that
specific role. The second worked flawlessly.

For more information visit the [official external-dns aws
documentation](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md).
