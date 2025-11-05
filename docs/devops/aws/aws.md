---
title: AWS
date: 20200212
author: Lyz
tags:
  - WIP
---

[Amazon Web Services (AWS)](https://en.wikipedia.org/wiki/Amazon_Web_Services)
is a subsidiary of Amazon that provides on-demand cloud computing platforms and
APIs to individuals, companies, and governments, on a metered pay-as-you-go
basis. In aggregate, these cloud computing web services provide a set of
primitive abstract technical infrastructure and distributed computing building
blocks and tools.

# Learn path

TBD

# AWS snippets

## Exclude greyed out trusted advisor checks

There are some checks that can't be excluded from the web UI. To exclude them you need to use the CLI.

I got the check id from the prometheus exporter, I have no clue how to get it from elsewhere. The steps are:

- Retrieve the Recommendation ARN, Execute the following command to list recommendations:

  ```bash
  aws trustedadvisor list-recommendations --region us-east-1 --check-identifier 'arn:aws:trustedadvisor:::check/c1dfprch15'
  ```

- Run the `list-recommendation-resources` command using the suggestions ARN, to obtain the recommendation-resource ARN for the check you want to be excluded. ( Using the recommendation ARN from step 1: )

  ```bash
  aws trustedadvisor list-recommendation-resources --recommendation-identifier $recommendation_arn
  ```

  Copy the resource ARN from the above output, which in this format - `arn:aws:trustedadvisor::<account-id>:recommendation-resource/<recommendation-id>/<resource-id>`. Or you can use `| jq '.recommendationResourceSummaries[].arn` to show all the arns.

- Exclude Specific Resources, to execute for each resource you wish to exclude please use the below command.

  ```bash
  aws trustedadvisor batch-update-recommendation-resource-exclusion --recommendation-resource-exclusions '[{\"arn\": \"<ARN from Step 2>\",\"isExcluded\": true}]' --region us-east-1
  ```


For example to exclude all the arns of a check you can use:

```bash
aws trustedadvisor list-recommendation-resources --recommendation-identifier $recommendation_arn | jq -r '.recommendationResourceSummaries[].arn' | while read arn; do aws trustedadvisor batch-update-recommendation-resource-exclusion --recommendation-resource-exclusions "[{\"arn\": \"$arn\",\"isExcluded\": true}]" --region us-east-1; done
```
## [Remove the public IP of an ec2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/managing-network-interface-ip-addresses.html)

- Navigate to the network interfaces of the instance
- Click on the one that contains the public IP
- Actions/Manage IP addresses
- Click on the Interface to unfold the configuration
- Click on Auto-assign public IP

## [Get the role used by the instance](https://stackoverflow.com/questions/47313778/find-role-being-used-on-server-from-aws-cli)

```bash
aws sts get-caller-identity
{
    "UserId": "AIDAxxx",
    "Account": "xxx",
    "Arn": "arn:aws:iam::xxx:user/Tyrone321"
}
```

You can then take the role name, and query IAM for the role details using both `iam list-role-policies` for inline policies and `iam-list-attached-role-policies` for attached managed policies (thanks to @Dimitry K for the callout).

$ aws iam list-attached-role-policies --role-name Tyrone321
{
"AttachedPolicies": [
{
"PolicyName": "SomePolicy",
"PolicyArn": "arn:aws:iam::aws:policy/xxx"
},
{
"PolicyName": "AnotherPolicy",
"PolicyArn": "arn:aws:iam::aws:policy/xxx"
} ]
}

To get the actual IAM permissions, use aws iam get-policy to get the default policy version ID, and then aws iam get-policy-version with the version ID to retrieve the actual policy statements. If the IAM principal is a user, the commands are aws iam list-attached-user-policies and aws iam get-user-policy.

## [Stop an EC2 instance](https://docs.aws.amazon.com/cli/latest/reference/ec2/stop-instances.html)

```bash
aws ec2 stop-instances --instance-ids i-xxxxxxxx
```

# References

- [Compare aws ec2 instance types and prices](https://instances.vantage.sh/)
