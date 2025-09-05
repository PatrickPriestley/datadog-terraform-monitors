variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application key"
  type        = string
  sensitive   = true
}

variable "datadog_api_url" {
  description = "Datadog API URL"
  type        = string
  default     = "https://api.datadoghq.com/"  # Use datadoghq.eu for EU
}

variable "organization_name" {
  description = "Organization name for tagging"
  type        = string
  default     = "MyCompany"
}

variable "default_environment" {
  description = "Default environment"
  type        = string
  default     = "production"
}
