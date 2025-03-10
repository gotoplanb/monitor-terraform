terraform {
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 2.0"
    }
  }
}

provider "vercel" {
  # API token can be provided via VERCEL_API_TOKEN environment variable
} 