# [Protect sonarr behind authentik](https://docs.goauthentik.io/integrations/services/sonarr/)

We'll protect sonarr using it's HTTP Basic Auth behind authentik. To do that we need to save the Basic auth credentials into the `sonarr admin` group:

```terraform
resource "authentik_group" "sonarr_admin" {
  name         = "sonarr admin"
  is_superuser = false
  attributes = jsonencode(
    {
      sonarr_password = "<the password>"
      sonarr_user     = "<the user>"
    }
  )
  users = [
    data.authentik_user.<your_user>.id,
  ]
}
```

Then we'll configure the provider proxy to use these credentials.

```terraform
# ---------------
# -- Variables --
# ---------------

variable "sonarr_url" {
  type        = string
  description = "The url to access the service."
}

variable "sonarr_internal_url" {
  type        = string
  description = "The url authentik proxies the traffic to reach sonarr."
  default     = "http://sonarr:8989"
}

variable "sonarr_icon" {
  type        = string
  description = "The icon shown in the application"
  default     = "/application-icons/sonarr.svg"
}

# --------------------
# --    Provider    --
# --------------------

resource "authentik_provider_proxy" "sonarr" {
  name                          = "sonarr"
  internal_host                 = var.sonarr_internal_url
  external_host                 = var.sonarr_url
  authorization_flow            = data.authentik_flow.default-authorization-flow.id
  basic_auth_enabled            = true
  basic_auth_password_attribute = "sonarr_password"
  basic_auth_username_attribute = "sonarr_user"
  invalidation_flow             = data.authentik_flow.default-provider-invalidation-flow.id
  internal_host_ssl_validation  = false
  access_token_validity         = "minutes=120"
}

# -----------------------
# --    Application    --
# -----------------------

resource "authentik_application" "sonarr" {
  name              = "Sonarr"
  slug              = "sonarr"
  meta_icon         = var.sonarr_icon
  protocol_provider = authentik_provider_proxy.sonarr.id
  lifecycle {
    ignore_changes = [
      # The terraform provider is continuously changing the attribute even though it's set
      meta_icon,
    ]
  }
}

resource "authentik_policy_binding" "sonarr_admin" {
  target = authentik_application.sonarr.uuid
  group  = authentik_group.sonarr_admin.id
  order  = 1
}
resource "authentik_policy_binding" "sonarr_admin" {
  target = authentik_application.sonarr.uuid
  group  = authentik_group.admins.id
  order  = 1
}


resource "authentik_outpost" "default" {
  name               = "authentik Embedded Outpost"
  service_connection = authentik_service_connection_docker.local.id
  protocol_providers = [
    authentik_provider_proxy.sonarr.id,
  ]
}
```

If you try to copy paste the above terraform code you'll see that there are some missing resources, most of them are described [here](wg-easy.md)
