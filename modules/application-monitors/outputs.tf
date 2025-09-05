output "monitor_ids" {
  description = "Map of monitor types to their IDs"
  value = merge(
    # JVM monitors
    local.enable_jvm ? {
      jvm_heap_memory      = datadog_monitor.jvm_heap_memory[0].id
      jvm_gc_time          = datadog_monitor.jvm_gc_time[0].id
      jvm_thread_deadlocks = datadog_monitor.jvm_thread_deadlocks[0].id
      jvm_metaspace        = datadog_monitor.jvm_metaspace[0].id
    } : {},
    
    # Node.js monitors
    local.enable_nodejs ? {
      nodejs_memory         = datadog_monitor.nodejs_memory[0].id
      nodejs_event_loop_lag = datadog_monitor.nodejs_event_loop_lag[0].id
      nodejs_heap_usage     = datadog_monitor.nodejs_heap_usage[0].id
    } : {},
    
    # SQS monitors
    local.enable_sqs ? {
      sqs_queue_depth = datadog_monitor.sqs_queue_depth[0].id
      sqs_message_age = datadog_monitor.sqs_message_age[0].id
    } : {},
    
    # RabbitMQ monitors
    local.enable_rabbitmq ? {
      rabbitmq_queue_depth           = datadog_monitor.rabbitmq_queue_depth[0].id
      rabbitmq_consumer_utilization  = datadog_monitor.rabbitmq_consumer_utilization[0].id
    } : {},
    
    # Kafka monitors
    local.enable_kafka ? {
      kafka_consumer_lag      = datadog_monitor.kafka_consumer_lag[0].id
      kafka_partition_offline = datadog_monitor.kafka_partition_offline[0].id
    } : {}
  )
}

output "runtime" {
  description = "Application runtime being monitored"
  value       = var.runtime
}

output "queue_type" {
  description = "Queue type being monitored"
  value       = var.queue_type
}