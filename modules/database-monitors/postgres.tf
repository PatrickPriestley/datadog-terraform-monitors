# PostgreSQL Monitors

resource "datadog_monitor" "postgresql_connections" {
  count   = local.enable_postgresql ? 1 : 0
  name    = "[Database] ${var.service_name} - PostgreSQL Connection Pool Exhaustion"
  type    = "metric alert"
  message = "PostgreSQL connection pool is nearly exhausted for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):(avg:postgresql.connections{${local.service_filter}} by {db} / avg:postgresql.max_connections{${local.service_filter}} by {db}) * 100 > 85"

  monitor_thresholds {
    warning  = 75
    critical = 85
  }

  tags = local.base_tags
}

resource "datadog_monitor" "postgresql_replication_lag" {
  count   = local.enable_postgresql ? 1 : 0
  name    = "[Database] ${var.service_name} - PostgreSQL Replication Lag"
  type    = "metric alert"
  message = "PostgreSQL replication lag is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:postgresql.replication_delay{${local.service_filter}} by {db} > 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  tags = local.base_tags
}

resource "datadog_monitor" "postgresql_deadlocks" {
  count   = local.enable_postgresql ? 1 : 0
  name    = "[Database] ${var.service_name} - PostgreSQL Deadlocks Detected"
  type    = "metric alert"
  message = "PostgreSQL deadlocks detected for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:postgresql.deadlocks{${local.service_filter}} by {db}.as_rate() > 5"

  monitor_thresholds {
    warning  = 1
    critical = 5
  }

  tags = local.base_tags
}

resource "datadog_monitor" "postgresql_slow_queries" {
  count   = local.enable_postgresql ? 1 : 0
  name    = "[Database] ${var.service_name} - PostgreSQL Slow Queries"
  type    = "metric alert"
  message = "PostgreSQL has slow queries for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):avg:postgresql.queries.slow{${local.service_filter}} by {db} > 100"

  monitor_thresholds {
    warning  = 50
    critical = 100
  }

  tags = local.base_tags
}

resource "datadog_monitor" "postgresql_cache_hit_ratio" {
  count   = local.enable_postgresql ? 1 : 0
  name    = "[Database] ${var.service_name} - PostgreSQL Low Cache Hit Ratio"
  type    = "metric alert"
  message = "PostgreSQL cache hit ratio is low for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):(avg:postgresql.blks_hit{${local.service_filter}} by {db} / (avg:postgresql.blks_hit{${local.service_filter}} by {db} + avg:postgresql.blks_read{${local.service_filter}} by {db})) * 100 < 90"

  monitor_thresholds {
    warning  = 95
    critical = 90
  }

  tags = local.base_tags
}