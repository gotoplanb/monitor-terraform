# DNS Record for the application
resource "cloudflare_record" "app" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  value   = vercel_project_domain.domain.domain
  type    = "CNAME"
  proxied = true
}

# Zero Trust Application
resource "cloudflare_access_application" "app" {
  zone_id                   = var.cloudflare_zone_id
  name                      = "Monitors Application"
  domain                    = "${var.subdomain}.${var.domain_name}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

# Policy for users with full access (all HTTP methods)
resource "cloudflare_access_policy" "allow_full_access" {
  application_id = cloudflare_access_application.app.id
  zone_id       = var.cloudflare_zone_id
  name          = "Allow full access users"
  precedence    = "1"
  decision      = "allow"

  include {
    email = var.full_access_users
  }
}

# Policy for read-only users (GET requests only)
resource "cloudflare_access_policy" "allow_readonly_access" {
  application_id = cloudflare_access_application.app.id
  zone_id       = var.cloudflare_zone_id
  name          = "Allow read-only users"
  precedence    = "2"
  decision      = "allow"

  include {
    email = var.readonly_users
  }

  # Only allow GET requests
  require {
    request {
      methods = ["GET"]
    }
  }
}

# Deny all other requests from read-only users
resource "cloudflare_access_policy" "deny_readonly_users_non_get" {
  application_id = cloudflare_access_application.app.id
  zone_id       = var.cloudflare_zone_id
  name          = "Deny non-GET requests for read-only users"
  precedence    = "3"
  decision      = "deny"

  include {
    email = var.readonly_users
  }
}

# Identity Provider Configuration (using Cloudflare as IdP)
resource "cloudflare_access_identity_provider" "cloudflare_idp" {
  zone_id = var.cloudflare_zone_id
  name    = "Cloudflare IdP"
  type    = "onetimepin"
}

# Zero Trust Authentication Domain
resource "cloudflare_access_organization" "org" {
  name            = var.zero_trust_organization_name
  auth_domain     = var.zero_trust_auth_domain
  is_ui_read_only = false
} 