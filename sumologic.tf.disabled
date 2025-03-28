# Create a Sumo Logic Monitor
resource "sumologic_monitor" "status_code_monitor" {
  name              = "HTTP Status Code Monitor"
  description       = "Monitor for 4xx and 5xx status codes in HTTP logs"
  type              = "MonitorsLibraryMonitor"
  content_type      = "Monitor"
  monitor_type      = "Logs"
  evaluation_delay  = "5m"
  is_disabled       = false
  tags = {
    "team"        = "monitoring"
    "application" = "sumologic"
  }

  # Define the log query
  queries {
    row_id = "A"
    query  = "_sourceCategory=terraform* | where status_code matches \"4*\" OR status_code matches \"5*\""
  }

  # Trigger conditions for critical and warning levels
  trigger_conditions {
    logs_static_condition {
      critical {
        time_range = "5m"
        alert {
          threshold      = 1.0
          threshold_type = "GreaterThan"
        }
        resolution {
          threshold      = 1.0
          threshold_type = "LessThanOrEqual"
        }
      }
      warning {
        time_range = "5m"
        alert {
          threshold      = 1.0
          threshold_type = "GreaterThan"
        }
        resolution {
          threshold      = 1.0
          threshold_type = "LessThanOrEqual"
        }
      }
    }
  }

  # Notification settings
  notifications {
    notification {
      connection_type = "Email"
      recipients = [
        "abc@example.com",
      ]
      subject      = "Monitor Alert: {{TriggerType}} on {{Name}}"
      time_zone    = "PST"
      message_body = "Triggered {{TriggerType}} Alert on {{Name}}: {{QueryURL}}"
    }
    run_for_trigger_types = ["Critical", "ResolvedCritical", "Warning"]
  }
}