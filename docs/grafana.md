[Grafana](https://grafana.com/grafana) is a web application to create dashboards.

# [Installation](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/#run-grafana-via-docker-compose)

We're going to install it with docker-compose and connect it to [Authentik](authentik.md).

## [Create the Authentik connection](https://goauthentik.io/integrations/services/grafana/)

Assuming that you have [the terraform authentik provider configured](authentik.md), use the next terraform code:

```hcl
# ---------------
# -- Variables --
# ---------------

variable "grafana_name" {
  type        = string
  description = "The name shown in the Grafana application."
  default     = "Grafana"
}

variable "grafana_redirect_uri" {
  type        = string
  description = "The redirect url configured on Grafana."
}

variable "grafana_icon" {
  type        = string
  description = "The icon shown in the Grafana application"
  default     = "/application-icons/grafana.svg"
}

# -----------------------
# --    Application    --
# -----------------------

resource "authentik_application" "grafana" {
  name              = var.grafana_name
  slug              = "grafana"
  protocol_provider = authentik_provider_oauth2.grafana.id
  meta_icon         = var.grafana_icon
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

resource "authentik_provider_oauth2" "grafana" {
  name               = var.grafana_name
  client_id          = "grafana"
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  property_mappings = [
    data.authentik_scope_mapping.email.id,
    data.authentik_scope_mapping.openid.id,
    data.authentik_scope_mapping.profile.id,
  ]
  redirect_uris = [
    var.grafana_redirect_uri,
  ]
  signing_key = data.authentik_certificate_key_pair.default.id
  access_token_validity = "minutes=120"
}

data "authentik_certificate_key_pair" "default" {
  name = "authentik Self-signed Certificate"
}

data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

# -------------------
# --    Outputs    --
# -------------------

output "grafana_oauth_id" {
  value = authentik_provider_oauth2.grafana.client_id
}

output "grafana_oauth_secret" {
  value = authentik_provider_oauth2.grafana.client_secret
}
```

You'll need to upload the `grafana.svg` to your authentik application
you can use the next docker-compose file

```yaml
```

# References

- [Home](https://grafana.com/grafana)
