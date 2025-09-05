# Queue Monitors

# SQS Monitors
resource "datadog_monitor" "sqs_queue_depth" {
  count   = local.enable_sqs ? 1 : 0
  name    = "[Application] ${var.service_name} - SQS Queue Depth High"
  type    = "metric alert"
  message = "SQS queue depth is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):avg:aws.sqs.approximate_number_of_messages_visible{${local.service_filter}} by {queuename} > 10000"

  monitor_thresholds {
    warning  = 5000
    critical = 10000
  }

  tags = local.base_tags
}

resource "datadog_monitor" "sqs_message_age" {
  count   = local.enable_sqs ? 1 : 0
  name    = "[Application] ${var.service_name} - SQS Message Age High"
  type    = "metric alert"
  message = "SQS message age is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:aws.sqs.approximate_age_of_oldest_message{${local.service_filter}} by {queuename} > 3600"

  monitor_thresholds {
    warning  = 1800  # 30 minutes
    critical = 3600  # 1 hour
  }

  tags = local.base_tags
}

# RabbitMQ Monitors
resource "datadog_monitor" "rabbitmq_queue_depth" {
  count   = local.enable_rabbitmq ? 1 : 0
  name    = "[Application] ${var.service_name} - RabbitMQ Queue Depth High"
  type    = "metric alert"
  message = "RabbitMQ queue depth is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):avg:rabbitmq.queue.messages.ready{${local.service_filter}} by {queue} > 10000"

  monitor_thresholds {
    warning  = 5000
    critical = 10000
  }

  tags = local.base_tags
}

resource "datadog_monitor" "rabbitmq_consumer_utilization" {
  count   = local.enable_rabbitmq ? 1 : 0
  name    = "[Application] ${var.service_name} - RabbitMQ Low Consumer Utilization"
  type    = "metric alert"
  message = "RabbitMQ consumer utilization is low for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:rabbitmq.queue.consumer_utilisation{${local.service_filter}} by {queue} < 0.5"

  monitor_thresholds {
    warning  = 0.7
    critical = 0.5
  }

  tags = local.base_tags
}

# Kafka Monitors
resource "datadog_monitor" "kafka_consumer_lag" {
  count   = local.enable_kafka ? 1 : 0
  name    = "[Application] ${var.service_name} - Kafka Consumer Lag High"
  type    = "metric alert"
  message = "Kafka consumer lag is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):avg:kafka.consumer.lag_sum{${local.service_filter}} by {consumer_group} > 100000"

  monitor_thresholds {
    warning  = 50000
    critical = 100000
  }

  tags = local.base_tags
}

resource "datadog_monitor" "kafka_partition_offline" {
  count   = local.enable_kafka ? 1 : 0
  name    = "[Application] ${var.service_name} - Kafka Offline Partitions"
  type    = "metric alert"
  message = "Kafka has offline partitions for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:kafka.offline_partitions_count{${local.service_filter}} by {broker} > 0"

  monitor_thresholds {
    critical = 0
  }

  tags = local.base_tags
}