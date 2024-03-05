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
