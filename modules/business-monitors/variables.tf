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

variable "enable_api_health_checks" {
  description = "Enable API health check synthetic tests"
  type        = bool
  default     = false
}