provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.us5.datadoghq.com/"
}

# Local variables for service configuration
locals {
  # Define your services here - start small and grow
  services = {
    "web-app" = {
      environment     = "production"
      tier           = "critical"
      team           = "frontend"
      runtime        = "node"
      database_type  = "postgresql" 
      queue_type     = "sqs"
      service_type   = "web"
      deployment_type = "kubernetes"
      monitoring_suites = ["golden-signals"]
      custom_tags = ["customer-facing"]
    }
    
    "api-service" = {
      environment     = "production"
      tier           = "critical"
      team           = "backend"
      runtime        = "jvm"
      database_type  = "postgresql"
      queue_type     = "sqs" 
      service_type   = "api"
      deployment_type = "kubernetes"
      monitoring_suites = ["golden-signals"]
      custom_tags = ["api", "core-service"]
    }
  }

  # Alert routing by tier and environment
  alert_configs = {
    critical = {
      production = ["@slack-oncall", "@pagerduty-critical"]
      staging    = ["@slack-dev-alerts"]
    }
    important = {
      production = ["@slack-alerts", "@pagerduty-high"]
      staging    = ["@slack-dev"]
    }
    standard = {
      production = ["@slack-alerts"]
      staging    = ["@slack-dev"]
    }
  }
}

# Create monitoring for each service
module "service_monitoring" {
  source = "./modules/complete-monitoring"
  
  for_each = local.services
  
  service_name   = each.key
  service_config = each.value
  alert_channels = local.alert_configs[each.value.tier][each.value.environment]
  
  # Global settings
  organization_name = var.organization_name
}
