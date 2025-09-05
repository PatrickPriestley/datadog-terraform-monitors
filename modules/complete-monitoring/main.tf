# Main module orchestration logic
locals {
  service_filter = "service:${var.service_name},env:${var.service_config.environment}"
  alert_message  = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.service_config.environment}",
    "team:${var.service_config.team}",
    "tier:${var.service_config.tier}",
    "managed-by:terraform"
  ]
  all_tags = concat(local.base_tags, var.service_config.custom_tags)
}

# Golden Signals Monitors (if enabled)
module "golden_signals" {
  source = "../golden-signals"
  count  = contains(var.service_config.monitoring_suites, "golden-signals") ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  alert_channels = var.alert_channels
  tier          = var.service_config.tier
}

# Infrastructure Monitors (if enabled)
module "infrastructure" {
  source = "../infrastructure-monitors"
  count  = contains(var.service_config.monitoring_suites, "infrastructure") ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  alert_channels = var.alert_channels
  tier          = var.service_config.tier
}

# Database Monitors (if enabled and database specified)
module "database" {
  source = "../database-monitors"
  count  = contains(var.service_config.monitoring_suites, "database") && var.service_config.database_type != "" ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  database_type  = var.service_config.database_type
  alert_channels = var.alert_channels
  tier          = var.service_config.tier
}

# Application Monitors (if enabled)
module "application" {
  source = "../application-monitors"
  count  = contains(var.service_config.monitoring_suites, "application") ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  runtime        = var.service_config.runtime
  queue_type     = var.service_config.queue_type
  alert_channels = var.alert_channels
  tier          = var.service_config.tier
}

# Security Monitors (if enabled)
module "security" {
  source = "../security-monitors" 
  count  = contains(var.service_config.monitoring_suites, "security") ? 1 : 0
  
  service_name              = var.service_name
  environment               = var.service_config.environment
  alert_channels           = var.alert_channels
  tier                     = var.service_config.tier
  enable_synthetic_tests   = var.service_config.tier == "critical"
  enable_api_health_checks = var.service_config.service_type == "api"
}

# Business Monitors (if enabled)
module "business" {
  source = "../business-monitors"
  count  = contains(var.service_config.monitoring_suites, "business") ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  alert_channels = var.alert_channels
  tier          = var.service_config.tier
  
  business_thresholds = {
    revenue_minimum = 1000
    signup_rate_minimum = 10
    conversion_rate_minimum = 2.5
  }
}