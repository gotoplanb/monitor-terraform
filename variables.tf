variable "vercel_project_name" {
  description = "Name of the Vercel project"
  type        = string
  default     = "monitor-client"
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

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "monitor-api"
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

variable "lambda_runtime" {
  description = "Lambda runtime for Python"
  type        = string
  default     = "python3.11"
}

variable "lambda_memory" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "api_repository_url" {
  description = "Git repository URL for the API"
  type        = string
}

variable "api_repository_branch" {
  description = "Git branch to deploy"
  type        = string
  default     = "main"
}

variable "full_access_users" {
  description = "List of email addresses allowed to use all HTTP methods"
  type        = list(string)
  default     = []
}

variable "readonly_users" {
  description = "List of email addresses allowed to use only GET requests"
  type        = list(string)
  default     = []
}