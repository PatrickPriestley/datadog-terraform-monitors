variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tier" {
  description = "Service tier (critical/important/standard)"
  type        = string
  default     = "standard"
}

variable "runtime" {
  description = "Application runtime (jvm, node, python, go)"
  type        = string
  default     = ""
  
  validation {
    condition     = var.runtime == "" || contains(["jvm", "node", "python", "go", "ruby", "dotnet"], var.runtime)
    error_message = "Runtime must be one of: jvm, node, python, go, ruby, dotnet (or empty)."
  }
}

variable "queue_type" {
  description = "Type of message queue (sqs, rabbitmq, kafka)"
  type        = string
  default     = ""
  
  validation {
    condition     = var.queue_type == "" || contains(["sqs", "rabbitmq", "kafka", "redis"], var.queue_type)
    error_message = "Queue type must be one of: sqs, rabbitmq, kafka, redis (or empty)."
  }
}

variable "alert_channels" {
  description = "List of alert notification channels"
  type        = list(string)
  default     = []
}