# Compliance and Audit Monitors

resource "datadog_monitor" "config_change" {
  count = var.enable_log_monitoring ? 1 : 0
  name    = "[Security] ${var.service_name} - Unauthorized Configuration Change"
  type    = "log alert"
  message = "Unauthorized configuration change detected for ${var.service_name} ${local.alert_message}"
  query   = "logs(\"service:${var.service_name} @evt.category:configuration @evt.outcome:modified\").index(\"*\").rollup(\"count\").last(\"15m\") > 5"

  monitor_thresholds {
    warning  = 3
    critical = 5
  }

  tags = local.base_tags
}

resource "datadog_monitor" "audit_log_tampering" {
  count = var.enable_log_monitoring ? 1 : 0
  name    = "[Security] ${var.service_name} - Audit Log Tampering Detected"
  type    = "log alert"
  message = "Potential audit log tampering detected for ${var.service_name} ${local.alert_message}"
  query   = "logs(\"service:${var.service_name} @evt.name:(\\\"log_deleted\\\" OR \\\"log_modified\\\" OR \\\"audit_disabled\\\")\").index(\"*\").rollup(\"count\").last(\"5m\") > 1"

  monitor_thresholds {
    critical = 1
  }

  tags = local.base_tags
}

resource "datadog_monitor" "data_exfiltration" {
  count = var.enable_log_monitoring ? 1 : 0
  name    = "[Security] ${var.service_name} - Potential Data Exfiltration"
  type    = "log alert"
  message = "Potential data exfiltration detected for ${var.service_name} ${local.alert_message}"
  query   = "logs(\"service:${var.service_name} @evt.category:database @evt.outcome:success @database.rows_affected:>1000\").index(\"*\").rollup(\"count\").by(\"@usr.email\").last(\"30m\") > 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  tags = local.base_tags
}

resource "datadog_monitor" "api_key_exposure" {
  count = var.enable_log_monitoring ? 1 : 0
  name    = "[Security] ${var.service_name} - API Key Exposure in Logs"
  type    = "log alert"
  message = "Potential API key exposure in logs for ${var.service_name} ${local.alert_message}"
  query   = "logs(\"service:${var.service_name} (api_key OR apikey OR secret OR password OR token)\").index(\"*\").rollup(\"count\").last(\"5m\") > 1"

  monitor_thresholds {
    critical = 1
  }

  tags = local.base_tags
}