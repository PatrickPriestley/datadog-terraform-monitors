locals {
  service_filter = "service:${var.service_name},env:${var.environment}"
  alert_message  = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.environment}",
    "tier:${var.tier}",
    "managed-by:terraform",
    "monitor-type:security"
  ]
}