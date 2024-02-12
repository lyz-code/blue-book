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

So far there is [only one possible runner](https://gitea.com/gitea/act_runner) which is based on docker and [`act`](https://github.com/nektos/act). Currently, the only way to install act runner is by compiling it yourself, or by using one of the [pre-built binaries](https://dl.gitea.com/act_runner). There is no Docker image or other type of package management yet. At the moment, act runner should be run from the command line. Of course, you can also wrap this binary in something like a system service, supervisord, or Docker container.

You can create the default configuration of the runner with:

```bash
./act_runner generate-config > config.yaml
```

You can tweak there for example the `capacity` so you are able to run more than one workflow in parallel.

Before running a runner, you should first register it to your Gitea instance using the following command:

```bash
./act_runner register --config config.yaml --no-interactive --instance <instance> --token <token>
```

There are two arguments required, `instance` and `token`.

`instance` refers to the address of your Gitea instance, like `http://192.168.8.8:3000`. The runner and job containers (which are started by the runner to execute jobs) will connect to this address. This means that it could be different from the `ROOT_URL` of your Gitea instance, which is configured for web access. It is always a bad idea to use a loopback address such as `127.0.0.1` or `localhost`, as we will discuss later. If you are unsure which address to use, the LAN address is usually the right choice.

`token` is used for authentication and identification, such as `P2U1U0oB4XaRCi8azcngmPCLbRpUGapalhmddh23`. It is one-time use only and cannot be used to register multiple runners. You can obtain tokens from `your_gitea.com/admin/runners`.

After registering, a new file named `.runner` will appear in the current directory. This file stores the registration information. Please do not edit it manually. If this file is missing or corrupted, you can simply remove it and register again.

Finally, it’s time to start the runner.

```bash
./act_runner --config config.yaml daemon
```

You can also create a systemd service so that it starts when the server boots. For example in `/etc/systemd/system/gitea_actions_runner.service:

```
[Unit]
Description=Gitea Actions Runner
After=network.target

[Service]
WorkingDirectory=/var/gitea/gitea/act_runner/main
ExecStart=/var/gitea/gitea/act_runner/main/act_runner-main-linux-amd64 daemon

[Install]
WantedBy=default.target
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
* `uses: https://your_gitea_instance.com/xxx@xxx`

Be careful, the `https://` or `http://` prefix is necessary!

### [Tweak the runner image](https://itsthejoker.github.io/gitea_actions_and_python/)

The [gitea runner](https://docs.gitea.com/next/usage/actions/act-runner/#labels) uses the `node:16-bullseye` image by default, in that image [the `setup-python` action doesn't work](https://itsthejoker.github.io/gitea_actions_and_python/). You can tweak the docker image that the runner runs by editing the `.runner` file that is in the directory where you registered the runner (probably close to the `act_runner` executable).

If you open that up, you’ll see that there is a section called labels, and it (most likely) looks like this:

```json
"labels": [
  "ubuntu-latest:docker://node:16-bullseye",
  "ubuntu-22.04:docker://node:16-bullseye",
  "ubuntu-20.04:docker://node:16-bullseye",
  "ubuntu-18.04:docker://node:16-buster"
]
```

You can specify any other docker image. Adding new labels doesn't work yet.

You can start with this dockerfile:

```dockerfile
FROM node:16-bullseye

# Configure the labels
LABEL prune=false

# Configure the AWS credentials
RUN mkdir /root/.aws
COPY files/config /root/.aws/config
COPY files/credentials /root/.aws/credentials

# Install dependencies
RUN apt-get update && apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  screen \
  vim \
  && python3 -m pip install --upgrade pip \
  && rm -rf /var/lib/apt/lists/*

RUN pip install \
  molecule==5.0.1 \
  ansible==8.0.0 \
  ansible-lint \
  yamllint \ 
  molecule-plugins[ec2,docker,vagrant] \
  boto3 \ 
  botocore \
  testinfra \
  pytest

RUN wget https://download.docker.com/linux/static/stable/x86_64/docker-24.0.2.tgz \
  && tar xvzf docker-24.0.2.tgz \
  && cp docker/* /usr/bin \
  && rm -r docker docker-*
```

It's prepared for:

- Working within an AWS environment
- Run Ansible and molecule
- Build dockers

### Things that are not ready yet

* [Enable actions by default](https://github.com/go-gitea/gitea/issues/23724)
* Kubernetes act runner
* [Support cron jobs](https://github.com/go-gitea/gitea/pull/22751)
* [Badge for the CI jobs](https://github.com/go-gitea/gitea/issues/23688)

### Build a docker within a gitea action

Assuming you're using the custom gitea_runner docker proposed above you can build and upload a docker to a registry with this action:

```yaml
---
name: Publish Docker image

"on": [push]

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: https://github.com/actions/checkout@v3

      - name: Login to Docker Registry
        uses: https://github.com/docker/login-action@v2
        with:
          registry: my_registry.org
          username: ${{ secrets.REGISTRY_USERNAME }}
          password: ${{ secrets.REGISTRY_PASSWORD }}

      - name: Set up QEMU
        uses: https://github.com/docker/setup-qemu-action@v2

      - name: Set up Docker Buildx
        uses: https://github.com/docker/setup-buildx-action@v2

      - name: Extract metadata (tags, labels) for Docker
        id: meta
        uses: https://github.com/docker/metadata-action@v4
        with:
          images: my_registry.org/the_name_of_the_docker_to_build

      - name: Build and push
        uses: docker/build-push-action@v2
        with:
          context: .
          platforms: linux/amd64,linux/arm64
          push: true
          cache-from: type=registry,ref=my_registry.org/the_name_of_the_docker_to_build:buildcache
          cache-to: type=registry,ref=my_registry.org/the_name_of_the_docker_to_build:buildcache,mode=max
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
```

It uses a pair of nice features:

- Multi-arch builds
- [Cache](https://docs.docker.com/build/ci/github-actions/cache/) to speed up the builds

As it reacts to all events it will build and push:

- A tag with the branch name on each push to that branch
- a tag with the tag on tag push

### Bump the version of a repository on commits on master

- Create a SSH key for the CI to send commits to protected branches. 
- Upload the private key to a repo or organization secret called `DEPLOY_SSH_KEY`.
- Upload the public key to the repo configuration deploy keys
- Create the `bump.yaml` file with the next contents:

    ```yaml
    ---
    name: Bump version

    "on":
      push:
        branches:
          - main

    jobs:
      bump_version:
        if: "!startsWith(github.event.head_commit.message, 'bump:')"
        runs-on: ubuntu-latest
        name: "Bump version and create changelog"
        steps:
          - name: Check out
            uses: actions/checkout@v3
            with:
              fetch-depth: 0  # Fetch all history

          - name: Configure SSH
            run: |
                echo "${{ secrets.DEPLOY_SSH_KEY }}" > ~/.ssh/deploy_key
                chmod 600 ~/.ssh/deploy_key
                dos2unix ~/.ssh/deploy_key
                ssh-agent -a $SSH_AUTH_SOCK > /dev/null
                ssh-add ~/.ssh/deploy_key

          - name: Bump the version
            run: cz bump --changelog --no-verify

          - name: Push changes
            run: |
              git remote add ssh git@gitea-production.cloud.icij.org:templates/ansible-role.git
              git pull ssh main
              git push ssh main
              git push ssh --tags
    ```

    It assumes that you have `cz` (commitizen) and `dos2unix` installed in your runner.

### Skip gitea actions job on changes of some files

#### Using `paths-filter` custom action

```
jobs:
  test:
    if: "!startsWith(github.event.head_commit.message, 'bump:')"
    name: Test
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the codebase
        uses: https://github.com/actions/checkout@v3

      - name: Check if we need to run the molecule tests
        uses: https://github.com/dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            molecule:
              - 'defaults/**'
              - 'tasks/**'
              - 'handlers/**'
              - 'tasks/**'
              - 'templates/**'
              - 'molecule/**'
              - 'requirements.yaml'
              - '.github/workflows/tests.yaml'

      - name: Run Molecule tests
        if: steps.filter.outputs.molecule == 'true'
        run: make molecule
```

You can find more examples on how to use `paths-filter` [here](https://github.com/dorny/paths-filter#examples ).

#### Using `paths-ignore` gitea actions built-in feature

Note: at least till 2023-09-04 this path lead to some errors such as pipeline not being triggered on the first commit of a pull request even if the files that should trigger it were modified.

There are some expensive CI pipelines that don't need to be run for example if you changed a line in the `README.md`, to skip a pipeline on changes of certain files you can use the `paths-ignore` directive:

```yaml
---
name: Ansible Testing

"on":
  push:
    paths-ignore:
      - 'meta/**'
      - Makefile
      - README.md
      - renovate.json
      - CHANGELOG.md
      - .cz.toml
      - '.gitea/workflows/**'

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
        ...
```

The only downside is that if you set this pipeline as required in the branch protection, the merge button will look yellow instead of green when the pipeline is skipped.

### [Run jobs if other jobs failed](https://github.com/go-gitea/gitea/issues/23725)

This is useful to send notifications if any of the jobs failed.

[Right now](https://github.com/go-gitea/gitea/issues/23725) you can't run a job if other jobs fail, all you can do is add a last step on each workflow to do the notification on failure:

```yaml
- name: Send mail
    if: failure()
    uses: https://github.com/dawidd6/action-send-mail@v3
    with:
        to: ${{ secrets.MAIL_TO }}
        from: Gitea <gitea@hostname>
        subject: ${{ gitea.repository }} ${{gitea.workflow}} ${{ job.status }}
        priority: high
        convert_markdown: true
        html_body: |
            ### Job ${{ job.status }}

            ${{ github.repository }}: [${{ github.ref }}@${{ github.sha }}](${{ github.server_url }}/${{ github.repository }}/actions)
```

## [Disable the regular login, use only Oauth](https://discourse.gitea.io/t/solved-removing-default-login-interface/2740/2)

Inside your [`custom` directory](https://docs.gitea.io/en-us/customizing-gitea/) which may be `/var/lib/gitea/custom`:

* Create the directories `templates/user/auth`, 
* Create the `signin_inner.tmpl` file with the next contents. If it fails check [the latest version of the file](https://raw.githubusercontent.com/go-gitea/gitea/main/templates/user/auth/signin_inner.tmpl) and tweak it accordingly:
  ```jinja2
  {{if or (not .LinkAccountMode) (and .LinkAccountMode .LinkAccountModeSignIn)}}
  {{template "base/alert" .}}
  {{end}}
  <h4 class="ui top attached header center">
          {{if .LinkAccountMode}}
                  {{ctx.Locale.Tr "auth.oauth_signin_title"}}
          {{else}}
                  {{ctx.Locale.Tr "auth.login_userpass"}}
          {{end}}
  </h4>
  <div class="ui attached segment">
          <form class="ui form" action="{{.SignInLink}}" method="post">
          {{if .OAuth2Providers}}
          <div id="oauth2-login-navigator" class="gt-py-2">
                  <div class="gt-df gt-fc gt-jc">
                          <div id="oauth2-login-navigator-inner" class="gt-df gt-fc gt-fw gt-ac gt-gap-3">
                                  {{range $provider := .OAuth2Providers}}
                                          <a class="{{$provider.Name}} ui button gt-df gt-ac gt-jc gt-py-3 oauth-login-link" href="{{AppSubUrl}}/user/oauth2/{{$provider.DisplayName}}">
                                                  {{$provider.IconHTML 28}}
                                                  {{ctx.Locale.Tr "sign_in_with_provider" $provider.DisplayName}}
                                          </a>
                                  {{end}}
                          </div>
                  </div>
          </div>
          {{end}}
          </form>
  </div>
  ```
 
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

To import organisations and teams you need to use their `ID`. You can see the ID of the organisations in the Administration panel. To get the Teams ID you need to use the API. Go to https://your.gitea.com/api/swagger#/organization/orgListTeams and enter the organisation name.

## Create an admin user through the command line

```bash
gitea --config /etc/gitea/app.ini admin user create --admin --email email --username user_name --password password
```

Or you can change [the admin's password](https://discourse.gitea.io/t/how-to-change-gitea-admin-password-from-the-command-terminal-line/1930):

```bash
gitea --config /etc/gitea/app.ini admin user change-password -u username -p password
```

# [Gitea client command line tool](https://gitea.com/gitea/tea)

`tea` is a command line tool to interact with Gitea servers. It still lacks some features but is usable.

## [Installation](https://gitea.com/gitea/tea#installation)

- Download the precompiled binary from https://dl.gitea.com/tea/
- Until [#542](https://gitea.com/gitea/tea/issues/542) is fixed manually create a token with all the permissions
- Run `tea login add` to set your credentials.

# Troubleshooting

## [Fix Server does not allow request for unadvertised object error](https://github.com/go-gitea/gitea/issues/11958)
Fetching the whole history with fetch-depth: 0 worked for us:

```yaml
- name: Checkout the codebase
  uses: actions/checkout@v3
  with:
    fetch-depth: 0
```

# References

* [Home](https://gitea.io/en-us/)
* [Docs](https://docs.gitea.io/en-us/)

* [Terraform provider docs](https://registry.terraform.io/providers/Lerentis/gitea/latest/docs)
* [Terraform provider source code](https://github.com/Lerentis/terraform-provider-gitea)
