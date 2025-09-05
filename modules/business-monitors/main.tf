locals {
  service_filter = "service:${var.service_name},env:${var.environment}"
  alert_message  = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.environment}",
    "tier:${var.tier}",
    "managed-by:terraform",
    "monitor-type:business"
  ]
}

# Revenue Monitoring
resource "datadog_monitor" "revenue_decline" {
  name    = "[Business] ${var.service_name} - Revenue Decline"
  type    = "metric alert"
  message = "Revenue has declined significantly for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_30m):sum:business.revenue{${local.service_filter}}.as_rate() < ${var.business_thresholds.revenue_minimum}"

  monitor_thresholds {
    critical = var.business_thresholds.revenue_minimum
  }

  tags = local.base_tags
}

# User Signup Rate
resource "datadog_monitor" "low_signup_rate" {
  name    = "[Business] ${var.service_name} - Low User Signup Rate"
  type    = "metric alert"
  message = "User signup rate is low for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_60m):sum:business.user.signups{${local.service_filter}}.as_rate() * 3600 < ${var.business_thresholds.signup_rate_minimum}"

  monitor_thresholds {
    warning  = var.business_thresholds.signup_rate_minimum * 1.5
    critical = var.business_thresholds.signup_rate_minimum
  }

  tags = local.base_tags
}

# Conversion Rate Monitoring
resource "datadog_monitor" "low_conversion_rate" {
  name    = "[Business] ${var.service_name} - Low Conversion Rate"
  type    = "metric alert"
  message = "Conversion rate is low for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_2h):(sum:business.conversions{${local.service_filter}}.as_rate() / sum:business.visits{${local.service_filter}}.as_rate()) * 100 < ${var.business_thresholds.conversion_rate_minimum}"

  monitor_thresholds {
    warning  = var.business_thresholds.conversion_rate_minimum * 1.2
    critical = var.business_thresholds.conversion_rate_minimum
  }

  tags = local.base_tags
}

# Customer Satisfaction (if tracking NPS or similar)
resource "datadog_monitor" "customer_satisfaction" {
  name    = "[Business] ${var.service_name} - Low Customer Satisfaction"
  type    = "metric alert"
  message = "Customer satisfaction score is low for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_4h):avg:business.nps_score{${local.service_filter}} < 50"

  monitor_thresholds {
    warning  = 60
    critical = 50
  }

  tags = local.base_tags
}

# Transaction Failures
resource "datadog_monitor" "transaction_failure_rate" {
  name    = "[Business] ${var.service_name} - High Transaction Failure Rate"
  type    = "metric alert"
  message = "Transaction failure rate is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):(sum:business.transactions.failed{${local.service_filter}}.as_rate() / sum:business.transactions.total{${local.service_filter}}.as_rate()) * 100 > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = local.base_tags
}