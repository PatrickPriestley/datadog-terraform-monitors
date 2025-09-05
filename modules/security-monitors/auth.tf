# Authentication Monitors

resource "datadog_monitor" "auth_failure_rate" {
  name    = "[Security] ${var.service_name} - High Authentication Failure Rate"
  type    = "metric alert"
  message = "High authentication failure rate detected for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):(sum:security.auth.failure{${local.service_filter}}.as_rate() / (sum:security.auth.success{${local.service_filter}}.as_rate() + sum:security.auth.failure{${local.service_filter}}.as_rate())) * 100 > 20"

  monitor_thresholds {
    warning  = 10
    critical = 20
  }

  tags = local.base_tags
}

resource "datadog_monitor" "auth_brute_force" {
  name    = "[Security] ${var.service_name} - Potential Brute Force Attack"
  type    = "metric alert"
  message = "Potential brute force attack detected for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):sum:security.auth.failure{${local.service_filter}} by {client_ip}.as_rate() > 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  tags = local.base_tags
}

resource "datadog_monitor" "privilege_escalation" {
  count = var.enable_log_monitoring ? 1 : 0
  name    = "[Security] ${var.service_name} - Privilege Escalation Attempt"
  type    = "log alert"
  message = "Privilege escalation attempt detected for ${var.service_name} ${local.alert_message}"
  query   = "logs(\"service:${var.service_name} @evt.name:(\\\"privilege_escalation\\\" OR \\\"sudo\\\" OR \\\"su\\\" OR \\\"admin_access\\\")\").index(\"*\").rollup(\"count\").last(\"5m\") > 5"

  monitor_thresholds {
    warning  = 3
    critical = 5
  }

  tags = local.base_tags
}

resource "datadog_monitor" "unusual_login_location" {
  count = var.enable_log_monitoring ? 1 : 0
  name    = "[Security] ${var.service_name} - Login from Unusual Location"
  type    = "log alert"
  message = "Login from unusual location detected for ${var.service_name} ${local.alert_message}"
  query   = "logs(\"service:${var.service_name} @evt.name:login @geo.country:* -@geo.country:(US OR CA OR GB)\").index(\"*\").rollup(\"count\").by(\"@usr.email\").last(\"15m\") > 1"

  monitor_thresholds {
    critical = 1
  }

  tags = local.base_tags
}