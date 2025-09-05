output "monitor_ids" {
  description = "Map of monitor types to their IDs"
  value = {
    # Business KPI monitors
    revenue_decline         = datadog_monitor.revenue_decline.id
    low_signup_rate        = datadog_monitor.low_signup_rate.id
    low_conversion_rate    = datadog_monitor.low_conversion_rate.id
    customer_satisfaction  = datadog_monitor.customer_satisfaction.id
    transaction_failure_rate = datadog_monitor.transaction_failure_rate.id
  }
}

output "synthetic_test_ids" {
  description = "Map of synthetic test types to their IDs"
  value = {
    api_health_check  = var.enable_api_health_checks ? datadog_synthetics_test.api_health_check[0].id : null
    main_page_check   = var.tier == "critical" ? datadog_synthetics_test.main_page_check[0].id : null
  }
}