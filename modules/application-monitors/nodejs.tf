# Node.js Monitors

resource "datadog_monitor" "nodejs_memory" {
  count   = local.enable_nodejs ? 1 : 0
  name    = "[Application] ${var.service_name} - Node.js Memory Usage High"
  type    = "metric alert"
  message = "Node.js memory usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):avg:nodejs.mem.rss{${local.service_filter}} by {host} > 1073741824"  # 1GB in bytes

  monitor_thresholds {
    warning  = 805306368  # 768MB
    critical = 1073741824 # 1GB
  }

  tags = local.base_tags
}

resource "datadog_monitor" "nodejs_event_loop_lag" {
  count   = local.enable_nodejs ? 1 : 0
  name    = "[Application] ${var.service_name} - Node.js Event Loop Lag"
  type    = "metric alert"
  message = "Node.js event loop lag is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:nodejs.eventloop.delay.avg{${local.service_filter}} by {host} > 100"

  monitor_thresholds {
    warning  = 50
    critical = 100
  }

  tags = local.base_tags
}

resource "datadog_monitor" "nodejs_heap_usage" {
  count   = local.enable_nodejs ? 1 : 0
  name    = "[Application] ${var.service_name} - Node.js Heap Usage High"
  type    = "metric alert"
  message = "Node.js heap usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):(avg:nodejs.heap.size.used{${local.service_filter}} by {host} / avg:nodejs.heap.size.limit{${local.service_filter}} by {host}) * 100 > 85"

  monitor_thresholds {
    warning  = 75
    critical = 85
  }

  tags = local.base_tags
}