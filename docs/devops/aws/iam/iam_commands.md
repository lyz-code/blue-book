---
Title: Commands for AWS IAM
Author: Lyz
Date: 20170529
---

# Information gathering

## List roles

```bash
aws iam list-roles --query 'Roles[*].{RoleName: RoleName, RoleId: RoleId}' --output table
```

## List policies

```bash
aws iam list-policies --query 'Policies[*].{PolicyName: PolicyName, PolicyId: PolicyId}' --output table
```

## List attached policies

```bash
aws iam list-attached-role-policies --role-name {{ role_name }}
```

## Get role configuration

```bash
aws iam get-role --role-name {{ role_name }}
```

## Get role policies

```bash
aws iam list-role-policies --role-name {{ role_name }}
```
