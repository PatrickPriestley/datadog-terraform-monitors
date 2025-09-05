# Network Security Monitors

resource "datadog_monitor" "ssl_certificate_expiry" {
  name    = "[Security] ${var.service_name} - SSL Certificate Expiring Soon"
  type    = "metric alert"
  message = "SSL certificate expiring soon for ${var.service_name} ${local.alert_message}"
  query   = "min(last_5m):min:http.ssl.days_left{${local.service_filter}} by {host} < 30"

  monitor_thresholds {
    warning  = 60
    critical = 30
  }

  tags = local.base_tags
}

resource "datadog_monitor" "ddos_attack" {
  name    = "[Security] ${var.service_name} - Potential DDoS Attack"
  type    = "metric alert"
  message = "Potential DDoS attack detected for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):sum:trace.http.request.hits{${local.service_filter}} by {client_ip}.as_rate() > 1000"

  monitor_thresholds {
    warning  = 500
    critical = 1000
  }

  tags = local.base_tags
}

resource "datadog_monitor" "port_scan" {
  count = var.enable_log_monitoring ? 1 : 0
  name    = "[Security] ${var.service_name} - Port Scan Detected"
  type    = "log alert"
  message = "Port scan activity detected for ${var.service_name} ${local.alert_message}"
  query   = "logs(\"service:${var.service_name} @network.client.port:* @evt.name:connection_attempt\").index(\"*\").rollup(\"cardinality\", \"@network.client.port\").by(\"@network.client.ip\").last(\"5m\") > 20"

  monitor_thresholds {
    warning  = 10
    critical = 20
  }

  tags = local.base_tags
}

resource "datadog_monitor" "outbound_data_spike" {
  name    = "[Security] ${var.service_name} - Unusual Outbound Data Transfer"
  type    = "metric alert"
  message = "Unusual outbound data transfer detected for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):sum:system.net.bytes_sent{${local.service_filter}} by {host}.as_rate() > 1073741824"  # 1GB/s

  monitor_thresholds {
    warning  = 536870912   # 512MB/s
    critical = 1073741824  # 1GB/s
  }

  tags = local.base_tags
}