# Create the Vercel project
resource "vercel_project" "monitor_client" {
  name      = var.vercel_project_name
  framework = var.framework
  git_repository = {
    type = "github"
    repo = var.git_repository
  }
}

# Add environment variables to the project
resource "vercel_project_environment_variable" "env_vars" {
  for_each = var.environment_variables

  project_id = vercel_project.monitor_client.id
  key        = each.key
  value      = each.value
  target     = ["production", "preview", "development"]
}

# Configure project settings
resource "vercel_project_domain" "domain" {
  project_id = vercel_project.monitor_client.id
  domain     = "${var.vercel_project_name}.vercel.app"
} 