.PHONY: all setup-state deploy-infrastructure setup-env cleanup get-state-info

# Include environment variables from .env file if it exists
-include .env

# Default target
all: setup-state deploy-infrastructure

# Verify required environment variables
verify-env:
	@echo "Verifying required environment variables..."
	@if [ -z "$(STATE_BUCKET_NAME)" ]; then \
		echo "ERROR: STATE_BUCKET_NAME is not set in .env file"; \
		exit 1; \
	fi
	@if [ -z "$(DYNAMODB_TABLE_NAME)" ]; then \
		echo "ERROR: DYNAMODB_TABLE_NAME is not set in .env file"; \
		exit 1; \
	fi
	@echo "Environment variables verified."

# Deploy Terraform state backend
setup-state: verify-env
	@echo "Setting up Terraform state backend..."
	@echo "Using state bucket name: $(STATE_BUCKET_NAME)"
	@echo "Using DynamoDB table name: $(DYNAMODB_TABLE_NAME)"
	cd terraform-state && \
		terraform init && \
		terraform apply -auto-approve \
			-var="state_bucket_name=$(STATE_BUCKET_NAME)" \
			-var="dynamodb_table_name=$(DYNAMODB_TABLE_NAME)"
	@echo "State backend created/updated."

# Update providers.tf with state backend info
update-backend: verify-env
	@echo "Updating backend configuration..."
	@echo "Using state bucket name: $(STATE_BUCKET_NAME)"
	@echo "Using DynamoDB table name: $(DYNAMODB_TABLE_NAME)"
	sed -i.bak 's/TERRAFORM_STATE_BUCKET_NAME/$(STATE_BUCKET_NAME)/g' providers.tf
	sed -i.bak 's/TERRAFORM_DYNAMODB_TABLE_NAME/$(DYNAMODB_TABLE_NAME)/g' providers.tf
	rm -f providers.tf.bak

# Deploy main infrastructure
deploy-infrastructure: verify-env update-backend
	@echo "Deploying main infrastructure..."
	terraform init && terraform apply -auto-approve
	@echo "Extracting infrastructure outputs..."
	$(eval API_GATEWAY_URL=$(shell terraform output -raw api_gateway_url 2>/dev/null || echo "N/A"))
	$(eval PROJECT_URL=$(shell terraform output -raw project_url 2>/dev/null || echo "N/A"))
	$(eval CLOUDFLARE_URL=$(shell terraform output -raw cloudflare_url 2>/dev/null || echo "N/A"))
	@echo "API Gateway URL: $(API_GATEWAY_URL)"
	@echo "Project URL: $(PROJECT_URL)"
	@echo "Cloudflare URL: $(CLOUDFLARE_URL)"
	@echo "Exporting values to .env.output file..."
	@echo "API_GATEWAY_URL=$(API_GATEWAY_URL)" > .env.output
	@echo "PROJECT_URL=$(PROJECT_URL)" >> .env.output
	@echo "CLOUDFLARE_URL=$(CLOUDFLARE_URL)" >> .env.output

# Update Vercel environment with API URL
update-vercel-env:
	@echo "Updating Vercel environment variables..."
	@if [ -f .env.output ]; then \
		API_GATEWAY_URL=$$(grep API_GATEWAY_URL .env.output | cut -d= -f2); \
		vercel env add NEXT_PUBLIC_API_BASE_URL "$$API_GATEWAY_URL" production; \
	else \
		echo "No .env.output file found."; \
	fi

# Cleanup
cleanup:
	@echo "Cleaning up temporary files..."
	@rm -f .env.output
	@rm -f providers.tf.bak

# Just get info from existing state
get-state-info: verify-env
	@echo "State bucket: $(STATE_BUCKET_NAME)"
	@echo "DynamoDB table: $(DYNAMODB_TABLE_NAME)"

# Show help
help:
	@echo "Available targets:"
	@echo "  verify-env             - Verify environment variables are set"
	@echo "  setup-state            - Deploy Terraform state backend"
	@echo "  update-backend         - Update providers.tf with state backend info"
	@echo "  deploy-infrastructure  - Deploy main infrastructure and export outputs"
	@echo "  update-vercel-env      - Update Vercel environment with API URL"
	@echo "  cleanup                - Clean up temporary files"
	@echo "  get-state-info         - Get info about state backend resources"
