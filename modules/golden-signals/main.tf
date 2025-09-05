locals {
  service_filter = "service:${var.service_name},env:${var.environment}"
  alert_message = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.environment}",
    "tier:${var.tier}",
    "managed-by:terraform",
    "monitor-type:golden-signals"
  ]
}

# 1. LATENCY - Response time monitoring
resource "datadog_monitor" "latency_p95" {
  name    = "[Golden Signal] ${var.service_name} - High Latency (p95)"
  type    = "metric alert"
  message = "P95 latency is above threshold for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):p95:trace.http.request{${local.service_filter}} > 1"

  monitor_thresholds {
    warning  = 0.8
    critical = 1.0
  }

  tags = local.base_tags
}

resource "datadog_monitor" "latency_p99" {
  name    = "[Golden Signal] ${var.service_name} - High Latency (p99)"
  type    = "metric alert"
  message = "P99 latency is critically high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):p99:trace.http.request{${local.service_filter}} > 2"

  monitor_thresholds {
    warning  = 1.5
    critical = 2.0
  }

  tags = local.base_tags
}

# 2. TRAFFIC - Request rate monitoring
resource "datadog_monitor" "traffic_drop" {
  name    = "[Golden Signal] ${var.service_name} - Traffic Drop"
  type    = "metric alert"
  message = "Traffic has dropped significantly for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):sum:trace.http.request.hits{${local.service_filter}}.as_rate() < 10"

  monitor_thresholds {
    critical = 10
  }

  tags = local.base_tags
}

# 3. ERRORS - Error rate monitoring  
resource "datadog_monitor" "error_rate" {
  name    = "[Golden Signal] ${var.service_name} - High Error Rate"
  type    = "metric alert"
  message = "Error rate is above threshold for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):(sum:trace.http.request.errors{${local.service_filter}}.as_rate() / sum:trace.http.request.hits{${local.service_filter}}.as_rate()) * 100 > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = local.base_tags
}

# 4. SATURATION - Resource utilization
resource "datadog_monitor" "saturation_composite" {
  name    = "[Golden Signal] ${var.service_name} - Resource Saturation"
  type    = "composite"
  message = "Multiple resources are saturated for ${var.service_name} ${local.alert_message}"
  query   = "${datadog_monitor.cpu_saturation.id} || ${datadog_monitor.memory_saturation.id}"

  tags = local.base_tags
}

resource "datadog_monitor" "cpu_saturation" {
  name    = "[Golden Signal] ${var.service_name} - CPU Saturation"
  type    = "metric alert"
  message = "CPU saturation is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:system.cpu.user{${local.service_filter}} by {host} > 0.8"

  monitor_thresholds {
    warning  = 0.7
    critical = 0.8
  }

  tags = local.base_tags
}

resource "datadog_monitor" "memory_saturation" {
  name    = "[Golden Signal] ${var.service_name} - Memory Saturation"
  type    = "metric alert"
  message = "Memory saturation is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:system.mem.pct_usable{${local.service_filter}} by {host} < 0.2"

  monitor_thresholds {
    warning  = 0.3
    critical = 0.2
  }

  tags = local.base_tags
}