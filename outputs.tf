output "project_id" {
  description = "The ID of the created Vercel project"
  value       = vercel_project.monitors_client.id
}

output "project_url" {
  description = "The URL of the deployed project"
  value       = "https://${vercel_project_domain.domain.domain}"
} 