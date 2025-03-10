variable "vercel_project_name" {
  description = "Name of the Vercel project"
  type        = string
  default     = "monitors-client"
}

variable "framework" {
  description = "Framework preset for the project"
  type        = string
  default     = "nextjs"
}

variable "git_repository" {
  description = "Git repository URL"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Vercel project"
  type        = map(string)
  default = {
    NEXT_PUBLIC_API_BASE_URL = "https://your-api-url.com"  # Update this with your actual API URL
  }
}

variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the application"
  type        = string
  default     = "monitors"
}

variable "zero_trust_organization_name" {
  description = "Cloudflare Zero Trust organization name"
  type        = string
}

variable "allowed_users" {
  description = "List of email addresses allowed to access the application"
  type        = list(string)
  default     = []
}

variable "zero_trust_auth_domain" {
  description = "Authentication domain for Zero Trust"
  type        = string
}

variable "monitor_name" {
  description = "Name of the Sumo Logic monitor"
  type        = string
  default     = "API Health Monitor"
}

variable "monitor_query" {
  description = "Search query for the monitor"
  type        = string
  default     = "_sourceCategory=production/api/health | json \"status\", \"timestamp\" | where status != \"ok\""
}

variable "monitor_time_range" {
  description = "Time range for the monitor evaluation"
  type        = string
  default     = "-5m"
}

variable "notification_email" {
  description = "Email address for monitor notifications"
  type        = string
} 