---
title: Devops
date: 20200212
author: Lyz
tags:
---

[DevOps](https://en.wikipedia.org/wiki/DevOps) is a set of practices that
combines software development (Dev) and information-technology operations (Ops)
which aims to shorten the systems development life cycle and provide continuous
delivery with high software quality.

One of the most important goals of the DevOps initiative is to break the silos
between the developers and the sysadmins, that lead to ill feelings and
unproductivity.

It's a [relatively new concept](https://en.wikipedia.org/wiki/DevOps#History),
the main ideas emerged in the 1990s and the first conference was in 2009. That
means that as of 2021 there is still a lot of debate of what people understand
as DevOps.

# DevOps pitfalls

I've found that the DevOps word leads to some pitfalls that we should try to
avoid.

## Getting lost in the label

[Labels](https://en.wikipedia.org/wiki/Labelling) are a language tool used to
speed up communication by describing someone or something in a word or short
phrase.

However, there are times when labels achieve the complete oposite, as it's the
case with DevOps, where there are different views on what the label represents
and usually one of the communication parties strongly feels they belong to the
label while the other doesn't agree. These discussions can fall into an
unproductive, agitated semantic debate where each part tries to convince each
other.

So instead of starting a [twitter
thread](https://twitter.com/christianhujer/status/1356481078626639873) telling
people why they aren't a DevOps team, we could invest those energies in creating
resources that close the gap between both parties. Similarly, instead of
starting an internal discussion of *what do we understand as DevOps?*, we could
discuss how to improve our existent processes so that the team members feel more
comfortable contributing to the application or infrastructure code.

## You need to do it all to be awarded the DevOps pin

I find specially harmful the idea that to be qualified as DevOps you need to
develop and maintain the application at the same time as the infrastructure that
holds it.

To be able to do that in a typical company product you'll need to know (between
another thousand more things):

* How to operate the cloud infrastructure where the project lives, which can be
    [AWS](aws.md), Google Cloud, Azure or/and baremetal servers.
* Deploy new resources in that infrastructure, which probably would mean knowing
    Terraform, Ansible, Docker or/and [Kubernetes](kubernetes.md).
* How to integrate the new resources with the operations processes, for example:
    * The monitoring system, so you'll need to know how to use
        [Prometheus](prometheus.md), Nagios, Zabbix or the existent solution.
    * The continuous integration or delivery system, that you'll need to know
        how to maintain, so you have to know how it works and how is it built.
    * The backup system.
    * The log centralizer system.
* Infrastructure architecture to know what you need to deploy, how and where.
* To code efficiently in the language that the application is developed in, for
    example Java, Python, Rust, Go, PHP or Javascript, in a way that meets the
    quality requirements (code style, linters, coverage and documentation).
* Knowing how to test your code in that language.
* Software architecture to structure complex code projects in a maintainable
    way.
* The product you're developing to be able to suggest features and fixtures when
    the product owner or the stakeholders show their needs.
* How to make the application user friendly so anyone wants to use it.
* And don't forget that you also need to do that in a secure way, so you should
    also have to know about pentesting, static and dynamic security tools,
    common security vulnerabilities...

And I could keep on going forever. Even if you could get there (and you won't), it
wouldn't matter, because when you did, the technologies will have changed so much
that you will already be outdated and would need to start over.

It's the sickness of the fullstack developer. If you make job openings with this
mindset you're going to end up with a team of cis white males in their thirties
or forties that are used to earn 3 or 4 times the minimum salary. No other kind
of people can reach that point and hold it in time.

But bare with me a little longer, even if you make there. What happens when the
project changes so that you need to:

* Change the programming language of your application.
* Change the cloud provider.
* Change the deployment system.
* Change the program architecture.
* Change the language framework.

Or any other thousand of possible changes? You would need to be able to keep up with
them. Noooo way.

Luckily you are not alone. You are a cog in a team, that as a whole is able to
overcome these changes. That is why we have developers, sysadmins, security,
user experience, quality, scrum master and product owners. So each profile can
design, create, investigate and learn it's best in their area of expertise. In
the merge of all that personal knowledge is where the team thrives.

DevOps then, as I understand it, is the philosophy where the developers and
sysadmins try their best to break the barriers that separate them. That idea can
be brought to earth by for example:

* Open discussions on how to:
    * Improve the development workflow.
    * Make developers or sysadmins life easier.
    * Make it easier to use the sysadmin tools.
    * Make it easier to understand the developers code.
* Formations on the technologies or architecture used by either side.
* A clear documentation that allows either side to catch up with new changes.
* Periodic meetings to update each other with the changes.
* Periodic meetings to release the tension that have appeared between
    them.
* Joined design sessions to decide how to solve problems.

# Learn path

DevOps has become a juicy work, if you want to become one, I think you first
need to get the basic knowledge of each of them (developing and operating)
before being able to unlock the benefits of the combination of both. You can try
to learn both at the same time, but I think it can be a daunting task.

To get the basic knowledge of the Ops side I would:

* Learn basic Linux administration, otherwise you'll be lost.

* Learn how to be comfortable searching for anything you don't know, most of
    your questions are already answered, and even the most senior people spent
    a great amount of time searching for solutions in the project's
    documentation, Github issues or Stackoverflow.

    When you start, navigating this knowledge sources is hard and consumes a lot
    of your life, but it will get easier with the time.

* Learn how to use Git. If you can, host your own Gitea, if not, use an existing
  service such as Gitlab or Github.

* Learn how to install and maintain services, (that is why I suggested hosting
    your own Gitea). If you don't know what to install, take a look at the
    [awesome
    self-hosted](https://github.com/awesome-selfhosted/awesome-selfhosted) list.

* Learn how to use Ansible, from now on try to deploy every machine with it.

* Build a small project inside [AWS](aws.md) so you can get used to the most
  common services (VPC, EC2, S3, Route53, RDS), most of them have free-tier
  resources so you don't need to pay anything. You can try also with Google
  Cloud or Azure, but I recommend against it.

* Once you are comfortable with AWS, learn how to use Terraform. You could for
  example deploy the previous project. From now on only use Terraform to
  provision AWS resources.

* Get into the [CI/CD](ci.md) world hosting your own Drone, if not, use [Gitlab
  runners](https://docs.gitlab.com/runner/) or [Github
  Actions](https://github.com/features/actions).

To get the basic knowledge of the Dev side I would:

* Learn the basics of a programming language, for example Python. There are
    thousand sources there on how to do it, books, articles, videos, forums or
    courses, choose the one that suits you best.

* As with the Ops path, get comfortable with git and searching for things you
    don't know.

* As soon as you can, start doing small programming projects that make your life
    easier. Coding your stuff is what's going to make you internalize the
    learned concepts, by finding solutions to the blocks you encounter.

* Publish those projects into a public git server, don't be afraid if you code
    is good enough, it works for you, you did your best and you should be happy
    about it. That's all that matters. By doing so, you'll start collaborating
    to the open source world and it will probably force yourself to make your
    code better.

* Step into the [TDD](tdd.md) world, learn why, how and when to test your code.

* For those projects that you want to maintain, create [CI/CD pipelines](ci.md)
    that enhance the quality of your code, by for example running your tests or
    some [linters](ci.md#linters).

* Once you're comfortable, try to collaborate with existent projects (right now
    you may not now where to look for projects to collaborate, but when you reach
    this point, I promise you will).
