variable "service_name" {
  description = "Name of the service"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service_name))
    error_message = "Service name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "service_config" {
  description = "Service configuration object"
  type = object({
    environment       = string
    tier             = string
    team             = string
    runtime          = string
    database_type    = string
    queue_type       = string
    service_type     = string
    deployment_type  = string
    monitoring_suites = list(string)
    custom_tags      = list(string)
  })
  
  validation {
    condition = contains(["production", "staging", "development"], var.service_config.environment)
    error_message = "Environment must be production, staging, or development."
  }
  
  validation {
    condition = contains(["critical", "important", "standard"], var.service_config.tier)
    error_message = "Tier must be critical, important, or standard."
  }
  
  validation {
    condition = var.service_config.runtime == "" || contains(["node", "jvm", "python", "go", "ruby", "dotnet"], var.service_config.runtime)
    error_message = "Runtime must be one of: node, jvm, python, go, ruby, dotnet (or empty)."
  }
  
  validation {
    condition = var.service_config.database_type == "" || contains(["postgresql", "mysql", "redis", "mongodb", "dynamodb"], var.service_config.database_type)
    error_message = "Database type must be one of: postgresql, mysql, redis, mongodb, dynamodb (or empty)."
  }
  
  validation {
    condition = var.service_config.queue_type == "" || contains(["sqs", "rabbitmq", "kafka", "redis"], var.service_config.queue_type)
    error_message = "Queue type must be one of: sqs, rabbitmq, kafka, redis (or empty)."
  }
  
  validation {
    condition = contains(["api", "web", "worker", "batch"], var.service_config.service_type)
    error_message = "Service type must be one of: api, web, worker, batch."
  }
  
  validation {
    condition = contains(["kubernetes", "ecs", "lambda", "ec2"], var.service_config.deployment_type)
    error_message = "Deployment type must be one of: kubernetes, ecs, lambda, ec2."
  }
}

variable "alert_channels" {
  description = "List of alert notification channels"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for channel in var.alert_channels : can(regex("^@", channel))
    ])
    error_message = "All alert channels must start with @."
  }
}

variable "organization_name" {
  description = "Organization name"
  type        = string
  default     = "MyCompany"
}

variable "business_thresholds" {
  description = "Business metric thresholds"
  type = object({
    revenue_minimum         = number
    signup_rate_minimum    = number
    conversion_rate_minimum = number
  })
  default = {
    revenue_minimum         = 1000
    signup_rate_minimum    = 10
    conversion_rate_minimum = 2.5
  }
}