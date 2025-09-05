output "monitor_ids" {
  description = "Map of monitor types to their IDs"
  value = {
    latency_p95          = datadog_monitor.latency_p95.id
    latency_p99          = datadog_monitor.latency_p99.id
    traffic_drop         = datadog_monitor.traffic_drop.id
    error_rate           = datadog_monitor.error_rate.id
    saturation_composite = datadog_monitor.saturation_composite.id
    cpu_saturation       = datadog_monitor.cpu_saturation.id
    memory_saturation    = datadog_monitor.memory_saturation.id
  }
}

output "dashboard_id" {
  description = "Golden signals dashboard ID"
  value       = try(datadog_dashboard.golden_signals.id, "")
}

output "dashboard_url" {
  description = "Golden signals dashboard URL"
  value       = try(datadog_dashboard.golden_signals.url, "")
}