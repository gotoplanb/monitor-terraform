# Create a temporary directory for cloning
resource "null_resource" "clone_repo" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
      set -e  # Exit on any error
      rm -rf /tmp/monitor-api || true
      git clone ${var.api_repository_url} /tmp/monitor-api || exit 1
      cd /tmp/monitor-api || exit 1
      git checkout ${var.api_repository_branch} || exit 1
      python3.13 -m pip install --platform manylinux2014_x86_64 --target . --implementation cp --python-version 3.13 --only-binary=:all: -r requirements.txt || exit 1
      zip -r /tmp/lambda_function.zip . || exit 1
    EOF
  }
}

# Output file for trigger
resource "local_file" "lambda_zip_trigger" {
  depends_on = [null_resource.clone_repo]
  filename = "${path.module}/lambda_zip_created.txt"
  content  = "Lambda zip created at ${timestamp()}"
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "api" {
  filename         = "/tmp/lambda_function.zip"
  function_name    = var.lambda_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "app.main.handler"
  source_code_hash = local_file.lambda_zip_trigger.content_md5  # Use this as a trigger instead
  runtime         = "python3.13"
  memory_size     = 256  # Recommend at least 256MB for FastAPI
  timeout         = 30   # Increase timeout to handle potential Supabase latency

  depends_on = [
    null_resource.clone_repo,
    local_file.lambda_zip_trigger
  ]

  environment {
    variables = {
      ENVIRONMENT = var.api_stage_name
      STATE_BUCKET_NAME = data.external.env.result.STATE_BUCKET_NAME
      DYNAMODB_TABLE_NAME = data.external.env.result.DYNAMODB_TABLE_NAME
      VERCEL_API_TOKEN = data.external.env.result.VERCEL_API_TOKEN
      CLOUDFLARE_API_TOKEN = data.external.env.result.CLOUDFLARE_API_TOKEN
      SUMOLOGIC_ACCESSID = data.external.env.result.SUMOLOGIC_ACCESSID
      SUMOLOGIC_ACCESSKEY = data.external.env.result.SUMOLOGIC_ACCESSKEY
      DATABASE_URL = data.external.env.result.DATABASE_URL
    }
  }

}

# Data source to read environment variables
data "external" "env" {
  program = ["sh", "-c", <<EOF
    echo '{
      "STATE_BUCKET_NAME": "'"$STATE_BUCKET_NAME"'",
      "DYNAMODB_TABLE_NAME": "'"$DYNAMODB_TABLE_NAME"'",
      "VERCEL_API_TOKEN": "'"$VERCEL_API_TOKEN"'",
      "CLOUDFLARE_API_TOKEN": "'"$CLOUDFLARE_API_TOKEN"'",
      "SUMOLOGIC_ACCESSID": "'"$SUMOLOGIC_ACCESSID"'",
      "SUMOLOGIC_ACCESSKEY": "'"$SUMOLOGIC_ACCESSKEY"'",
      "DATABASE_URL": "'$(echo $DATABASE_URL | sed 's/"/\\"/g')'"
    }'
EOF
  ]
}

# API Gateway
resource "aws_apigatewayv2_api" "api" {
  name          = "${var.lambda_name}-gateway"
  protocol_type = "HTTP"
  target        = aws_lambda_function.api.arn

  cors_configuration {
    allow_origins = ["*"]  # Configure according to your needs
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
    max_age      = 300
  }
}

# API Gateway stage
resource "aws_apigatewayv2_stage" "api" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = var.api_stage_name
  auto_deploy = true
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
} 