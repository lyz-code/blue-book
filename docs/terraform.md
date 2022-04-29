---
title: Terraform
date: 20210806
author: Lyz
---

[Terraform](https://en.wikipedia.org/wiki/Terraform_(software)) is an
open-source infrastructure as code software tool created by HashiCorp. It
enables users to define and provision a datacenter infrastructure using
an awful high-level configuration language known as Hashicorp Configuration Language
(HCL), or optionally JSON. Terraform supports a number of cloud
infrastructure providers such as Amazon Web Services, IBM Cloud
, Google Cloud Platform, DigitalOcean, Linode, Microsoft Azure,
Oracle Cloud Infrastructure, OVH, or VMware vSphere as well as
OpenNebula and OpenStack.

# Tools

* [tfschema](https://github.com/minamijoyo/tfschema): A binary that allows you
  to see the attributes of the resources of the different providers. There are
  some times that there are complex attributes that aren't shown on the docs
  with an example. Here you'll see them clearly.

  ```bash
  tfschema resource list aws | grep aws_iam_user
  > aws_iam_user
  > aws_iam_user_group_membership
  > aws_iam_user_login_profile
  > aws_iam_user_policy
  > aws_iam_user_policy_attachment
  > aws_iam_user_ssh_key

  tfschema resource show aws_iam_user
  +----------------------+-------------+----------+----------+----------+-----------+
  | ATTRIBUTE            | TYPE        | REQUIRED | OPTIONAL | COMPUTED | SENSITIVE |
  +----------------------+-------------+----------+----------+----------+-----------+
  | arn                  | string      | false    | false    | true     | false     |
  | force_destroy        | bool        | false    | true     | false    | false     |
  | id                   | string      | false    | true     | true     | false     |
  | name                 | string      | true     | false    | false    | false     |
  | path                 | string      | false    | true     | false    | false     |
  | permissions_boundary | string      | false    | true     | false    | false     |
  | tags                 | map(string) | false    | true     | false    | false     |
  | unique_id            | string      | false    | false    | true     | false     |
  +----------------------+-------------+----------+----------+----------+-----------+

  # Open the documentation of the resource in the browser

  tfschema resource browse aws_iam_user
  ```

* [terraforming](https://github.com/dtan4/terraforming): Tool to export existing
  resources to terraform

* [terraboard](https://github.com/camptocamp/terraboard): Web dashboard to
  visualize and query terraform tfstate, you can search, compare and see the
  most active ones. There are deployments for k8s.

  ```bash
  export AWS_ACCESS_KEY_ID=XXXXXXXXXXXXXXXXXXXX
  export AWS_SECRET_ACCESS_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
  export AWS_DEFAULT_REGION=eu-west-1
  export AWS_BUCKET=terraform-tfstate-20180119
  export TERRABOARD_LOG_LEVEL=debug
  docker network create terranet
  docker run -ti --rm --name db -e POSTGRES_USER=gorm -e POSTGRES_DB=gorm -e POSTGRES_PASSWORD="mypassword" --net terranet postgres
  docker run -ti --rm -p 8080:8080 -e AWS_REGION="$AWS_DEFAULT_REGION" -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" -e AWS_BUCKET="$AWS_BUCKET" -e DB_PASSWORD="mypassword" --net terranet camptocamp/terraboard:latest
  ```

* tfenv: Install different versions of terraform
  ```bash
  git clone https://github.com/tfutils/tfenv.git ~/.tfenv
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.zshrc
  tfenv list-remote
  tfenv install 0.12.8
  terraform version
  tfenv install 0.11.15
  terraform version
  tfenv use 0.12.8
  terraform version
  ```

* https://github.com/eerkunt/terraform-compliance

* [landscape](https://github.com/coinbase/terraform-landscape): A program to
  modify the `plan` and show a nicer version, really useful when it's shown as
  json. [Right now](https://github.com/coinbase/terraform-landscape/issues/101)
  it only works for terraform 11.

  ```bash
  terraform plan | landscape
  ```

* [k2tf](https://github.com/sl1pm4t/k2tf): Program to convert k8s yaml
  manifestos to HCL.

## Editor Plugins

For [Vim](vim.md):

* [vim-terraform](https://github.com/hashivim/vim-terraform): Execute tf from
    vim and autoformat when saving.
* [vim-terraform-completion](https://github.com/juliosueiras/vim-terraform-completion):
    linter and autocomplete.

## Good practices and maintaining

* [fmt](https://www.terraform.io/docs/commands/fmt.html): Formats the code
  following hashicorp best practices.

  ```bash
  terraform fmt
  ```

* [Validate](https://www.terraform.io/docs/commands/validate.html): Tests that
  the syntax is correct.
  ```bash
  terraform validate
  ```

* [Documentación](https://github.com/segmentio/terraform-docs): Generates
  a table in markdown with the inputs and outputs.

  ```bash
  terraform-docs markdown table *.tf > README.md

  ## Inputs

  | Name | Description | Type | Default | Required |
  |------|-------------|:----:|:-----:|:-----:|
  | broker_numbers | Number of brokers | number | `"3"` | no |
  | broker_size | AWS instance type for the brokers | string | `"kafka.m5.large"` | no |
  | ebs_size | Size of the brokers disks | string | `"300"` | no |
  | kafka_version | Kafka version | string | `"2.1.0"` | no |

  ## Outputs

  | Name | Description |
  |------|-------------|
  | brokers_masked_endpoints | Zookeeper masked endpoints |
  | brokers_real_endpoints | Zookeeper real endpoints |
  | zookeeper_masked_endpoints | Zookeeper masked endpoints |
  | zookeeper_real_endpoints | Zookeeper real endpoints |
  ```

* Terraform lint ([tflint](https://github.com/wata727/tflint)): Only works with
  some AWS resources. It allows the validation against a third party API. For
  example:
  ```hcl
    resource "aws_instance" "foo" {
      ami           = "ami-0ff8a91507f77f867"
      instance_type = "t1.2xlarge" # invalid type!
    }
  ```

  The code is valid, but in AWS there doesn't exist the type `t1.2xlarge`. This
  test avoids this kind of issues.

  ```bash
  wget https://github.com/wata727/tflint/releases/download/v0.11.1/tflint_darwin_amd64.zip
  unzip tflint_darwin_amd64.zip
  sudo install tflint /usr/local/bin/
  tflint -v
  ```

We can automate all the above to be executed before we do a commit using the
[pre-commit](https://pre-commit.com/) framework.

```bash
sudo pip install pre-commit
cd $proyectoConTerraform
echo """repos:
- repo: git://github.com/antonbabenko/pre-commit-terraform
  rev: v1.19.0
  hooks:
    - id: terraform_fmt
    - id: terraform_validate
    - id: terraform_docs
    - id: terraform_tflint
""" > .pre-commit-config.yaml
pre-commit install
pre-commit run terraform_fmt
pre-commit run terraform_validate --file dynamo.tf
pre-commit run -a
```

## Tests

[Motivation](https://www.contino.io/insights/top-3-terraform-testing-strategies-for-ultra-reliable-infrastructure-as-code)

### Static analysis

#### Linters

* conftest
* tflint
* `terraform validate`

#### Dry run

* `terraform plan`
* hashicorp sentinel
* terraform-compliance

### Unit tests

There is no real unit testing in infrastructure code as you need to deploy it in
a real environment

* `terratest` (works for k8s and terraform)

    Some sample code in:

    * github.com/gruntwork-io/infrastructure-as-code-testing-talk
    * gruntwork.io

### E2E test

* Too slow and too brittle to be worth it
* Use incremental e2e testing

# [Variables](https://www.terraform.io/intro/getting-started/variables.html)

It's a good practice to name the resource before the particularization of the
resource, so you can search all the elements of that resource, for example,
instead of `client_cidr` and `operations_cidr` use `cidr_operations` and
`cidr_client`

```tf
variable "list_example"{
  description = "An example of a list"
  type = "list"
  default = [1, 2, 3]
}

variable "map_example"{
  description = "An example of a dictionary"
  type = "map"
  default = {
    key1 = "value1"
    key2 = "value2"
  }
}
```

For the use of maps inside maps or lists investigate `zipmap`

To access you have to use `"${var.list_example}"`

For secret variables we use:
```terraform
variable "db_password" {
  description = "The password for the database"
}
```

Which has no default value, we save that password in our keystore and pass it as
environmental variable
```bash
export TF_VAR_db_password="{{ your password }}"
terragrunt plan
```

As a reminder, Terraform stores all variables in its state file in plain text,
including this database password, which is why your terragrunt config should
always enable encryption for remote state storage in S3

## [Interpolation of variables](https://github.com/hashicorp/terraform/issues/4084)

You can't interpolate in variables, so instead of
```terraform
variable "sistemas_gpg" {
  description = "Sistemas public GPG key for Zena"
  type = "string"
  default = "${file("sistemas_zena.pub")}"
}
```
You have to use locals

```terraform
locals {
  sistemas_gpg = "${file("sistemas_zena.pub")}"
}

"${local.sistemas_gpg}"
```

# Show information of the resources

Get information of the infrastructure. Output variables show up in the console
after you run `terraform apply`, you can also use `terraform output [{{
output_name }}]` to see the value of a specific output without applying any
changes

```tf
output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
```

```bash
> terraform apply
aws_security_group.instance: Refreshing state... (ID: sg-db91dba1)
aws_instance.example: Refreshing state... (ID: i-61744350)
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
Outputs:
public_ip = 54.174.13.5
```

# Data source

A *data source* represents a piece of read-only information that is fetched from
the provider every time you run Terraform. It does not create anything new

```terraform
data "aws_availability_zones" "all" {}
```

And you reference it with `"${data.aws_availability_zones.all.names}"`

# Read-only state source

With `terraform_remote_state` you an fetch the Terraform state file stored by
another set of templates in a completely read-only manner.

From an app template we can read the info of the ddbb with
```terraform
data "terraform_remote_state" "db" {
  backend = "s3"
  config {
    bucket = "(YOUR_BUCKET_NAME)"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "us-east-1"
  }
}
```

And you would access the variables inside the database terraform file with
`data.terraform_remote_state.db.outputs.port`

To share variables from state, you need to to set them in the `outputs.tf` file.

# Template_file source

It is used to load templates, it has two parameters, `template` which is
a string and `vars` which is a map of variables. it has one output attribute
called `rendered`, which is the result of rendering template. For example

```bash
# File: user-data.sh
#!/bin/bash
cat > index.html <<EOF
<h1>Hello, World</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOF
nohup busybox httpd -f -p "${server_port}" &
```

```terraform
data "template_file" "user_data" {
  template = "${file("user-data.sh")}"
  vars {
    server_port = "${var.server_port}"
    db_address = "${data.terraform_remote_state.db.address}"
    db_port = "${data.terraform_remote_state.db.port}"
  }
}
```

# Resource lifecycle

The `lifecycle` parameter is a *meta-parameter*, it exist on about every
resource in Terraform. You can add a `lifecycle` block to any resource to
configure how that resource should be created, updated or destroyed.

The available options are:
* `create_before_destroy`: Which if set to true will create a replacement
  resource before destroying hte original resource
* `prevent_destroy`: If set to true, any attempt to delete that resource
  (`terraform destroy`), will fail, to delete it you have to first remove the
  `prevent_destroy`

```terraform
resource "aws_launch_configuration" "example" {
  image_id = "ami-40d28157"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF
  lifecycle {
    create_before_destroy = true
  }
}
```

If you set the `create_before_destroy` on a resource, you also have to set it on every
resource that X depends on (if you forget, you'll get errors about cyclical
dependencies). In the case of the launch configuration, that means you need to
set `create_before_destroy` to true on the security group:

```terraform

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
```

# Use collaboratively

## Share state
The best option is to use S3 as bucket of the config.

First create it
```terraform
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-up-and-running-state"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}
```

And then configure terraform
```bash
terraform remote config \
          -backend=s3 \
          -backend-config="bucket=(YOUR_BUCKET_NAME)" \
          -backend-config="key=global/s3/terraform.tfstate" \
          -backend-config="region=us-east-1" \
          -backend-config="encrypt=true"
```

In this way terraform will automatically pull the latest state from this bucked
and push the latest state after running a command

## Lock terraform

To avoid several people running terraform at the same time, we'd use
`terragrunt` a wrapper for terraform that manages remote state for you
automatically and provies locking by using DynamoDB (in the free tier)

Inside the `terraform_config.tf` you create the dynamodb table and then
configure your `s3` backend to use it

```terraform
resource "aws_dynamodb_table" "terraform_statelock" {
  name           = "global-s3"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket = "grupo-zena-tfstate"
    key    = "global/s3/terraform.tfstate"
    region = "eu-west-1"
    encrypt = "true"
    dynamodb_table = "global-s3"
  }
}
```

You'll probably need to execute an `terraform apply` with the `dynamodb_table`
line commented

If you want to unforce a lock, execute:

```bash
terraform force-unlock {{ unlock_id }}
```

You get the `unlock_id` from an error trying to execute any `terraform` command

# Modules

In terraform you can put code inside of a `module` and reuse in multiple places
throughout your code.

The provider resource should be specified by the user and not in the modules

Whenever you add a module to your terraform template or modify its source
parameter you need to run a get command before you run `plan` or `apply`

```bash
terraform get
```

To extract output variables of a module to the parent tf file you should use

`${module.{{module.name}}.{{output_name}}}`

## Basics

Any set of Terraform templates in a directory is a module.

The good practice is to have a directory called `modules` in your parent project
directory. There you git clone the desired modules. and for example inside
`pro/services/bastion/main.tf` you'd call it with:

```terraform
provider "aws" {
  region = "eu-west-1"
}

module "bastion" {
  source = "../../../modules/services/bastion/"
}
```

## Outputs

Modules encapsulate their resources. A resource in one module cannot directly
depend on resources or attributes in other modules, unless those are exported
through outputs. These outputs can be referenced in other places in your
configuration, for example:

```terraform
resource "aws_instance" "client" {
  ami               = "ami-408c7f28"
  instance_type     = "t1.micro"
  availability_zone = "${module.consul.server_availability_zone}"
}
```

# Import

You can import the different parts with `terraform import
{{resource_type}}.{{resource_name}} {{ resource_id }}`

For examples see the documentation of the desired resource.

## Bulk import

But if you want to bulk import sources, I suggest using `terraforming`.

# Bad points

* Manually added resources wont be managed by terraform, therefore you can't use
  it to enforce as shown in this
  [bug](https://github.com/hashicorp/terraform/issues/4728).
* If you modify the LC of an ASG, the instances don't get rolling updated, you
  have to do it manually.
* They call the dictionaries `map`... (/ﾟДﾟ)/
* The conditionals are really ugly. You need to use `count`.
* You [can't split long strings](https://github.com/hashicorp/hcl/issues/211) xD

# Best practices

Name the resources with `_` instead of `-` so the editor's completion work :)

## VPC

Don't use the default vpc

## Security groups

Instead of using `aws_security_group` to define the ingress and egress rules,
use it only to create the empty security group and use `aws_security_group_rule`
to add the rules, otherwise you'll get into a cycle loop

The sintaxis of an egress security group must be
`egress_from_{{source}}_to_destination`. The sintaxis of an ingress security
group must be `ingress_to_{{destination}}_from_{{source}}`

Also set the order of the arguments, so they look like the name.

For ingress rule:

```terraform
security_group_id = ...
cidr_blocks = ...
```

And in egress should look like:

```terraform
security_group_id = ...
cidr_blocks = ...
```

Imagine you want to filter the traffic from A -> B, the egress rule from A to
B should go besides the ingress rule from B to A.

### Default security group

You can't manage the default security group of an vpc, therefore you have to
adopt it and set it to no rules at all with `aws_default_security_group`
resource

# IAM

You have to generate an gpg key and export it in base64

```bash
gpg --export {{ gpg_id }} | base64
```

To see the secrets you have to decrypt it
```bash
terraform output secret | base64 --decode | gpg -d
```

# Sensitive information

There are several approaches here.

First rely on the S3 encryption to protect the information in your state file

Second use [Vault
provider](https://www.terraform.io/docs/providers/vault/index.html) to protect the state file.

Third (but I won't use it) would be to use [terrahelp](https://github.com/opencredo/terrahelp)

## RDS credentials

The RDS credentials are saved in plaintext both in the definition and in the
state file, see [this](https://github.com/hashicorp/terraform/issues/516) bug
for more information. The value of `password` is not compared against the value
of the password in the cloud, so as long as the string in the code and the state
file remains the same, it won't try to change it.

As a workaround, you can create the RDS with a fake password `changeme`, and
once the resource is created, run an `aws` command to change it. That way, the
value in your code and the state is not the real one, but it won't try to change
it.

Inspired in [this
gist](https://gist.github.com/mattupstate/27f2bf26d3712b6b7973) and the
[`local-exec`](https://www.terraform.io/docs/language/resources/provisioners/local-exec.html)
docs, you could do:

```hcl
resource "aws_db_instance" "main" {
    username = "postgres"
    password = "changeme"
    ...
}

resource "null_resource" "master_password" {
    triggers {
        db_host = aws_db_instance.main.address
    }
    provisioner "local-exec" {
        command = "pass generate rds_main_password; aws rds modify-db-instance --db-instance-identifier $INSTANCE --master-user-password $(pass show rds_main_password)"
        environment = {
            INSTANCE = aws_db_instance.main.identifier
        }
    }
}
```

Where the password is stored in your `pass` repository that can be shared with
the team.

If you're wondering why I added such a long line, well it's because of HCL! as
you [can't split long strings](https://github.com/hashicorp/hcl/issues/211),
marvelous isn't it? xD

# Loops

You can't use nested lists or dictionaries, see this [2015 bug](https://github.com/hashicorp/terraform/issues/2114)

## Loop over a variable

```hcl
variable "vpn_egress_tcp_ports" {
  description = "VPN egress tcp ports "
  type = "list"
  default = [50, 51, 500, 4500]
}

resource "aws_security_group_rule" "ingress_tcp_from_ops_to_vpn_instance"{
  count = "${length(var.vpn_egress_tcp_ports)}"
  type = "ingress"
  from_port   = "${element(var.vpn_egress_tcp_ports, count.index)}"
  to_port     = "${element(var.vpn_egress_tcp_ports, count.index)}"
  protocol    = "tcp"
  cidr_blocks = [ "${var.cidr}"]
  security_group_id = "${aws_security_group.pro_ins_vpn.id}"
}
```

# Refactoring

Refactoring in terraform is **ugly business**

## Refactoring in modules

If you try to refactor your terraform state into modules it will try to destroy
and recreate all the elements of the module...

## [Refactoring the state file](https://www.terraform.io/docs/commands/state/mv.html)

```bash
terraform state mv -state-out=other.tfstate module.web module.web
```

# [Google cloud integration](https://www.terraform.io/docs/providers/google/index.html)

You configure it in the terraform directory
```terraform
// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
  project     = "my-gce-project"
  region      = "us-central1"
}
```

To download the json go to the [Google Developers
Console](https://console.developers.google.com/). Go to `Credentials` then
`Create credentials` and finally `Service account key`.

Select `Compute engine default service account` and select `JSON` as the key
type.

# [Ignore the change of an attribute](https://www.terraform.io/docs/language/meta-arguments/lifecycle.html#syntax-and-arguments)

Sometimes you don't care whether some attributes of a resource change, if that's
the case use the `lifecycle` statement:

```hcl
resource "aws_instance" "example" {
  # ...

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      tags,
    ]
  }
}
```

# [Define the default value of an variable that contains an object as empty](https://github.com/hashicorp/terraform/issues/19898)

```hcl
variable "database" {
  type = object({
    size                 = number
    instance_type        = string
    storage_type         = string
    engine               = string
    engine_version       = string
    parameter_group_name = string
    multi_az             = bool
  })
  default     = null
```

# Conditionals

## Elif

```terraform
locals {
  test = "${ condition ? value : (elif-condition ? elif-value : else-value)}"
}
```

## [Do a conditional if a variable is not null](https://stackoverflow.com/questions/53200585/terraform-conditionals-if-variable-does-not-exist)

```hcl
resource "aws_db_instance" "instance" {
  count                = var.database == null ? 0 : 1
  ...
```

# [Debugging](https://www.terraform.io/docs/internals/debugging.html)

You can set the `TF_LOG` environmental variable to one of the log levels
`TRACE`, `DEBUG`, `INFO`, `WARN` or `ERROR` to change the verbosity of the logs.

To remove the debug traces run `unset TF_LOG`.
# References

* [Docs](https://www.terraform.io/docs/index.html)
* [Modules registry](https://registry.terraform.io/)
* [terraform-aws-modules](https://github.com/terraform-aws-modules)
* [AWS providers](https://www.terraform.io/docs/providers/aws/index.html)
* [AWS examples](https://github.com/brikis98/terraform-up-and-running-code)
* [GCloud examples](https://github.com/mjuenema/Terraform-Up-and-Running-Code-Samples-Translated/)
* [Good and bad sides of terraform](https://charity.wtf/2016/02/23/two-weeks-with-terraform/)
* [Awesome Terraform](https://github.com/shuaibiyy/awesome-terraform)
