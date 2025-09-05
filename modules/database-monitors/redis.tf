# Redis Monitors

resource "datadog_monitor" "redis_connections" {
  count   = local.enable_redis ? 1 : 0
  name    = "[Database] ${var.service_name} - Redis Connection Count High"
  type    = "metric alert"
  message = "Redis connection count is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:redis.net.clients{${local.service_filter}} by {redis_host} > 1000"

  monitor_thresholds {
    warning  = 800
    critical = 1000
  }

  tags = local.base_tags
}

resource "datadog_monitor" "redis_memory" {
  count   = local.enable_redis ? 1 : 0
  name    = "[Database] ${var.service_name} - Redis Memory Usage High"
  type    = "metric alert"
  message = "Redis memory usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):(avg:redis.mem.used{${local.service_filter}} by {redis_host} / avg:redis.mem.maxmemory{${local.service_filter}} by {redis_host}) * 100 > 90"

  monitor_thresholds {
    warning  = 80
    critical = 90
  }

  tags = local.base_tags
}

resource "datadog_monitor" "redis_evicted_keys" {
  count   = local.enable_redis ? 1 : 0
  name    = "[Database] ${var.service_name} - Redis Key Evictions"
  type    = "metric alert"
  message = "Redis is evicting keys for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:redis.keys.evicted{${local.service_filter}} by {redis_host}.as_rate() > 100"

  monitor_thresholds {
    warning  = 50
    critical = 100
  }

  tags = local.base_tags
}

resource "datadog_monitor" "redis_keyspace_misses" {
  count   = local.enable_redis ? 1 : 0
  name    = "[Database] ${var.service_name} - Redis High Cache Miss Rate"
  type    = "metric alert"
  message = "Redis cache miss rate is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):(avg:redis.stats.keyspace_misses{${local.service_filter}} by {redis_host}.as_rate() / (avg:redis.stats.keyspace_hits{${local.service_filter}} by {redis_host}.as_rate() + avg:redis.stats.keyspace_misses{${local.service_filter}} by {redis_host}.as_rate())) * 100 > 20"

  monitor_thresholds {
    warning  = 10
    critical = 20
  }

  tags = local.base_tags
}

resource "datadog_monitor" "redis_replication_lag" {
  count   = local.enable_redis ? 1 : 0
  name    = "[Database] ${var.service_name} - Redis Replication Lag"
  type    = "metric alert"
  message = "Redis replication lag is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:redis.replication.master_repl_offset{${local.service_filter}} by {redis_host} - avg:redis.replication.slave_repl_offset{${local.service_filter}} by {redis_host} > 1000000"

  monitor_thresholds {
    warning  = 500000
    critical = 1000000
  }

  tags = local.base_tags
}