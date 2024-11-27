---
title: Security groups
date: 20200429
author: Lyz
---

Security groups are the AWS way of defining firewall rules between the
resources. If not handled properly they can soon become hard to read, which can
lead to an insecure infrastructure.

It has helped me to use four types of security groups:

* Default security groups: Security groups created by AWS per VPC and region,
    they can't be deleted.
* Naming security groups: Used to identify an aws resource. They are usually
    referenced in other security groups.
* Ingress security groups: Used to define the rules of ingress traffic to the
    resource.
* Egress security groups: Used to define the rules of egress traffic to the
    resource.

But what helped most has been using [clinv](https://github.com/lyz-code/clinv)
while refactoring all the security groups.

With `clinv unused` I got rid of all the security groups that weren't used by
any AWS resource (beware of [#16](https://github.com/lyz-code/clinv/issues/16),
[17](https://github.com/lyz-code/clinv/issues/17),
[#18](https://github.com/lyz-code/clinv/issues/18) and
[#19](https://github.com/lyz-code/clinv/issues/19)), then used the `clinv
unassigned security_groups` to methodically decide if they were correct and add
them to my inventory or if I needed to refactor them.

# Best practices

* Follow a [naming convention](#naming-convention).
* Avoid as much as you can the use of CIDRs in the definition of security
    groups. Instead, use naming security groups as much as you can. This will
    probably mean that you'll need to create security rules for each service
    that is going to use the security group. It is cumbersome but from
    a security point of view we gain traceability.
* Follow the principle of least privileges. Open the least number of ports
    required for the service to work.
* Reuse existing security groups. If there is a security group for web servers
    that uses port 80, don't create the new service using port 8080.
* Remove all rules from the default security groups and don't use them.
* Don't define the rules in the `aws_security_group` terraform resource. Use
    `aws_security_group_rules` for each security group to avoid creation
    dependency loops.
* Add descriptions to each security group and security group rule.
* Avoid using port ranges in the security group rule definitions, as you
    probably won't need them.

# Naming convention

A naming convention is required once the number of security groups starts to
grow, both to understand them and to be able to search in them.

!!! note
    It is assumed that terraform is used to create the resources

## Default security groups

There are going to be two kinds of default security groups:

* VPC default security groups.
* Region default security groups.

For the first one we'll use:

```terraform
resource "aws_default_security_group" "{{ region_id }}_{{ vpc_friendly_identifier }}" {
  vpc_id = "{{ vpc_id }}"
}
```

Where:

* `region_id` is the region identifier with underscores, for example `us_east_1`
* `vpc_friendly_identifier` is a human understandable identifier, such as
    `publicdmz`.
* `vpc_id` is the VPC id such as `vpc-xxxxxxxxxxxxxxxxx`.

For the second one:

```terraform
resource "aws_default_security_group" "{{ region_id }}" {
  provider = aws.{{ region_id }}
}

Where the provider must be configured in the `terraform_config.tf` file, for
example:

```terraform
provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}
```

## Naming security groups

For the naming security groups I've created an
[UltiSnips](https://github.com/SirVer/ultisnips) template.

```terraform
snippet naming "naming security group rule" b
resource "aws_security_group" "${1:resource_name}_${2:resource_type}" {
  name        = "$1-$2"
  description = "Identify the $1 $2."
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_${3:vpc}_id
  tags = {
    Name = "$1 $2"
  }
}

output "$1_$2_id" {
  value = aws_security_group.$1_$2.id
}
$0
endsnippet
```

Where:

* `instance_name` is a human friendly identifier of the resource that the
    security group is going to identify, for example `gitea`, `ci` or `bastion`.
* `resource_type` identifies the type of resource, such as `instance` for EC2,
    or `load_balancer` for ELBs.
* `vpc`: is a human friendly identifier of the vpc. It has to match the outputs
    of the vpc resources, as it's going to be also used in the definition of the
    vpc used by the security group.

Once you've finished defining the security group, move the `output` resource to
the `outputs.tf` file.

## Ingress security groups

For the ingress security groups I've created another
[UltiSnips](https://github.com/SirVer/ultisnips) template.

```terraform
snippet ingress "ingress security group rule" b
resource "aws_security_group" "ingress_${1:protocol}_from_${2:destination}_at_${3:vpc}" {
  name        = "ingress-$1-from-$2-at-$3"
  description = "Allow the ingress of $1 traffic from the $2 instances at $3"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_$3_id
  tags = {
    Name = "Ingress $1 from $2 at $3"
  }
}

resource "aws_security_group_rule" "ingress_$1_from_$2_at_$3" {
  type              = "ingress"
  from_port         = ${4:port}
  to_port           = ${5:$4}
  protocol          = "${6:tcp}"
  security_group_id = aws_security_group.ingress_$1_from_$2_at_$3.id
  source_security_group_id = aws_security_group.$7.id
  description      = "Allow the ingress $1 traffic on port $4 from the $2 instances at $3."
}

output "ingress_$1_from_$2_at_$3_id" {
  value = aws_security_group.ingress_$1_from_$2_at_$3.id
}
$0
endsnippet
```

Where:

* `protocol` is a human friendly identifier of what kind of traffic the security
    group is going to allow, for example `gitea`, `ssh`, `proxy` or `openvpn`.
* `destination` identifies the resources that are going to use the security
    group, for example `drone_instance`, `ldap_instance` or `everywhere`.
* `vpc`: is a human friendly identifier of the vpc. It has to match the outputs
    of the vpc resources, as it's going to be also used in the definition of the
    vpc used by the security group.
* `port` is the port we are going to open.
* `$6` we assume that the `to_port` is the same as `from_port`.
* `$7` ID of the naming security group that will have access to the particular
    security group rule. If you need to use CIDRs for the rule definition,
    change that line for the following:

    ```terraform
    cidr_blocks       = ["{{ cidr }}"]
    ```

Once you've finished defining the security group, move the `output` resource to
the `outputs.tf` file.

## Egress security groups

For the egress security groups I've created another
[UltiSnips](https://github.com/SirVer/ultisnips) template.

```terraform
snippet egress "egress security group rule" b
resource "aws_security_group" "egress_${1:protocol}_to_${2:destination}_from_${3:vpc}" {
  name        = "egress-$1-to-$2-from-$3"
  description = "Allow the egress of $1 traffic to the $2 instances at $3"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_$3_id
  tags = {
    Name = "Egress $1 to $2 at $3"
  }
}

resource "aws_security_group_rule" "egress_$1_to_$2_from_$3" {
  type              = "egress"
  from_port         = ${4:port}
  to_port           = ${5:$4}
  protocol          = "${6:tcp}"
  security_group_id = aws_security_group.egress_$1_to_$2_from_$3.id
  source_security_group_id = aws_security_group.$7.id
  description      = "Allow the egress of $1 traffic on port $4 to the $2 instances at $3."
}

output "egress_$1_to_$2_from_$3_id" {
  value = aws_security_group.egress_$1_to_$2_from_$3.id
}
$0
endsnippet
```

Where:

* `protocol` is a human friendly identifier of what kind of traffic the security
    group is going to allow, for example `gitea`, `ssh`, `proxy` or `openvpn`.
* `destination` identifies the resources that are going to be accessed by the security
    group, for example `drone_instance`, `ldap_instance` or `everywhere`.
* `vpc`: is a human friendly identifier of the vpc. It has to match the outputs
    of the vpc resources, as it's going to be also used in the definition of the
    vpc used by the security group.
* `port` is the port we are going to open.
* `$6` we assume that the `to_port` is the same as `from_port`.
* `$7` ID of the naming security group that will be accessed by the particular
    security group rule. If you need to use CIDRs for the rule definition,
    change that line for the following:

    ```terraform
    cidr_blocks       = ["{{ cidr }}"]
    ```

Once you've finished defining the security group, move the `output` resource to
the `outputs.tf` file.

## Instance security group definition

When defining the security groups in the `aws_instance` resources, define them
in this order:

* Naming security groups.
* Ingress security groups.
* Egress security groups.

For example

```terraform
resource "aws_instance" "gitea_production" {
  ami               = ...
  availability_zone = ...
  subnet_id         = ...
  vpc_security_group_ids = [
    data.terraform_remote_state.security_groups.outputs.gitea_instance_id,
    data.terraform_remote_state.security_groups.outputs.ingress_http_from_gitea_loadbalancer_at_publicdmz_id,
    data.terraform_remote_state.security_groups.outputs.ingress_http_from_monitoring_at_privatedmz_id,
    data.terraform_remote_state.security_groups.outputs.ingress_administration_from_bastion_at_connectiondmz_id,
    data.terraform_remote_state.security_groups.outputs.egress_ldap_to_ldap_instance_from_publicdmz_id,
    data.terraform_remote_state.security_groups.outputs.egress_https_to_debian_repositories_from_publicdmz_id,
  ]
```
