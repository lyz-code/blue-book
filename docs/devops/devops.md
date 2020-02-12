---
title: Devops
date: 20200212
author: Lyz
tags:
  - WIP
---

[DevOps](https://en.wikipedia.org/wiki/DevOps) is a set of practices that
combines software development (Dev) and information-technology operations (Ops)
which aims to shorten the systems development life cycle and provide continuous
delivery with high software quality.

# Learn path

DevOps is has become a juicy work, if you want to introduce yourself into this
world I suggest you to follow these steps:

* Learn basic Linux administration, otherwise you'll be lost.
* Learn how to use Git. If you can host your own Gitea, if not, use an existing
  service such as Gitlab or Github.
* Learn how to use Ansible, from now on try to deploy every machine with it.
* Build a small project inside [AWS](aws.md) so you can get used to the most
  common services (VPC, EC2, S3, Route53, RDS), most of them have free-tier
  resources so you don't need to pay anything.
* Once you are comfortable with AWS, learn how to use Terraform. You could for
  example deploy the previous project. From now on only use Terraform to
  provision AWS resources.
* Get into the CI/CD world hosting your own Drone, if not, use [Gitlab
  runners](https://docs.gitlab.com/runner/) or [Github
  Actions](https://github.com/features/actions).
