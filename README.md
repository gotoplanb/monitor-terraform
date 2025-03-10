# monitors-terraform

## Setup state

1. export state_bucket_name 
1. export dynamodb_table_name
1. cd monitors-terraform/terraform-state
1. terraform init
1. terraform apply

## Run the other stuff

1. export VERCEL_API_TOKEN="your_token_here"
1. export CLOUDFLARE_API_TOKEN="your_cloudflare_token"
1. export SUMOLOGIC_ACCESSID="your-access-id"
1. export SUMOLOGIC_ACCESSKEY="your-access-key"
1. cd monitors-terraform
1. terraform init
1. terraform apply