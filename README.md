# monitors-terraform

## Using the Makefile (Recommended)

1. Copy the example environment file and fill in your credentials:
   ```
   cp .env.example .env
   # Edit .env with your credentials
   ```

2. Run the entire deployment process with a single command:
   ```
   make
   ```

   This will:
   - Set up the Terraform state backend in AWS
   - Configure the main Terraform backend to use this state
   - Deploy all infrastructure components
   - Export outputs to an .env.output file

3. Update Vercel environment variables with API URL:
   ```
   make update-vercel-env
   ```

For more options, run:
```
make help
```

## Manual Setup (Alternative)

### Setup state

1. update ./terraform-state/terraform.tfvars
1. export AWS_ACCESS_KEY_ID="your_access_key"
1. export AWS_SECRET_ACCESS_KEY="your_secret_key"
1. export AWS_REGION="us-east-1"
1. cd monitors-terraform/terraform-state
1. terraform init
1. terraform apply

### Run the other stuff

1. Update the backend configuration in providers.tf with your state bucket and DynamoDB table:
   ```
   backend "s3" {
     bucket         = "your-state-bucket-name"
     key            = "monitors/terraform.tfstate"
     region         = "your-aws-region"
     dynamodb_table = "your-dynamodb-table-name"
     encrypt        = true
   }
   ```
1. export VERCEL_API_TOKEN="your_token_here"
1. export CLOUDFLARE_API_TOKEN="your_cloudflare_token"
1. export SUMOLOGIC_ACCESSID="your-access-id"
1. export SUMOLOGIC_ACCESSKEY="your-access-key"
1. export AWS_ACCESS_KEY_ID="your_access_key"
1. export AWS_SECRET_ACCESS_KEY="your_secret_key"
1. export AWS_REGION="us-east-1"
1. cd monitors-terraform
1. terraform init
1. terraform apply

## Required AWS IAM Permissions

Create an IAM policy named something like `monitor-terraform-state-policy` with content:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:Get*",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:DeleteBucket",
                "s3:CreateBucket",
                "s3:PutBucketVersioning",
                "s3:PutEncryptionConfiguration"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:CreateTable",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteTable",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:DescribeContinuousBackups",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:ListTagsOfResource"
            ],
            "Resource": [
                "arn:aws:dynamodb:*:*:table/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:CreateFunction",
                "lambda:GetFunction",
                "lambda:UpdateFunctionCode",
                "lambda:UpdateFunctionConfiguration",
                "lambda:DeleteFunction",
                "lambda:AddPermission",
                "lambda:RemovePermission"
            ],
            "Resource": [
                "arn:aws:lambda:*:*:function:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:GetRole",
                "iam:PassRole"
            ],
            "Resource": [
                "arn:aws:iam::*:role/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "apigateway:*"
            ],
            "Resource": [
                "arn:aws:apigateway:*::*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups"
            ],
            "Resource": [
                "arn:aws:logs:*:*:*"
            ]
        }
    ]
}
```

Create a user named something like `monitor-terraform-state-user` and attach that policy.

For production environments, consider using more restrictive policies limited to specific resources.

Create an access key named something like `monitor-terraform-state-key` for local app use.