output "monitor_ids" {
  description = "Map of monitor types to their IDs"
  value = merge(
    # PostgreSQL monitors
    local.enable_postgresql ? {
      postgresql_connections      = datadog_monitor.postgresql_connections[0].id
      postgresql_replication_lag  = datadog_monitor.postgresql_replication_lag[0].id
      postgresql_deadlocks        = datadog_monitor.postgresql_deadlocks[0].id
      postgresql_slow_queries     = datadog_monitor.postgresql_slow_queries[0].id
      postgresql_cache_hit_ratio  = datadog_monitor.postgresql_cache_hit_ratio[0].id
    } : {},
    
    # MySQL monitors
    local.enable_mysql ? {
      mysql_connections          = datadog_monitor.mysql_connections[0].id
      mysql_replication_lag      = datadog_monitor.mysql_replication_lag[0].id
      mysql_slow_queries         = datadog_monitor.mysql_slow_queries[0].id
      mysql_innodb_buffer_pool   = datadog_monitor.mysql_innodb_buffer_pool[0].id
      mysql_table_locks          = datadog_monitor.mysql_table_locks[0].id
    } : {},
    
    # Redis monitors
    local.enable_redis ? {
      redis_connections       = datadog_monitor.redis_connections[0].id
      redis_memory           = datadog_monitor.redis_memory[0].id
      redis_evicted_keys     = datadog_monitor.redis_evicted_keys[0].id
      redis_keyspace_misses  = datadog_monitor.redis_keyspace_misses[0].id
      redis_replication_lag  = datadog_monitor.redis_replication_lag[0].id
    } : {}
  )
}

output "database_type" {
  description = "Type of database being monitored"
  value       = var.database_type
}