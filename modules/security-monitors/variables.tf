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

variable "alert_channels" {
  description = "List of alert notification channels"
  type        = list(string)
  default     = []
}

variable "enable_synthetic_tests" {
  description = "Enable synthetic tests for critical services"
  type        = bool
  default     = false
}

variable "enable_api_health_checks" {
  description = "Enable API health checks"
  type        = bool
  default     = false
}

variable "enable_log_monitoring" {
  description = "Enable log-based monitors (requires Datadog Log Management)"
  type        = bool
  default     = false
}