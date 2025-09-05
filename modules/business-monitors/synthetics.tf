# Synthetic Tests for Business Critical Journeys - Simplified Version

resource "datadog_synthetics_test" "api_health_check" {
  count = var.enable_api_health_checks ? 1 : 0
  
  type    = "api"
  subtype = "http"
  status  = "live"
  name    = "[Synthetics] ${var.service_name} - API Health Check"
  message = "API health check failed for ${var.service_name} ${local.alert_message}"
  
  locations = ["aws:us-east-1"]
  
  options_list {
    tick_every = 60  # 1 minute
    
    retry {
      count    = 2
      interval = 300
    }
    
    monitor_options {
      renotify_interval = 60
    }
  }
  
  request_definition {
    method = "GET"
    url    = "https://${var.service_name}-${var.environment}.example.com/health"
    timeout = 30
  }
  
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  
  assertion {
    type     = "responseTime"
    operator = "lessThan" 
    target   = "1000"
  }
  
  tags = local.base_tags
}

# Simple HTTP check for the main application
resource "datadog_synthetics_test" "main_page_check" {
  count = var.tier == "critical" ? 1 : 0
  
  type    = "api"
  subtype = "http" 
  status  = "live"
  name    = "[Synthetics] ${var.service_name} - Main Page Check"
  message = "Main page check failed for ${var.service_name} ${local.alert_message}"
  
  locations = ["aws:us-east-1"]
  
  options_list {
    tick_every = 300  # 5 minutes
    
    retry {
      count    = 2
      interval = 300
    }
  }
  
  request_definition {
    method = "GET"
    url    = "https://${var.service_name}-${var.environment}.example.com"
    timeout = 60
  }
  
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  
  assertion {
    type     = "responseTime"
    operator = "lessThan"
    target   = "2000"
  }
  
  tags = local.base_tags
}