output "monitor_ids" {
  description = "Map of monitor types to their IDs"
  value = merge(
    {
      # Always-enabled monitors
      auth_failure_rate      = datadog_monitor.auth_failure_rate.id
      auth_brute_force       = datadog_monitor.auth_brute_force.id
      ssl_certificate_expiry = datadog_monitor.ssl_certificate_expiry.id
      ddos_attack           = datadog_monitor.ddos_attack.id
      outbound_data_spike   = datadog_monitor.outbound_data_spike.id
    },
    
    # Conditional log-based monitors
    var.enable_log_monitoring ? {
      privilege_escalation   = datadog_monitor.privilege_escalation[0].id
      unusual_login_location = datadog_monitor.unusual_login_location[0].id
      port_scan             = datadog_monitor.port_scan[0].id
      config_change        = datadog_monitor.config_change[0].id
      audit_log_tampering  = datadog_monitor.audit_log_tampering[0].id
      data_exfiltration    = datadog_monitor.data_exfiltration[0].id
      api_key_exposure     = datadog_monitor.api_key_exposure[0].id
    } : {}
  )
}