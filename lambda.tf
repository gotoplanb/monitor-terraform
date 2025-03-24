# Create a temporary directory for cloning
resource "null_resource" "clone_repo" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
      rm -rf /tmp/monitor-api || true
      git clone ${var.api_repository_url} /tmp/monitor-api
      cd /tmp/monitor-api
      git checkout ${var.api_repository_branch}
      zip -r /tmp/lambda_function.zip .
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
  runtime         = var.lambda_runtime
  memory_size     = var.lambda_memory
  timeout         = var.lambda_timeout

  depends_on = [
    null_resource.clone_repo,
    local_file.lambda_zip_trigger
  ]

  environment {
    variables = {
      ENVIRONMENT = var.api_stage_name
      # Add other environment variables your API needs
    }
  }
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