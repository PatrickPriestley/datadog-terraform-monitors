output "monitoring_summary" {
  description = "Summary of created monitoring resources"
  value = {
    services_monitored = keys(local.services)
    total_services     = length(local.services)
    
    monitor_links = {
      for service_name in keys(local.services) :
      service_name => "https://app.datadoghq.com/monitors/manage?q=service%3A${service_name}"
    }
    
    dashboard_links = {
      for service_name in keys(local.services) :
      service_name => module.service_monitoring[service_name].dashboard_url
    }
  }
}
