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