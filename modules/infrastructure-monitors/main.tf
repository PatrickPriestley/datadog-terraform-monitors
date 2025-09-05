locals {
  service_filter = "service:${var.service_name},env:${var.environment}"
  alert_message = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.environment}",
    "tier:${var.tier}",
    "managed-by:terraform",
    "monitor-type:infrastructure"
  ]
  
  # Tier-based thresholds
  cpu_thresholds = {
    critical = { warning = 0.7, critical = 0.85 }
    important = { warning = 0.75, critical = 0.9 }
    standard = { warning = 0.8, critical = 0.95 }
  }
  
  memory_thresholds = {
    critical = { warning = 0.2, critical = 0.15 }
    important = { warning = 0.15, critical = 0.1 }
    standard = { warning = 0.1, critical = 0.05 }
  }
  
  disk_thresholds = {
    critical = { warning = 0.8, critical = 0.9 }
    important = { warning = 0.85, critical = 0.92 }
    standard = { warning = 0.9, critical = 0.95 }
  }
}

# Host Availability Monitor
resource "datadog_monitor" "host_availability" {
  name    = "[Infrastructure] ${var.service_name} - Host Down"
  type    = "service check"
  message = "Host is down for ${var.service_name} ${local.alert_message}"
  query   = "\"datadog.agent.up\".over(\"service:${var.service_name}\",\"env:${var.environment}\").by(\"host\").last(2).count_by_status()"

  monitor_thresholds {
    warning  = 1
    critical = 1
  }

  notify_no_data    = true
  no_data_timeframe = 5
  tags              = local.base_tags
}

# CPU Usage Monitor
resource "datadog_monitor" "cpu_usage" {
  name    = "[Infrastructure] ${var.service_name} - High CPU Usage"
  type    = "metric alert"
  message = "CPU usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:system.cpu.user{${local.service_filter}} by {host} > ${local.cpu_thresholds[var.tier].critical}"

  monitor_thresholds {
    warning  = local.cpu_thresholds[var.tier].warning
    critical = local.cpu_thresholds[var.tier].critical
  }

  tags = local.base_tags
}

# Memory Usage Monitor
resource "datadog_monitor" "memory_usage" {
  name    = "[Infrastructure] ${var.service_name} - High Memory Usage"
  type    = "metric alert"
  message = "Memory usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:system.mem.pct_usable{${local.service_filter}} by {host} < ${local.memory_thresholds[var.tier].critical}"

  monitor_thresholds {
    warning  = local.memory_thresholds[var.tier].warning
    critical = local.memory_thresholds[var.tier].critical
  }

  tags = local.base_tags
}

# Disk Usage Monitor
resource "datadog_monitor" "disk_usage" {
  name    = "[Infrastructure] ${var.service_name} - High Disk Usage"
  type    = "metric alert"
  message = "Disk usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):max:system.disk.used{${local.service_filter}} by {host,device} / max:system.disk.total{${local.service_filter}} by {host,device} > ${local.disk_thresholds[var.tier].critical}"

  monitor_thresholds {
    warning  = local.disk_thresholds[var.tier].warning
    critical = local.disk_thresholds[var.tier].critical
  }

  tags = local.base_tags
}

# Network Error Monitor
resource "datadog_monitor" "network_errors" {
  name    = "[Infrastructure] ${var.service_name} - Network Errors"
  type    = "metric alert"
  message = "Network errors detected for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):sum:system.net.packets_in.error{${local.service_filter}} by {host}.as_rate() + sum:system.net.packets_out.error{${local.service_filter}} by {host}.as_rate() > 100"

  monitor_thresholds {
    warning  = 50
    critical = 100
  }

  tags = local.base_tags
}

# Load Average Monitor (for Unix systems)
resource "datadog_monitor" "load_average" {
  name    = "[Infrastructure] ${var.service_name} - High Load Average"
  type    = "metric alert"
  message = "Load average is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):avg:system.load.5{${local.service_filter}} by {host} / avg:system.core.count{${local.service_filter}} by {host} > 2"

  monitor_thresholds {
    warning  = 1.5
    critical = 2.0
  }

  tags = local.base_tags
}