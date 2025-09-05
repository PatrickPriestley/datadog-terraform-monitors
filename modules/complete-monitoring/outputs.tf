output "dashboard_id" {
  description = "Dashboard ID"
  value       = try(datadog_dashboard.service_overview.id, "")
}

output "dashboard_url" {
  description = "Dashboard URL"
  value       = try(datadog_dashboard.service_overview.url, "")
}

output "monitor_count" {
  description = "Total monitors created"
  value = (
    (contains(var.service_config.monitoring_suites, "golden-signals") ? 5 : 0) +
    (contains(var.service_config.monitoring_suites, "infrastructure") ? 4 : 0) +
    (contains(var.service_config.monitoring_suites, "database") && var.service_config.database_type != "" ? 3 : 0) +
    (contains(var.service_config.monitoring_suites, "application") ? 3 : 0) +
    (contains(var.service_config.monitoring_suites, "security") ? 4 : 0) +
    (contains(var.service_config.monitoring_suites, "business") ? 3 : 0)
  )
}

output "monitor_ids" {
  description = "Map of monitoring suite names to their monitor IDs"
  value = {
    golden_signals = contains(var.service_config.monitoring_suites, "golden-signals") ? module.golden_signals[0].monitor_ids : {}
    infrastructure = contains(var.service_config.monitoring_suites, "infrastructure") ? module.infrastructure[0].monitor_ids : {}
    database       = contains(var.service_config.monitoring_suites, "database") && var.service_config.database_type != "" ? module.database[0].monitor_ids : {}
    application    = contains(var.service_config.monitoring_suites, "application") ? module.application[0].monitor_ids : {}
    security       = contains(var.service_config.monitoring_suites, "security") ? module.security[0].monitor_ids : {}
    business       = contains(var.service_config.monitoring_suites, "business") ? module.business[0].monitor_ids : {}
  }
}

output "service_tags" {
  description = "Tags applied to all monitoring resources"
  value       = local.all_tags
}

output "monitoring_suites_enabled" {
  description = "List of monitoring suites enabled for this service"
  value       = var.service_config.monitoring_suites
}