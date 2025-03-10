terraform {
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 1.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    sumologic = {
      source  = "SumoLogic/sumologic"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket         = "your-terraform-state-bucket-name"
    key            = "monitors/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "your-terraform-locks-table-name"
    encrypt        = true
  }
}

provider "vercel" {
  # API token can be provided via VERCEL_API_TOKEN environment variable
}

provider "cloudflare" {
  # API token can be provided via CLOUDFLARE_API_TOKEN environment variable
}

provider "sumologic" {
  # Credentials can be provided via environment variables:
  # SUMOLOGIC_ACCESSID and SUMOLOGIC_ACCESSKEY
} 