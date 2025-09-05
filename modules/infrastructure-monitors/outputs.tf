output "monitor_ids" {
  description = "Map of monitor types to their IDs"
  value = {
    host_availability = datadog_monitor.host_availability.id
    cpu_usage        = datadog_monitor.cpu_usage.id
    memory_usage     = datadog_monitor.memory_usage.id
    disk_usage       = datadog_monitor.disk_usage.id
    network_errors   = datadog_monitor.network_errors.id
    load_average     = datadog_monitor.load_average.id
  }
}