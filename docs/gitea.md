---
title: Gitea
date: 20221012
author: Lyz
---

NOTE: Use [Forgejo](forgejo.md) instead!!


[Gitea](https://gitea.io/en-us/) is a community managed lightweight code hosting
solution written in Go. It's the best self hosted Github alternative in my
opinion.

# [Installation](https://docs.gitea.io/en-us/install-with-docker-rootless/)

Gitea provides automatically updated Docker images within its Docker Hub
organisation.

## [Configure gitea actions](https://blog.gitea.io/2023/03/hacking-on-gitea-actions/)

We've been using [Drone](drone.md) as CI runner for some years now as Gitea didn't have their native runner. On [Mar 20, 2023](https://blog.gitea.io/2023/03/gitea-1.19.0-is-released/) however Gitea released the version 1.19.0 which promoted to stable the Gitea Actions which is a built-in CI system like GitHub Actions. With Gitea Actions, you can reuse your familiar workflows and Github Actions in your self-hosted Gitea instance. While it is not currently fully compatible with GitHub Actions, they intend to become as compatible as possible in future versions. The typical procedure is as follows:

* Register a runner (at the moment, act runners are the only option). This can be done on the following scopes:
  * site-wide (by site admins)
  * organization-wide (by organization owners)
  * repository-wide (by repository owners)
* Create workflow files under `.gitea/workflows/<workflow name>.yaml` or `.github/workflows/<workflow name>.yaml`. The syntax is the same as [the GitHub workflow syntax](https://docs.github.com/en/actions) where supported. 

Gitea Actions advantages are:

* Uses the same pipeline syntax as Github Actions, so it's easier to use for new developers
* You can reuse existent Github actions.
* Migration from Github repositories to Gitea is easier.
* You see the results of the workflows in the same gitea webpage, which is much cleaner than needing to go to drone
* Define the secrets in the repository configuration.

Drone advantages are:

* They have the promote event. Not critical as we can use other git events such as creating a tag.
* They can be run as a service by default. The gitea runners will need some work to run on instance restart.
* Has support for [running kubernetes pipelines](https://docs.drone.io/quickstart/kubernetes/). Gitea actions doesn't yet support this

### [Setup Gitea actions](https://blog.gitea.io/2023/03/hacking-on-gitea-actions/)

You need a Gitea instance with a version of 1.19.0 or higher. Actions are disabled by default (as they are still an feature-in-progress), so you need to add the following to the configuration file to enable it:

```ini
[actions]
ENABLED=true
```

Even if you enable at configuration level you need to manually enable the actions on each repository [until this issue is solved](https://github.com/go-gitea/gitea/issues/23724).

So far there is [only one possible runner](https://gitea.com/gitea/act_runner) which is based on docker and [`act`](https://github.com/nektos/act). Currently, the only way to install act runner is by compiling it yourself, or by using one of the [pre-built binaries](http://dl.gitea.com/act_runner). There is no Docker image or other type of package management yet. At the moment, act runner should be run from the command line. Of course, you can also wrap this binary in something like a system service, supervisord, or Docker container.

Before running a runner, you should first register it to your Gitea instance using the following command:

```bash
./act_runner register --no-interactive --instance <instance> --token <token>
```

There are two arguments required, `instance` and `token`.

`instance` refers to the address of your Gitea instance, like `http://192.168.8.8:3000`. The runner and job containers (which are started by the runner to execute jobs) will connect to this address. This means that it could be different from the `ROOT_URL` of your Gitea instance, which is configured for web access. It is always a bad idea to use a loopback address such as `127.0.0.1` or `localhost`, as we will discuss later. If you are unsure which address to use, the LAN address is usually the right choice.

`token` is used for authentication and identification, such as `P2U1U0oB4XaRCi8azcngmPCLbRpUGapalhmddh23`. It is one-time use only and cannot be used to register multiple runners. You can obtain tokens from `your_gitea.com/admin/runners`.

After registering, a new file named `.runner` will appear in the current directory. This file stores the registration information. Please do not edit it manually. If this file is missing or corrupted, you can simply remove it and register again.

Finally, it’s time to start the runner.

```bash
./act_runner daemon
```

### [Use the gitea actions](https://blog.gitea.io/2023/03/hacking-on-gitea-actions/#use-actions)

Even if Actions is enabled for the Gitea instance, repositories [still disable Actions by default](https://github.com/go-gitea/gitea/issues/23724). Enable it on the settings page of your repository.

You will need to study [the workflow syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions) for Actions and write the workflow files you want.

However, we can just start from a simple demo:

```yaml
name: Gitea Actions Demo
run-name: ${{ gitea.actor }} is testing out Gitea Actions
on: [push]
jobs:
  Explore-Gitea-Actions:
    runs-on: ubuntu-latest
    steps:
      - run: echo "The job was automatically triggered by a ${{ gitea.event_name }} event."
      - run: echo "This job is now running on a ${{ runner.os }} server hosted by Gitea!"
      - run: echo "The name of your branch is ${{ gitea.ref }} and your repository is ${{ gitea.repository }}."
      - name: Check out repository code
        uses: actions/checkout@v3
      - run: echo "The ${{ gitea.repository }} repository has been cloned to the runner."
      - run: echo "The workflow is now ready to test your code on the runner."
      - name: List files in the repository
        run: |
          ls ${{ gitea.workspace }}          
      - run: echo "This job's status is ${{ gitea.status }}."
```

You can upload it as a file with the extension `.yaml` in the directory `.gitea/workflows/` or `.github/workflows` of the repository, for example `.gitea/workflows/demo.yaml`. 

You may be aware that there are tens of thousands of [marketplace actions in GitHub](https://github.com/marketplace?type=actions). However, when you write `uses: actions/checkout@v3`, it actually downloads the scripts from gitea.com/actions/checkout by default (not GitHub). This is a mirror of github.com/actions/checkout, but it’s impossible to mirror all of them. That’s why you may encounter failures when trying to use some actions that haven’t been mirrored.

The good news is that you can specify the URL prefix to use actions from anywhere. This is an extra syntax in Gitea Actions. For example:

* `uses: https://github.com/xxx/xxx@xxx`
* `uses: https://gitea.com/xxx/xxx@xxx`
* `uses: http://your_gitea_instance.com/xxx@xxx`

Be careful, the `https://` or `http://` prefix is necessary!

### Things that are not ready yet

* [Enable actions by default](https://github.com/go-gitea/gitea/issues/23724)
* Kubernetes act runner
* [Support cron jobs](https://github.com/go-gitea/gitea/pull/22751)

## [Disable the regular login, use only Oauth](https://discourse.gitea.io/t/solved-removing-default-login-interface/2740/2)

Inside your [`custom` directory](https://docs.gitea.io/en-us/customizing-gitea/) which may be `/var/lib/gitea/custom`:

* Create the directories `templates/user/auth`, 
* Create the `signin_inner.tmpl` file with the next contents:
  ```jinja2
                  {{if or (not .LinkAccountMode) (and .LinkAccountMode .LinkAccountModeSignIn)}}
                {{template "base/alert" .}}
                {{end}}
                <h4 class="ui top attached header center">
                        {{if .LinkAccountMode}}
                                {{.locale.Tr "auth.oauth_signin_title"}}
                        {{else}}
                                {{.locale.Tr "auth.login_userpass"}}
                        {{end}}
                </h4>
                <div class="ui attached segment">
                        <form class="ui form" action="{{.SignInLink}}" method="post">
                        {{.CsrfTokenHtml}}
                        {{if and .OrderedOAuth2Names .OAuth2Providers}}
                        <div class="ui attached segment">
                                <div class="oauth2 center">
                                        <div id="oauth2-login-loader" class="ui disabled centered loader"></div>
                                        <div>
                                                <div id="oauth2-login-navigator">
                                                        <p>Sign in with </p>
                                                        {{range $key := .OrderedOAuth2Names}}
                                                                {{$provider := index $.OAuth2Providers $key}}
                                                                <a href="{{AppSubUrl}}/user/oauth2/{{$key}}">
                                                                        <img
                                                                                alt="{{$provider.DisplayName}}{{if eq $provider.Name "openidConnect"}} ({{$key}}){{end}}"
                                                                                title="{{$provider.DisplayName}}{{if eq $provider.Name "openidConnect"}} ({{$key}}){{end}}"
                                                                                class="{{$provider.Name}} oauth-login-image"
                                                                                src="{{AppSubUrl}}{{$provider.Image}}"
                                                                        ></a>
                                                        {{end}}
                                                </div>
                                        </div>
                                </div>
                        </div>
                        {{end}}
                        </form>
                </div>
  ```
* Download the [`signin_inner.tmpl`](https://raw.githubusercontent.com/go-gitea/gitea/main/templates/user/auth/signin_inner.tmpl)
 
## [Configure it with terraform](https://registry.terraform.io/providers/Lerentis/gitea/latest/docs)

Gitea can be configured through terraform too. There is an [official provider](https://gitea.com/gitea/terraform-provider-gitea/src/branch/main) that doesn't work, there's a [fork that does though](https://registry.terraform.io/providers/Lerentis/gitea/latest/docs). Sadly it doesn't yet support configuring Oauth Authentication sources. Be careful [`gitea_oauth2_app`](https://registry.terraform.io/providers/Lerentis/gitea/latest/docs/resources/oauth2_app) looks to be the right resource to do that, but instead it configures Gitea to be the Oauth provider, not a consumer.

To configure the provider you need to specify the url and a Gitea API token, keeping in mind that whoever gets access to this information will have access and full permissions on your Gitea instance it's critical that [you store this information well](terraform.md#sensitive-information). We'll use [`sops` to encrypt the token with GPG.](#sensitive-information-in-the-terraform-source-code).

First create a Gitea user under `Site Administration/User Accounts/` with the `terraform` name (use your Oauth2 provider if you have one!).

Then log in with that user and create a token with name `Terraform` under `Settings/Applications`, copy it to your clipboard.

Configure `sops` by defining the gpg keys in a `.sops.yaml` file at the top of your repository:

```yaml
---
creation_rules:
  - pgp: >-
      2829BASDFHWEGWG23WDSLKGL323534J35LKWERQS,
      2GEFDBW349YHEDOH2T0GE9RH0NEORIG342RFSLHH
```

Then create the secrets file with the command `sops secrets.enc.json` somewhere in your terraform repository. For example:

```json
{
  "gitea_token": "paste the token here"
}
```

```hcl
terraform {
  required_providers {
    gitea = {
      source  = "Lerentis/gitea"
      version = "~> 0.12.1"
    }
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}

provider "gitea" {
  base_url   = "https://gitea.your-domain.org"
  token = data.sops_file.secrets.data["gitea_token"]
}
```

### [Create an organization](https://registry.terraform.io/providers/Lerentis/gitea/latest/docs/resources/team)

If you manage your users externally for example with an Oauth2 provider like [Authentik](authentik.md) you don't need to create a resource for the users, use a `data` instead:

```terraform
resource "gitea_org" "docker_compose" {
  name = "docker-compose"
}

resource "gitea_team" "docker_compose" {
  name         = "Developers"
  organisation = gitea_org.docker_compose.name
  permission   = "owner"
  members      = [
    data.gitea_user.lyz.username,
  ]
}
```

If you have many organizations that share the same users you can use variables.

```terraform

resource "gitea_org" "docker_compose" {
  name = "docker-compose"
}

resource "gitea_team" "docker_compose" {
  name         = "Developers"
  organisation = gitea_org.docker_compose.name
  permission   = "owner"
  members      = [
    data.gitea_user.lyz.username,
  ]
}
```

## Create an admin user through the command line

```bash
gitea --config /etc/gitea/app.ini admin user create --admin --email email --username user_name --password password
```

Or you can change [the admin's password](https://discourse.gitea.io/t/how-to-change-gitea-admin-password-from-the-command-terminal-line/1930):

```bash
gitea --config /etc/gitea/app.ini admin user change-password -u username -p password
```

# References

* [Home](https://gitea.io/en-us/)
* [Docs](https://docs.gitea.io/en-us/)

* [Terraform provider docs](https://registry.terraform.io/providers/Lerentis/gitea/latest/docs)
* [Terraform provider source code](https://github.com/Lerentis/terraform-provider-gitea)
