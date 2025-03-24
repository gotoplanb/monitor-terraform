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
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "monitor-state-1742753260"
    key            = "monitor/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "monitor-state-1742753260"
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

provider "aws" {
  region = var.aws_region
} 