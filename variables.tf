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