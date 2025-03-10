# Create a folder to organize monitors
resource "sumologic_folder" "monitors" {
  name        = "API Monitors"
  description = "Folder containing API health monitors"
}

# Create a monitor
resource "sumologic_monitor" "api_health" {
  name         = var.monitor_name
  description  = "Monitors API health status"
  type         = "Metrics"
  is_disabled  = false
  content_type = "Monitor"
  folder_id    = sumologic_folder.monitors.id

  queries {
    row_id = "A"
    query  = var.monitor_query
  }

  trigger_conditions {
    threshold {
      threshold_type   = "GreaterThanOrEqual"
      threshold       = 1
      time_range     = var.monitor_time_range
      occurrence_type = "AtLeastOnce"
    }
  }

  notifications {
    notification {
      connection_type = "Email"
      recipients     = [var.notification_email]
      subject        = "API Health Alert: {{TriggerType}}"
      message_body   = "Monitor {{Name}} is {{TriggerType}}\n\nDescription: {{Description}}\n\nTrigger Details: {{TriggerDetails}}"
      time_zone     = "UTC"
    }
  }

  group_notifications = true
} 