output "project_id" {
  description = "The ID of the created Vercel project"
  value       = vercel_project.monitors_client.id
}

output "project_url" {
  description = "The URL of the deployed project"
  value       = "https://${vercel_project_domain.domain.domain}"
}

output "cloudflare_url" {
  description = "The Cloudflare protected URL of the application"
  value       = "https://${cloudflare_record.app.hostname}"
}

output "zero_trust_app_id" {
  description = "The ID of the Zero Trust application"
  value       = cloudflare_zero_trust_access_application.app.id
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "${aws_apigatewayv2_api.api.api_endpoint}/${var.api_stage_name}"
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.api.function_name
} 