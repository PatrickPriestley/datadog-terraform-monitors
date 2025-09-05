resource "datadog_dashboard" "golden_signals" {
  title       = "Golden Signals - ${var.service_name} (${var.environment})"
  description = "Golden signals monitoring for ${var.service_name}"
  layout_type = "ordered"
  
  # Latency Widget
  widget {
    group_definition {
      title       = "Latency"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "Response Time Percentiles"
          
          request {
            q = "p50:trace.http.request{${local.service_filter}}"
            display_type = "line"
            style {
              palette = "dog_classic"
              line_type = "solid"
              line_width = "normal"
            }
          }
          
          request {
            q = "p95:trace.http.request{${local.service_filter}}"
            display_type = "line"
            style {
              palette = "orange"
              line_type = "solid"
              line_width = "normal"
            }
          }
          
          request {
            q = "p99:trace.http.request{${local.service_filter}}"
            display_type = "line"
            style {
              palette = "warm"
              line_type = "solid"
              line_width = "normal"
            }
          }
          
          yaxis {
            label = "Duration (ms)"
            scale = "linear"
          }
        }
      }
      
      widget {
        heatmap_definition {
          title = "Latency Distribution"
          
          request {
            q = "avg:trace.http.request{${local.service_filter}} by {resource_name}"
          }
        }
      }
    }
  }
  
  # Traffic Widget
  widget {
    group_definition {
      title       = "Traffic"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "Request Rate"
          
          request {
            q = "sum:trace.http.request.hits{${local.service_filter}}.as_rate()"
            display_type = "bars"
            style {
              palette = "dog_classic"
            }
          }
        }
      }
      
      widget {
        toplist_definition {
          title = "Top Endpoints by Traffic"
          
          request {
            q = "top(sum:trace.http.request.hits{${local.service_filter}} by {resource_name}.as_rate(), 10, 'mean', 'desc')"
          }
        }
      }
    }
  }
  
  # Errors Widget
  widget {
    group_definition {
      title       = "Errors"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "Error Rate %"
          
          request {
            q = "(sum:trace.http.request.errors{${local.service_filter}}.as_rate() / sum:trace.http.request.hits{${local.service_filter}}.as_rate()) * 100"
            display_type = "line"
            style {
              palette = "warm"
            }
          }
          
          yaxis {
            label = "Error Rate %"
            scale = "linear"
            min   = "0"
          }
        }
      }
      
      widget {
        query_value_definition {
          title = "Total Errors (last hour)"
          
          request {
            q = "sum:trace.http.request.errors{${local.service_filter}}.as_count()"
            aggregator = "sum"
          }
          
          autoscale = true
          precision = 0
        }
      }
    }
  }
  
  # Saturation Widget
  widget {
    group_definition {
      title       = "Saturation"
      layout_type = "ordered"
      
      widget {
        timeseries_definition {
          title = "CPU Usage by Host"
          
          request {
            q = "avg:system.cpu.user{${local.service_filter}} by {host}"
            display_type = "line"
            style {
              palette = "dog_classic"
            }
          }
          
          yaxis {
            label = "CPU %"
            scale = "linear"
            min   = "0"
            max   = "100"
          }
          
          marker {
            display_type = "error dashed"
            value        = "y = 80"
            label        = "Critical Threshold"
          }
        }
      }
      
      widget {
        timeseries_definition {
          title = "Memory Usage by Host"
          
          request {
            q = "(1 - avg:system.mem.pct_usable{${local.service_filter}} by {host}) * 100"
            display_type = "line"
            style {
              palette = "purple"
            }
          }
          
          yaxis {
            label = "Memory %"
            scale = "linear"
            min   = "0"
            max   = "100"
          }
          
          marker {
            display_type = "error dashed"
            value        = "y = 80"
            label        = "Critical Threshold"
          }
        }
      }
    }
  }
}