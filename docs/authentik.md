
[Authentik](https://goauthentik.io/) is an open-source Identity Provider focused on flexibility and versatility.

What I like:

* Is maintained and popular
* It has a clean interface
* They have their own [terraform provider](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs/resources/application) Oo!

What I don't like:

* It's heavy focused on GUI interaction, but you can export the configuration to YAML files to be applied without the GUI interaction.

* The documentation is oriented to developers and not users. It's a little difficult to get a grasp on how to do things in the platform without following blog posts.

# [Installation](https://goauthentik.io/docs/installation)

You can install it with Kubernetes or with `docker-compose`. I'm going to do the second.

Download the latest `docker-compose.yml` from [here](https://goauthentik.io/docker-compose.yml). Place it in a directory of your choice.

If this is a fresh authentik install run the following commands to generate a password:

```bash
# You can also use openssl instead: `openssl rand -base64 36`
sudo apt-get install -y pwgen
# Because of a PostgreSQL limitation, only passwords up to 99 chars are supported
# See https://www.postgresql.org/message-id/09512C4F-8CB9-4021-B455-EF4C4F0D55A0@amazon.com
echo "PG_PASS=$(pwgen -s 40 1)" >> .env
echo "AUTHENTIK_SECRET_KEY=$(pwgen -s 50 1)" >> .env
```

It is also recommended to configure global email credentials. These are used by authentik to notify you about alerts and configuration issues. They can also be used by Email stages to send verification/recovery emails.

Append this block to your .env file

```bash
# SMTP Host Emails are sent to
AUTHENTIK_EMAIL__HOST=localhost
AUTHENTIK_EMAIL__PORT=25
# Optionally authenticate (don't add quotation marks to your password)
AUTHENTIK_EMAIL__USERNAME=
AUTHENTIK_EMAIL__PASSWORD=
# Use StartTLS
AUTHENTIK_EMAIL__USE_TLS=false
# Use SSL
AUTHENTIK_EMAIL__USE_SSL=false
AUTHENTIK_EMAIL__TIMEOUT=10
# Email address authentik will send from, should have a correct @domain
AUTHENTIK_EMAIL__FROM=authentik@localhost
```

By default, authentik listens on port 9000 for HTTP and 9443 for HTTPS. To change this, you can set the following variables in .env:

```bash
AUTHENTIK_PORT_HTTP=80
AUTHENTIK_PORT_HTTPS=443
```

You may need to tweak the `volumes` and the `networks` sections of the `docker-compose.yml` to your liking.

Once everything is set you can run `docker-compose up` to test everything is working.

In your browser, navigate to authentik’s initial setup page https://auth.home.yourdomain.com/if/flow/initial-setup/.

Set the email and password for the default admin user, `akadmin`. You’re now logged in.

# Configuration

## [Terraform](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs)

You can use [`terraform`](terraform.md) to configure authentik! `<3`.

### [Configure the provider](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs#configure-provider-with-environment-variables)

To configure the provider you need to specify the url and an Authentik API token, keeping in mind that whoever gets access to this information will have access and full permissions on your Authentik instance it's critical that [you store this information well](terraform.md#sensitive-information). We'll use [`sops` to encrypt the token with GPG.](#sensitive-information-in-the-terraform-source-code).

First create an Authentik user under `Admin interface/Directory/Users` with the next attributes:

* Username: `terraform`
* Name: `Terraform`
* Path: `infra`
* Groups: `Admin`

Then create a token with name `Terraform` under `Directory/Tokens & App passwords`, copy it to your clipboard.

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
  "authentik_token": "paste the token here"
}
```

```hcl
terraform {
  required_providers {
    authentik = {
      source = "goauthentik/authentik"
      version = "~> 2023.1.1"
    }
    sops = {
      source = "carlpett/sops"
      version = "~> 0.5"
    }
  }
}

provider "authentik" {
  url   = "https://oauth.your-domain.org"
  token = data.sops_file.secrets.data["authentik_token"]
}
```

## [Configure some common applications](https://goauthentik.io/integrations/)

You have some guides to connect [some popular applications](https://goauthentik.io/integrations/)

### [Gitea](https://goauthentik.io/integrations/services/gitea/)

You can follow the [Authentik Gitea docs](https://goauthentik.io/integrations/services/gitea/) or you can use the next terraform snippet:

```hcl
# ----------------
# --    Data    --
# ----------------

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

# -----------------------
# --    Application    --
# -----------------------

resource "authentik_application" "gitea" {
  name              = "Gitea"
  slug              = "gitea"
  protocol_provider = authentik_provider_oauth2.gitea.id
  meta_icon = "application-icons/gitea.svg"
  lifecycle {
    ignore_changes = [
      # The terraform provider is continuously changing the attribute even though it's set
      meta_icon,
    ]
  }
}

# --------------------------
# --    Oauth provider    --
# --------------------------

resource "authentik_provider_oauth2" "gitea" {
  name               = "Gitea"
  client_id = "gitea"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  property_mappings = [
    authentik_scope_mapping.gitea.id,
    data.authentik_scope_mapping.email.id,
    data.authentik_scope_mapping.openid.id,
    data.authentik_scope_mapping.profile.id,
  ]
  redirect_uris = [
    "https://git.your-domain.org/user/oauth2/authentik/callback",
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
}

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

# -------------------------
# --    Scope mapping    --
# -------------------------

resource "authentik_scope_mapping" "gitea" {
  name       = "Gitea"
  scope_name = "gitea"
  expression = <<EOF
gitea_claims = {}
if request.user.ak_groups.filter(name="Users").exists():
    gitea_claims["gitea"]= "user"
if request.user.ak_groups.filter(name="Admins").exists():
    gitea_claims["gitea"]= "admin"

return gitea_claims
EOF
}

data "authentik_scope_mapping" "email" {
  managed = "goauthentik.io/providers/oauth2/scope-email"
}

data "authentik_scope_mapping" "openid" {
  managed = "goauthentik.io/providers/oauth2/scope-openid"
}

data "authentik_scope_mapping" "profile" {
  managed = "goauthentik.io/providers/oauth2/scope-profile"
}

# -------------------
# --    Outputs    --
# -------------------

output "gitea_oauth_id" {
  value = authentik_provider_oauth2.gitea.client_id
}

output "gitea_oauth_secret" {
  value = authentik_provider_oauth2.gitea.client_secret
}
```

It assumes that:

* You've changed `git.your-domain.org` with your gitea domain.
* The gitea logo is mounted in the docker directory `/media/application-icons/gitea.svg`.

Gitea can be configured through terraform too. There is an [official provider](https://gitea.com/gitea/terraform-provider-gitea/src/branch/main) that doesn't work, there's a [fork that does though[(https://registry.terraform.io/providers/Lerentis/gitea/latest/docs). Sadly it doesn't yet support configuring Oauth Authentication sources. So you'll need to configure it manually.

Be careful [`gitea_oauth2_app`](https://registry.terraform.io/providers/Lerentis/gitea/latest/docs/resources/oauth2_app) looks to be the right resource to do that, but instead it configures Gitea to be the Oauth provider, not a consumer.

## [Configure the invitation flow](https://yewtu.be/watch?v=mGOTpRfulfQ)

Let's assume that we have two groups (Admins and Users) created under `Directory/Groups` and that we want to configure an invitation link for a user to be added directly on the `Admins` group.

Authentik works by defining Stages and Flows. Stages are the steps you need to follow to complete a procedure, and a flow is the procedure itself.

You create Stages by:
* Going to the Admin interface
* Going to Flows & Stages/Stages
* Click on Create

To be able to complete the invitation through link we need to define the next stages:

* An Invitation Stage: This stage represents the moment an admin chooses to create an invitation for a user. 
  Graphically you would need to:

  * Click on Create
  * Select Invitation Stage
  * Fill the form with the next data:
    * Name: enrollment-invitation
    * Uncheck the `Continue flow without invitation` as we don't want users to be able to register without the invitation.
  * Click Finish

  Or use the next terraform snippet:

  ```terraform
  resource "authentik_stage_invitation" "default" {
    name                             = "enrollment-invitation"
    continue_flow_without_invitation = false
  }
  ```

* An User Write Stage: This is when the user will be created but it won't show up as the username and password are not yet selected.
  Graphically you would need to:

    * Click on Create
    * Select User Write Stage
    * Click on Next
    * Fill the form with the next data:
      * Name: enrollment-invitation-admin-write
      * Enable the `Can Create Users` flag.
      * If you want users to validate their email leave "Create users as inactive" enabled, otherwise disable it.
      * Select the group you want the user to be added to. I don't [yet know how to select more than one group](https://github.com/goauthentik/authentik/issues/2098)
      * Click on Finish

  Or use the next terraform snippet:

  ```terraform
  resource "authentik_stage_user_write" "admin_write" {
    name                     = "enrollment-invitation-admin-write"
    create_users_as_inactive = true
    create_users_group       = authentik_group.admins.id
  }
  ```

  Where `authentik_group.admin` is defined as:

  ```terraform
  resource "authentik_group" "admins" {
    name         = "Admins"
    is_superuser = true
    users = [
      data.authentik_user.user_1.id,
      data.authentik_user.user_2.id,
    ]
  }

  data "authentik_user" "user_1" {
    username = "user_1"
  }

  data "authentik_user" "user_2" {
    username = "user_2"
  }
  ```

* Email Confirmation Stage: This is when the user gets an email to confirm that it has access to it

  Graphically you would need to:

  * Click on Create
  * Select Email Stage
  * Click on Next
    * Name: email-account-confirmation
    * Subject: Account confirmation
    * Template: Account confirmation
  * Click on Finish

  Or use the next terraform snippet:

  ```terraform
  resource "authentik_stage_email" "account_confirmation" {
    name                     = "email-account-confirmation"
    activate_user_on_success = true
    subject                  = "Authentik Account Confirmation"
    template                 = "email/account_confirmation.html"
    timeout                  = 10
  }
  ```

Create the invitation Flow:

  Graphically you would need to:

  * Go to `Flows & Stages/Flows`
  * Click on Create
  * Fill the form with the next data:
    * Name: Enrollment Invitation Admin
    * Title: Enrollment Invitation Admin
    * Designation: Enrollment
    * Unfold the Behavior settings to enable the Compatibility mode
  * Click Create

  Or use the next terraform snippet:

  ```terraform
  resource "authentik_flow" "enrollment_admin" {
    name        = "Enrollment invitation admin"
    title       = "Enrollment invitation admin"
    slug        = "enrollment-invitation-admin"
    designation = "enrollment"
  }
  ```

We need to define how the flow is going to behave by adding the different the stage bindings:

* Bind the Invitation admin stage:

  Graphically you would need to:

  * Click on the flow we just created `enrollment-invitation-admin`
  * Click on `Stage Bindings`
  * Click on `Bind Stage`
  * Fill the form with the next data:
    * Stage: select `enrollment-invitation-admin`
    * Order: 10
  * Click Create

  Or use the next terraform snippet:

  ```terraform
  resource "authentik_flow_stage_binding" "invitation_creation" {
    target = authentik_flow.enrollment_admin.uuid
    stage  = authentik_stage_invitation.default.id
    order  = 10
  }
  ```

* Bind the Enrollment prompt stage: This is a builtin stage where the user is asked for their login information

  Graphically you would need to:

  * Click on `Bind Stage`
  * Fill the form with the next data:
    * Stage: select `default-source-enrollment-prompt`
    * Order: 20
  * Click Create
  * Click Edit Stage and configure it wit:
    * On the fields select: 
      * username
      * name
      * email
      * password
      * password_repeat
    * Select the validation policy you have one

  Or use the next terraform snippet:

  ```terraform
  resource "authentik_stage_prompt" "user_data" {
    name = "enrollment-user-data-prompt"
    fields = [ 
        authentik_stage_prompt_field.username.id,
        authentik_stage_prompt_field.name.id,
        authentik_stage_prompt_field.email.id,
        authentik_stage_prompt_field.password.id,
        authentik_stage_prompt_field.password_repeat.id,
    ]
  }

  resource "authentik_stage_prompt_field" "username" {
    field_key = "username"
    label     = "Username"
    type      = "text"
    order = 200
    placeholder = <<EOT
  try:
      return user.username
  except:
      return ''
  EOT
    placeholder_expression = true
    required = true
  }

  resource "authentik_stage_prompt_field" "name" {
    field_key = "name"
    label     = "Name"
    type      = "text"
    order = 201
    placeholder = <<EOT
  try:
      return user.name
  except:
      return ''
  EOT
    placeholder_expression = true
    required = true
  }

  resource "authentik_stage_prompt_field" "email" {
    field_key = "email"
    label     = "Email"
    type      = "email"
    order = 202
    placeholder = <<EOT
  try:
      return user.email
  except:
      return ''
  EOT
    placeholder_expression = true
    required = true
  }

  resource "authentik_stage_prompt_field" "password" {
    field_key = "password"
    label     = "Password"
    type      = "password"
    order = 300
    placeholder = "Password"
    placeholder_expression = false
    required = true
  }

  resource "authentik_stage_prompt_field" "password_repeat" {
    field_key = "password_repeat"
    label     = "Password (repeat)"
    type      = "password"
    order = 301
    placeholder = "Password (repeat)"
    placeholder_expression = false
    required = true
  }
  ```

  We had to redefine all the `authentik_stage_prompt_field` because the terraform provider doesn't yet support [the `data` resource of the `authentik_stage_prompt_field`](https://github.com/goauthentik/terraform-provider-authentik/issues/243)

* Bind the User write stage:

  Graphically you would need to:

  * Click on `Bind Stage`
  * Fill the form with the next data:
    * Stage: select `enrollment-invitation-admin-write`
    * Order: 30
  * Click Create

  Or use the next terraform snippet:

  ```terraform
  resource "authentik_flow_stage_binding" "invitation_user_write" {
    target = authentik_flow.enrollment_admin.uuid
    stage  = authentik_stage_user_write.admin_write.id
    order  = 30
  }
  ```

* Bind the email account confirmation stage: 

  Graphically you would need to:

  * Click on `Bind Stage`
  * Fill the form with the next data:
    * Stage: select `email-account-confirmation`
    * Order: 40
  * Click Create
  * Edit the stage and make sure that you have enabled:
    * Activate pending user on success
    * Use global settings
  * Click Update

  Or use the next terraform snippet:

  ```terraform
  resource "authentik_flow_stage_binding" "invitation_account_confirmation" {
    target = authentik_flow.enrollment_admin.uuid
    stage  = authentik_stage_email.account_confirmation.id
    order  = 40
  }
  ```

* Bind the User login stage: This is a builtin stage where the user is asked to log in

  Graphically you would need to:

  * Click on `Bind Stage`
  * Fill the form with the next data:
    * Stage: select `default-source-enrollment-login`
    * Order: 50
  * Click Create

  Or use the next terraform snippet:
  
  ```terraform
  resource "authentik_flow_stage_binding" "invitation_login" {
    target = authentik_flow.enrollment_admin.uuid
    stage  = data.authentik_stage.default_source_enrollment_login.id
    order  = 50
  }
  ```

## [Configure password recovery](https://www.youtube.com/watch?v=NKJkYz0BIlA)

Recovery of password is not enabled by default, to configure it you need to create two new stages:

* An identification stage:
  
  ```terraform
  data "authentik_source" "built_in" {
    managed = "goauthentik.io/sources/inbuilt"
  }

  resource "authentik_stage_identification" "recovery" {
    name           = "recovery-authentication-identification"
    user_fields    = ["username", "email"]
    sources = [data.authentik_source.built_in.uuid]
    case_insensitive_matching = true
  }
  ```

* An Email recovery stage: 

  ```terraform
  resource "authentik_stage_email" "recovery" {
    name                     = "recovery-email"
    activate_user_on_success = true
    subject                  = "Password Recovery"
    template                 = "email/password_reset.html"
    timeout                  = 10
  }
  ```

* We will reuse two existing stages too:
  
  ```terraform
  data "authentik_stage" "default_password_change_prompt" {
    name = "default-password-change-prompt"
  }

  data "authentik_stage" "default_password_change_write" {
    name = "default-password-change-write"
  }
  ```

Then we need to create the recovery flow and bind all the stages:

```terraform
resource "authentik_flow" "password_recovery" {
  name        = "Password Recovery"
  title       = "Password Recovery"
  slug        = "password-recovery"
  designation = "recovery"
}

resource "authentik_flow_stage_binding" "recovery_identification" {
  target = authentik_flow.password_recovery.uuid
  stage  = authentik_stage_identification.recovery.id
  order  = 0
}

resource "authentik_flow_stage_binding" "recovery_email" {
  target = authentik_flow.password_recovery.uuid
  stage  = authentik_stage_email.recovery.id
  order  = 10
}

resource "authentik_flow_stage_binding" "recovery_password_change" {
  target = authentik_flow.password_recovery.uuid
  stage  = data.authentik_stage.default_password_change_prompt.id
  order  = 20
}

resource "authentik_flow_stage_binding" "recovery_password_write" {
  target = authentik_flow.password_recovery.uuid
  stage  = data.authentik_stage.default_password_change_write.id
  order  = 30
}
```

Finally we need to enable it in the site's authentication flow. To be able to do change the default flow we'd need to do two manual steps, so to have all the code in terraform we will create a new tenancy for our site and a new authentication flow.

Starting with the authentication flow we need to create the Flow, stages and stage bindings.

```terraform
# -----------
# -- Flows --
# -----------

resource "authentik_flow" "authentication" {
  name        = "Welcome to Authentik!"
  title        = "Welcome to Authentik!"
  slug        = "custom-authentication-flow"
  designation = "authentication"
  authentication = "require_unauthenticated"
  compatibility_mode = false
}

# ------------
# -- Stages --
# ------------

resource "authentik_stage_identification" "authentication" {
  name           = "custom-authentication-identification"
  user_fields    = ["username", "email"]
  password_stage = data.authentik_stage.default_authentication_password.id
  case_insensitive_matching = true
  recovery_flow = authentik_flow.password_recovery.uuid
}

data "authentik_stage" "default_authentication_mfa_validation" {
  name = "default-authentication-mfa-validation"
}

data "authentik_stage" "default_authentication_login" {
  name = "default-authentication-login"
}

data "authentik_stage" "default_authentication_password" {
  name = "default-authentication-password"
}

# -------------------
# -- Stage binding --
# -------------------

resource "authentik_flow_stage_binding" "login_identification" {
  target = authentik_flow.authentication.uuid
  stage  = authentik_stage_identification.authentication.id
  order  = 10
}

resource "authentik_flow_stage_binding" "login_mfa" {
  target = authentik_flow.authentication.uuid
  stage  = data.authentik_stage.default_authentication_mfa_validation.id
  order  = 20
}

resource "authentik_flow_stage_binding" "login_login" {
  target = authentik_flow.authentication.uuid
  stage  = data.authentik_stage.default_authentication_login.id
  order  = 30
}
```

Now we can bind it to the new tenant for our site:

```terraform
# ------------
# -- Tenant --
# ------------

resource "authentik_tenant" "default" {
  domain         = "your-domain.org"
  default        = false
  branding_title = "Authentik"
  branding_logo = "/static/dist/assets/icons/icon_left_brand.svg"
  branding_favicon = "/static/dist/assets/icons/icon.png"
  flow_authentication = authentik_flow.authentication.uuid
  # We need to define id instead of uuid until 
  # https://github.com/goauthentik/terraform-provider-authentik/issues/305
  # is fixed.
  flow_invalidation = data.authentik_flow.default_invalidation_flow.id
  flow_user_settings = data.authentik_flow.default_user_settings_flow.id
  flow_recovery = authentik_flow.password_recovery.uuid
}

# -----------
# -- Flows --
# -----------

data "authentik_flow" "default_invalidation_flow" {
  slug = "default-invalidation-flow"
}

data "authentik_flow" "default_user_settings_flow" {
  slug = "default-user-settings-flow"
}
```

## [Hide and application from a user](https://goauthentik.io/docs/applications#authorization)

Application access can be configured using (Policy) Bindings. Click on an application in the applications list, and select the Policy / Group / User Bindings tab. There you can bind users/groups/policies to grant them access. When nothing is bound, everyone has access. You can use this to grant access to one or multiple users/groups, or dynamically give access using policies.

With terraform you can use `authentik_policy_binding`, for example:

```terraform
resource "authentik_policy_binding" "admin" {
  target = authentik_application.gitea.uuid
  group  = authentik_group.admins.id
  order  = 0
}
```

## [Protect applications that don't have authentication](https://piotrkrzyzek.com/how-to-setup-use-authentik-with-simple-forward-proxy/)

Some applications don't have authentication, for example [prometheus](prometheus.md). You can use Authentik in front of such applications to add the authentication and authorization layer.

Authentik can be used as a (very) simple reverse proxy by using its Provider feature with the regular "Proxy" setting. This let's you wrap authentication around a sub-domain / app where it normally wouldn't have authentication (or not the type of auth that you would specifically want) and then have Authentik handle the proxy forwarding and Auth.

In this mode, there is no domain level nor 'integrated' authentication into your desired app; Authentik becomes both your reverse proxy and auth for this one particular app or (sub) domain. This mode does not forward authentication nor let you log in into any app. It's just acts like an authentication wrapper.

It's best to use a normal reverse proxy out front of Authentik. This adds a second layer of routing to deal with but Authentik is not NGINX or a reverse proxy system, so it does not have that many configuration options. 

We'll use the following fake domains in this example:

- Authentik domain: auth.yourdomain.com
- App domain: app.yourdomain.com
- Nginx: nginx.yourdomain.com
- Authentik's docker conter name: auth_server

The steps are:

- Configure the proxy provider:

  ```terraform
  # ---------------
  # -- Variables --
  # ---------------

  variable "prometheus_url" {
    type        = string
    description = "The url to access the service."
  }

  # ----------
  # -- Data --
  # ----------

  data "authentik_flow" "default-authorization-flow" {
    slug = "default-provider-authorization-implicit-consent"
  }

  # --------------------
  # --    Provider    --
  # --------------------

  resource "authentik_provider_proxy" "prometheus" {
    name               = "Prometheus"
    internal_host      = "http://prometheus:9090"
    external_host      = var.prometheus_url
    authorization_flow = data.authentik_flow.default-authorization-flow.id
    internal_host_ssl_validation = false
  }
  ```

- Configure the application:

  

## [Use blueprints](https://goauthentik.io/developer-docs/blueprints/)

WARNING: [Use the `terraform` provider instead!!!](#terraform)

Blueprints offer a new way to template, automate and distribute authentik configuration. Blueprints can be used to automatically configure instances, manage config as code without any external tools, and to distribute application configs.

Blueprints are yaml files, whose format is described further in [File structure](https://goauthentik.io/developer-docs/blueprints/v1/structure) and uses [YAML tags](https://goauthentik.io/developer-docs/blueprints/v1/tags) to configure the objects. It can be complicated when you first look at it, reading [this example](https://goauthentik.io/developer-docs/blueprints/v1/example) may help.

Blueprints can be applied in one of two ways:

* As a Blueprint instance, which is a YAML file mounted into the authentik (worker) container. This file is read and applied every time it changes. Multiple instances can be created for a single blueprint file, and instances can be given context key:value attributes to configure the blueprint.
* As a Flow import, which is a YAML file uploaded via the Browser/API. This file is validated and applied directly after being uploaded, but is not further monitored/applied.

The authentik container by default looks for blueprints in `/blueprints`. Underneath this directory, there are a couple default subdirectories:

* `/blueprints/default`: Default blueprints for default flows, tenants, etc
* `/blueprints/example`: Example blueprints for common configurations and flows
* `/blueprints/system`: System blueprints for authentik managed Property mappings, etc

Any additional `.yaml` file in /blueprints will be discovered and automatically instantiated, depending on their labels.

To disable existing blueprints, an empty file can be mounted over the existing blueprint.

File-based blueprints are automatically removed once they become unavailable, however none of the objects created by those blueprints are affected by this.

### [Export blueprints](https://goauthentik.io/developer-docs/blueprints/export)

Exports from either method will contain a (potentially) long list of objects, all with hardcoded primary keys and no ability for templating/instantiation. This is because currently, authentik does not check which primary keys are used where. It is assumed that for most exports, there'll be some manual changes done regardless, to filter out unwanted objects, adjust properties, etc. That's why it may be better to use the [flow export](#flow-export) for the resources you've created rather than the [global export](#global-export).

#### Global export

To migrate existing configurations to blueprints, run `ak export_blueprint` within any authentik Worker container. This will output a blueprint for most currently created objects. Some objects will not be exported as they might have dependencies on other things.

Exported blueprints don't use any of the YAML Tags, they just contain a list of entries as they are in the database.

Note that fields which are write-only (for example, OAuth Provider's Secret Key) will not be added to the blueprint, as the serialisation logic from the API is used for blueprints.

Additionally, default values will be skipped and not added to the blueprint.

#### Flow export

Instead of exporting everything from a single instance, there's also the option to export a single flow with it's attached stages, policies and other objects.

This export can be triggered via the API or the Web UI by clicking the download button in the flow list.


# References

* [Source](https://github.com/goauthentik/authentik)
* [Docs](https://goauthentik.io/docs/)
* [Home](https://goauthentik.io/)

* [Terraform provider docs](https://registry.terraform.io/providers/goauthentik/authentik/latest/docs)
* [Terraform provider source code](https://github.com/goauthentik/terraform-provider-authentik)
