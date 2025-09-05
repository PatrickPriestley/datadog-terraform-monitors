locals {
  service_filter = "service:${var.service_name},env:${var.environment}"
  alert_message  = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.environment}",
    "tier:${var.tier}",
    "runtime:${var.runtime}",
    "managed-by:terraform",
    "monitor-type:application"
  ]
  
  # Enable monitors based on runtime and queue type
  enable_jvm     = var.runtime == "jvm"
  enable_nodejs  = var.runtime == "node"
  enable_python  = var.runtime == "python"
  enable_go      = var.runtime == "go"
  
  enable_sqs      = var.queue_type == "sqs"
  enable_rabbitmq = var.queue_type == "rabbitmq"
  enable_kafka    = var.queue_type == "kafka"
}