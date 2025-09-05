resource "datadog_dashboard" "service_overview" {
  title       = "${var.organization_name} - ${var.service_name} (${var.service_config.environment})"
  description = "Comprehensive monitoring dashboard for ${var.service_name}"
  layout_type = "ordered"
  
  # Service Health Overview
  widget {
    group_definition {
      title       = "🏥 Service Health"
      layout_type = "ordered"
      
      widget {
        query_value_definition {
          title = "Service Status"
          
          request {
            q          = "avg:service.health.status{${local.service_filter}}"
            aggregator = "last"
          }
          
          custom_unit = ""
          precision   = 0
        }
      }
      
      widget {
        check_status_definition {
          title = "Monitor Status"
          check = "datadog.agent.up"
          group = local.service_filter
          grouping = "cluster"
        }
      }
    }
  }


  # Infrastructure Section (if enabled)
  dynamic "widget" {
    for_each = contains(var.service_config.monitoring_suites, "infrastructure") ? [1] : []
    
    content {
      group_definition {
        title       = "🖥️ Infrastructure"
        layout_type = "ordered"
        
        widget {
          timeseries_definition {
            title = "CPU & Memory Usage"
            
            request {
              q = "avg:system.cpu.user{${local.service_filter}} by {host}"
              display_type = "line"
              style {
                palette = "dog_classic"
              }
            }
            
            request {
              q = "(1 - avg:system.mem.pct_usable{${local.service_filter}}) * 100 by {host}"
              display_type = "line"
              style {
                palette = "purple"
              }
            }
          }
        }
        
        widget {
          timeseries_definition {
            title = "Disk I/O"
            
            request {
              q = "avg:system.disk.read_time_pct{${local.service_filter}} by {host}"
              display_type = "area"
            }
            
            request {
              q = "avg:system.disk.write_time_pct{${local.service_filter}} by {host}"
              display_type = "area"
            }
          }
        }
        
        widget {
          toplist_definition {
            title = "Top Hosts by CPU"
            
            request {
              q = "top(avg:system.cpu.user{${local.service_filter}} by {host}, 10, 'mean', 'desc')"
            }
          }
        }
      }
    }
  }

  # Database Section (if enabled and database type specified)
  dynamic "widget" {
    for_each = contains(var.service_config.monitoring_suites, "database") && var.service_config.database_type != "" ? [1] : []
    
    content {
      group_definition {
        title       = "🗄️ Database (${var.service_config.database_type})"
        layout_type = "ordered"
        
        widget {
          timeseries_definition {
            title = "Database Connections"
            
            request {
              q = "avg:database.connections{${local.service_filter}}"
              display_type = "line"
            }
          }
        }
        
        widget {
          query_value_definition {
            title = "Query Performance"
            
            request {
              q = "avg:database.queries{${local.service_filter}}.as_rate()"
            }
          }
        }
      }
    }
  }

  # Application Section (if enabled)
  dynamic "widget" {
    for_each = contains(var.service_config.monitoring_suites, "application") ? [1] : []
    
    content {
      group_definition {
        title       = "🚀 Application (${var.service_config.runtime})"
        layout_type = "ordered"
        
        widget {
          timeseries_definition {
            title = "Runtime Metrics"
            
            request {
              q = "avg:runtime.memory{${local.service_filter}}"
              display_type = "line"
            }
          }
        }
        
        dynamic "widget" {
          for_each = var.service_config.queue_type != "" ? [1] : []
          content {
            query_value_definition {
              title = "Queue Depth"
              
              request {
                q = "avg:queue.depth{${local.service_filter}}"
              }
            }
          }
        }
      }
    }
  }

  # Security Section (if enabled)
  dynamic "widget" {
    for_each = contains(var.service_config.monitoring_suites, "security") ? [1] : []
    
    content {
      group_definition {
        title       = "🔒 Security"
        layout_type = "ordered"
        
        widget {
          timeseries_definition {
            title = "Authentication Events"
            
            request {
              q = "sum:security.auth.success{${local.service_filter}}.as_rate()"
              display_type = "bars"
              style {
                palette = "green"
              }
            }
            
            request {
              q = "sum:security.auth.failure{${local.service_filter}}.as_rate()"
              display_type = "bars"
              style {
                palette = "warm"
              }
            }
          }
        }
        
        widget {
          query_value_definition {
            title = "SSL Certificate Expiry (days)"
            
            request {
              q = "min:http.ssl.days_left{${local.service_filter}}"
            }
            
            conditional_format {
              comparator = "<"
              value      = "30"
              palette    = "red"
            }
            
            conditional_format {
              comparator = "<"
              value      = "60"
              palette    = "yellow"
            }
            
            conditional_format {
              comparator = ">="
              value      = "60"
              palette    = "green"
            }
          }
        }
      }
    }
  }

  # Business Metrics Section (if enabled)
  dynamic "widget" {
    for_each = contains(var.service_config.monitoring_suites, "business") ? [1] : []
    
    content {
      group_definition {
        title       = "💼 Business Metrics"
        layout_type = "ordered"
        
        widget {
          timeseries_definition {
            title = "Revenue Metrics"
            
            request {
              q = "sum:business.revenue{${local.service_filter}}.as_rate()"
              display_type = "bars"
              style {
                palette = "green"
              }
            }
          }
        }
        
        widget {
          query_value_definition {
            title = "Conversion Rate %"
            
            request {
              q = "(sum:business.conversions{${local.service_filter}}.as_rate() / sum:business.visits{${local.service_filter}}.as_rate()) * 100"
            }
            
            custom_unit = "%"
            precision   = 2
          }
        }
        
        widget {
          timeseries_definition {
            title = "User Signups"
            
            request {
              q = "sum:business.user.signups{${local.service_filter}}.as_rate()"
              display_type = "bars"
            }
          }
        }
      }
    }
  }

  # Logs Section
  widget {
    group_definition {
      title       = "📋 Recent Logs"
      layout_type = "ordered"
      
      widget {
        log_stream_definition {
          indexes     = ["*"]
          query       = local.service_filter
          columns     = ["timestamp", "status", "service", "message"]
          show_date_column   = true
          show_message_column = true
          message_display    = "expanded-md"
        }
      }
    }
  }

  template_variable {
    name    = "service"
    prefix  = "service"
    default = var.service_name
  }
  
  template_variable {
    name    = "environment"
    prefix  = "env"
    default = var.service_config.environment
  }
  
  template_variable {
    name    = "host"
    prefix  = "host"
    default = "*"
  }
}