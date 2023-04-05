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
