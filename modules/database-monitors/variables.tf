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

variable "database_type" {
  description = "Type of database (postgresql, mysql, redis, mongodb)"
  type        = string
  
  validation {
    condition     = contains(["postgresql", "mysql", "redis", "mongodb"], var.database_type)
    error_message = "Database type must be postgresql, mysql, redis, or mongodb."
  }
}

variable "alert_channels" {
  description = "List of alert notification channels"
  type        = list(string)
  default     = []
}