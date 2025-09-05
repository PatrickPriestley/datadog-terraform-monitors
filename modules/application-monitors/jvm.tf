# JVM Monitors

resource "datadog_monitor" "jvm_heap_memory" {
  count   = local.enable_jvm ? 1 : 0
  name    = "[Application] ${var.service_name} - JVM Heap Memory Usage High"
  type    = "metric alert"
  message = "JVM heap memory usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):(avg:jvm.heap_memory_used{${local.service_filter}} by {host} / avg:jvm.heap_memory_max{${local.service_filter}} by {host}) * 100 > 85"

  monitor_thresholds {
    warning  = 75
    critical = 85
  }

  tags = local.base_tags
}

resource "datadog_monitor" "jvm_gc_time" {
  count   = local.enable_jvm ? 1 : 0
  name    = "[Application] ${var.service_name} - JVM GC Time High"
  type    = "metric alert"
  message = "JVM garbage collection time is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:jvm.gc.parnew.time{${local.service_filter}} by {host}.as_rate() > 500"

  monitor_thresholds {
    warning  = 300
    critical = 500
  }

  tags = local.base_tags
}

resource "datadog_monitor" "jvm_thread_deadlocks" {
  count   = local.enable_jvm ? 1 : 0
  name    = "[Application] ${var.service_name} - JVM Thread Deadlocks"
  type    = "metric alert"
  message = "JVM thread deadlocks detected for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:jvm.thread_count.deadlocked{${local.service_filter}} by {host} > 0"

  monitor_thresholds {
    critical = 0
  }

  tags = local.base_tags
}

resource "datadog_monitor" "jvm_metaspace" {
  count   = local.enable_jvm ? 1 : 0
  name    = "[Application] ${var.service_name} - JVM Metaspace Usage High"
  type    = "metric alert"
  message = "JVM metaspace usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):(avg:jvm.non_heap_memory_used{${local.service_filter}} by {host} / avg:jvm.non_heap_memory_max{${local.service_filter}} by {host}) * 100 > 90"

  monitor_thresholds {
    warning  = 80
    critical = 90
  }

  tags = local.base_tags
}