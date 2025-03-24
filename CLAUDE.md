# CLAUDE.md - Monitor Terraform Guidelines

## Commands

- Init: `terraform init` - Initialize Terraform
- Plan: `terraform plan` - Preview changes
- Apply: `terraform apply` - Apply changes
- Destroy: `terraform destroy` - Destroy infrastructure
- Format: `terraform fmt` - Format Terraform files
- Validate: `terraform validate` - Validate Terraform files

## Project Structure

- `*.tf` - Terraform configuration files
- `terraform.tfvars` - Variable values
- `variables.tf` - Variable declarations
- `outputs.tf` - Output declarations
- `terraform-state/` - State management resources

## Code Style Guidelines

- Use consistent naming conventions
- Use modules for reusable infrastructure components
- Follow Terraform best practices for resource organization
- Document all variables with descriptions

## Infrastructure Components

- Cloudflare for DNS and edge functions
- Lambda for serverless functions
- SumoLogic for logging
- Vercel for frontend deployment

## Best Practices

- Use remote state with proper locking
- Use workspaces for different environments
- Implement proper secret management
- Test changes in non-production environments first