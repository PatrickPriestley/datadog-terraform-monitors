# MySQL Monitors

resource "datadog_monitor" "mysql_connections" {
  count   = local.enable_mysql ? 1 : 0
  name    = "[Database] ${var.service_name} - MySQL Connection Pool Exhaustion"
  type    = "metric alert"
  message = "MySQL connection pool is nearly exhausted for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):(avg:mysql.net.connections{${local.service_filter}} by {db} / avg:mysql.net.max_connections{${local.service_filter}} by {db}) * 100 > 85"

  monitor_thresholds {
    warning  = 75
    critical = 85
  }

  tags = local.base_tags
}

resource "datadog_monitor" "mysql_replication_lag" {
  count   = local.enable_mysql ? 1 : 0
  name    = "[Database] ${var.service_name} - MySQL Replication Lag"
  type    = "metric alert"
  message = "MySQL replication lag is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:mysql.replication.seconds_behind_master{${local.service_filter}} by {db} > 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  tags = local.base_tags
}

resource "datadog_monitor" "mysql_slow_queries" {
  count   = local.enable_mysql ? 1 : 0
  name    = "[Database] ${var.service_name} - MySQL Slow Queries"
  type    = "metric alert"
  message = "MySQL has slow queries for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):avg:mysql.performance.slow_queries{${local.service_filter}} by {db}.as_rate() > 10"

  monitor_thresholds {
    warning  = 5
    critical = 10
  }

  tags = local.base_tags
}

resource "datadog_monitor" "mysql_innodb_buffer_pool" {
  count   = local.enable_mysql ? 1 : 0
  name    = "[Database] ${var.service_name} - MySQL InnoDB Buffer Pool Utilization"
  type    = "metric alert"
  message = "MySQL InnoDB buffer pool utilization is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):(avg:mysql.innodb.buffer_pool_pages_total{${local.service_filter}} - avg:mysql.innodb.buffer_pool_pages_free{${local.service_filter}}) / avg:mysql.innodb.buffer_pool_pages_total{${local.service_filter}} * 100 > 90"

  monitor_thresholds {
    warning  = 85
    critical = 90
  }

  tags = local.base_tags
}

resource "datadog_monitor" "mysql_table_locks" {
  count   = local.enable_mysql ? 1 : 0
  name    = "[Database] ${var.service_name} - MySQL Table Lock Waits"
  type    = "metric alert"
  message = "MySQL has high table lock waits for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:mysql.locks.immediate{${local.service_filter}} by {db}.as_rate() > 100"

  monitor_thresholds {
    warning  = 50
    critical = 100
  }

  tags = local.base_tags
}