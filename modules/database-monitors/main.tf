locals {
  service_filter = "service:${var.service_name},env:${var.environment}"
  alert_message  = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.environment}",
    "tier:${var.tier}",
    "database:${var.database_type}",
    "managed-by:terraform",
    "monitor-type:database"
  ]
  
  # Enable monitors based on database type
  enable_postgresql = var.database_type == "postgresql"
  enable_mysql      = var.database_type == "mysql"
  enable_redis      = var.database_type == "redis"
  enable_mongodb    = var.database_type == "mongodb"
}