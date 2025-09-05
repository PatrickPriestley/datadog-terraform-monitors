# Datadog Monitoring with Terraform - Complete Implementation Guide

## Overview
This guide provides complete instructions for implementing a reusable, modular Datadog monitoring system using Terraform. The system supports multiple monitoring suites (Golden Signals, Infrastructure, Database, Security, etc.) and can be easily deployed across different environments.

## Prerequisites
- Terraform >= 1.0 installed
- Datadog account with API and Application keys
- AWS account (for state storage)
- Git repository for code storage

## Project Structure

Create the following directory structure:

```
datadog-monitoring/
├── modules/
│   ├── complete-monitoring/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── dashboards.tf
│   │   └── README.md
│   ├── golden-signals/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── infrastructure-monitors/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── database-monitors/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── postgres.tf
│   │   ├── mysql.tf
│   │   └── redis.tf
│   ├── application-monitors/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── jvm.tf
│   ├── security-monitors/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── business-monitors/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── synthetic.tf
├── environments/
│   ├── production/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── backend.tf
│   │   ├── versions.tf
│   │   └── terraform.tfvars.example
│   ├── staging/
│   │   └── (similar structure)
│   └── development/
│       └── (similar structure)
├── scripts/
│   ├── deploy.sh
│   ├── validate-monitoring.sh
│   └── backup-monitoring.sh
├── .gitignore
├── README.md
└── Makefile
```

## Implementation Steps

### Step 1: Create Module Files

#### 1.1 Complete Monitoring Module (modules/complete-monitoring/)

**main.tf:**
```hcl
# Main module orchestration logic
locals {
  service_filter = "service:${var.service_name},env:${var.service_config.environment}"
  alert_message  = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.service_config.environment}",
    "team:${var.service_config.team}",
    "tier:${var.service_config.tier}",
    "managed-by:terraform"
  ]
  all_tags = concat(local.base_tags, var.service_config.custom_tags)
}

# Golden Signals Monitors (if enabled)
module "golden_signals" {
  source = "../golden-signals"
  count  = contains(var.service_config.monitoring_suites, "golden-signals") ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  alert_channels = var.alert_channels
}

# Infrastructure Monitors (if enabled)
module "infrastructure" {
  source = "../infrastructure-monitors"
  count  = contains(var.service_config.monitoring_suites, "infrastructure") ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  alert_channels = var.alert_channels
}

# Database Monitors (if enabled and database specified)
module "database" {
  source = "../database-monitors"
  count  = contains(var.service_config.monitoring_suites, "database") && var.service_config.database_type != "" ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  database_type  = var.service_config.database_type
  alert_channels = var.alert_channels
}

# Application Monitors (if enabled)
module "application" {
  source = "../application-monitors"
  count  = contains(var.service_config.monitoring_suites, "application") ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  runtime        = var.service_config.runtime
  queue_type     = var.service_config.queue_type
  alert_channels = var.alert_channels
}

# Security Monitors (if enabled)
module "security" {
  source = "../security-monitors" 
  count  = contains(var.service_config.monitoring_suites, "security") ? 1 : 0
  
  service_name              = var.service_name
  environment               = var.service_config.environment
  alert_channels           = var.alert_channels
  enable_synthetic_tests   = var.service_config.tier == "critical"
  enable_api_health_checks = var.service_config.service_type == "api"
}

# Business Monitors (if enabled)
module "business" {
  source = "../business-monitors"
  count  = contains(var.service_config.monitoring_suites, "business") ? 1 : 0
  
  service_name   = var.service_name
  environment    = var.service_config.environment
  alert_channels = var.alert_channels
  
  business_thresholds = {
    revenue_minimum = 1000
    signup_rate_minimum = 10
    conversion_rate_minimum = 2.5
  }
}
```

**variables.tf:**
```hcl
variable "service_name" {
  description = "Name of the service"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.service_name))
    error_message = "Service name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "service_config" {
  description = "Service configuration object"
  type = object({
    environment       = string
    tier             = string
    team             = string
    runtime          = string
    database_type    = string
    queue_type       = string
    service_type     = string
    deployment_type  = string
    monitoring_suites = list(string)
    custom_tags      = list(string)
  })
  
  validation {
    condition = contains(["production", "staging", "development"], var.service_config.environment)
    error_message = "Environment must be production, staging, or development."
  }
  
  validation {
    condition = contains(["critical", "important", "standard"], var.service_config.tier)
    error_message = "Tier must be critical, important, or standard."
  }
}

variable "alert_channels" {
  description = "List of alert notification channels"
  type        = list(string)
  default     = []
  
  validation {
    condition = alltrue([
      for channel in var.alert_channels : can(regex("^@", channel))
    ])
    error_message = "All alert channels must start with @."
  }
}

variable "organization_name" {
  description = "Organization name"
  type        = string
  default     = "MyCompany"
}
```

**outputs.tf:**
```hcl
output "dashboard_id" {
  description = "Dashboard ID"
  value       = datadog_dashboard.service_overview.id
}

output "dashboard_url" {
  description = "Dashboard URL"
  value       = datadog_dashboard.service_overview.url
}

output "monitor_count" {
  description = "Total monitors created"
  value = (
    (contains(var.service_config.monitoring_suites, "golden-signals") ? 5 : 0) +
    (contains(var.service_config.monitoring_suites, "infrastructure") ? 4 : 0) +
    (contains(var.service_config.monitoring_suites, "database") && var.service_config.database_type != "" ? 3 : 0) +
    (contains(var.service_config.monitoring_suites, "application") ? 3 : 0) +
    (contains(var.service_config.monitoring_suites, "security") ? 4 : 0)
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
```

**dashboards.tf:**
```hcl
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

  # Golden Signals Section (if enabled)
  dynamic "widget" {
    for_each = contains(var.service_config.monitoring_suites, "golden-signals") ? [1] : []
    
    content {
      group_definition {
        title       = "🎯 Golden Signals"
        layout_type = "ordered"
        
        widget {
          timeseries_definition {
            title = "Request Rate & Errors"
            
            request {
              q            = "sum:trace.web.request.hits{${local.service_filter}}.as_rate()"
              display_type = "bars"
              style {
                palette = "dog_classic"
              }
            }
            
            request {
              q            = "sum:trace.web.request.errors{${local.service_filter}}.as_rate()"
              display_type = "bars"
              style {
                palette = "warm"
              }
            }
          }
        }
        
        widget {
          timeseries_definition {
            title = "Response Time Percentiles"
            
            request {
              q = "p50:trace.web.request.duration{${local.service_filter}}"
            }
            
            request {
              q = "p95:trace.web.request.duration{${local.service_filter}}"
            }
            
            request {
              q = "p99:trace.web.request.duration{${local.service_filter}}"
            }
          }
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
            }
            
            request {
              q = "(1 - avg:system.mem.pct_usable{${local.service_filter}}) * 100 by {host}"
            }
          }
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
}
```

#### 1.2 Golden Signals Module (modules/golden-signals/)

**main.tf:**
```hcl
locals {
  service_filter = "service:${var.service_name},env:${var.environment}"
  alert_message = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.environment}",
    "managed-by:terraform",
    "monitor-type:golden-signals"
  ]
}

# 1. LATENCY - Response time monitoring
resource "datadog_monitor" "latency_p95" {
  name    = "[Golden Signal] ${var.service_name} - High Latency (p95)"
  type    = "metric alert"
  message = "P95 latency is above threshold for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):p95:trace.web.request.duration{${local.service_filter}} > 1"

  monitor_thresholds {
    warning  = 0.8
    critical = 1.0
  }

  tags = local.base_tags
}

# 2. TRAFFIC - Request rate monitoring
resource "datadog_monitor" "traffic_drop" {
  name    = "[Golden Signal] ${var.service_name} - Traffic Drop"
  type    = "metric alert"
  message = "Traffic has dropped significantly for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_15m):avg:trace.web.request.hits{${local.service_filter}}.as_rate() < 10"

  monitor_thresholds {
    critical = 10
  }

  tags = local.base_tags
}

# 3. ERRORS - Error rate monitoring  
resource "datadog_monitor" "error_rate" {
  name    = "[Golden Signal] ${var.service_name} - High Error Rate"
  type    = "metric alert"
  message = "Error rate is above threshold for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):(sum:trace.web.request.errors{${local.service_filter}}.as_rate() / sum:trace.web.request.hits{${local.service_filter}}.as_rate()) * 100 > 5"

  monitor_thresholds {
    warning  = 2
    critical = 5
  }

  tags = local.base_tags
}

# 4. SATURATION - Resource utilization
resource "datadog_monitor" "cpu_saturation" {
  name    = "[Golden Signal] ${var.service_name} - CPU Saturation"
  type    = "metric alert"
  message = "CPU saturation is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:system.cpu.user{${local.service_filter}} by {host} > 0.8"

  monitor_thresholds {
    warning  = 0.7
    critical = 0.8
  }

  tags = local.base_tags
}

resource "datadog_monitor" "memory_saturation" {
  name    = "[Golden Signal] ${var.service_name} - Memory Saturation"
  type    = "metric alert"
  message = "Memory saturation is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:system.mem.pct_usable{${local.service_filter}} by {host} < 0.2"

  monitor_thresholds {
    warning  = 0.3
    critical = 0.2
  }

  tags = local.base_tags
}
```

**variables.tf:**
```hcl
variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alert_channels" {
  description = "List of alert notification channels"
  type        = list(string)
  default     = []
}
```

**outputs.tf:**
```hcl
output "monitor_ids" {
  description = "Map of monitor types to their IDs"
  value = {
    latency_p95       = datadog_monitor.latency_p95.id
    traffic_drop      = datadog_monitor.traffic_drop.id
    error_rate        = datadog_monitor.error_rate.id
    cpu_saturation    = datadog_monitor.cpu_saturation.id
    memory_saturation = datadog_monitor.memory_saturation.id
  }
}
```

#### 1.3 Infrastructure Monitors Module (modules/infrastructure-monitors/)

**main.tf:**
```hcl
locals {
  service_filter = "service:${var.service_name},env:${var.environment}"
  alert_message = join(" ", var.alert_channels)
  
  base_tags = [
    "service:${var.service_name}",
    "environment:${var.environment}",
    "managed-by:terraform",
    "monitor-type:infrastructure"
  ]
}

# Host Availability Monitor
resource "datadog_monitor" "host_availability" {
  name    = "[Infrastructure] ${var.service_name} - Host Down"
  type    = "service check"
  message = "Host is down for ${var.service_name} ${local.alert_message}"
  query   = '"datadog.agent.up".over("service:${var.service_name}","env:${var.environment}").by("host").last(2).count_by_status()'

  monitor_thresholds {
    warning  = 1
    critical = 1
  }

  notify_no_data    = true
  no_data_timeframe = 5
  tags              = local.base_tags
}

# CPU Usage Monitor
resource "datadog_monitor" "cpu_usage" {
  name    = "[Infrastructure] ${var.service_name} - High CPU Usage"
  type    = "metric alert"
  message = "CPU usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):avg:system.cpu.user{${local.service_filter}} by {host} > 0.85"

  monitor_thresholds {
    warning  = 0.7
    critical = 0.85
  }

  tags = local.base_tags
}

# Memory Usage Monitor
resource "datadog_monitor" "memory_usage" {
  name    = "[Infrastructure] ${var.service_name} - High Memory Usage"
  type    = "metric alert"
  message = "Memory usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_10m):avg:system.mem.pct_usable{${local.service_filter}} by {host} < 0.15"

  monitor_thresholds {
    warning  = 0.2
    critical = 0.15
  }

  tags = local.base_tags
}

# Disk Usage Monitor
resource "datadog_monitor" "disk_usage" {
  name    = "[Infrastructure] ${var.service_name} - High Disk Usage"
  type    = "metric alert"
  message = "Disk usage is high for ${var.service_name} ${local.alert_message}"
  query   = "avg(last_5m):max:system.disk.used{${local.service_filter}} by {host,device} > 0.9"

  monitor_thresholds {
    warning  = 0.8
    critical = 0.9
  }

  tags = local.base_tags
}
```

**variables.tf:**
```hcl
variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alert_channels" {
  description = "List of alert notification channels"
  type        = list(string)
  default     = []
}
```

**outputs.tf:**
```hcl
output "monitor_ids" {
  description = "Map of monitor types to their IDs"
  value = {
    host_availability = datadog_monitor.host_availability.id
    cpu_usage        = datadog_monitor.cpu_usage.id
    memory_usage     = datadog_monitor.memory_usage.id
    disk_usage       = datadog_monitor.disk_usage.id
  }
}
```

#### 1.4 Create Placeholder Modules

For the remaining modules (database-monitors, application-monitors, security-monitors, business-monitors), create similar structures with basic variables.tf and outputs.tf files. The main.tf files can be minimal for now.

### Step 2: Environment Configuration

#### 2.1 Production Environment (environments/production/)

**versions.tf:**
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.45"
    }
  }
}
```

**providers.tf:**
```hcl
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}
```

**variables.tf:**
```hcl
variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog Application key"
  type        = string
  sensitive   = true
}

variable "datadog_api_url" {
  description = "Datadog API URL"
  type        = string
  default     = "https://api.datadoghq.com/"
}

variable "organization_name" {
  description = "Organization name for tagging"
  type        = string
  default     = "MyCompany"
}
```

**main.tf:**
```hcl
# Local variables for this environment
locals {
  environment = "production"
  
  # Define services for production
  services = {
    "web-app" = {
      environment     = local.environment
      tier           = "critical"
      team           = "frontend"
      runtime        = "node"
      database_type  = "postgresql"
      queue_type     = "sqs"
      service_type   = "web"
      deployment_type = "kubernetes"
      monitoring_suites = ["golden-signals", "infrastructure"]
      custom_tags = ["customer-facing"]
    }
    
    "api-service" = {
      environment     = local.environment
      tier           = "critical"
      team           = "backend"
      runtime        = "jvm"
      database_type  = "postgresql"
      queue_type     = "sqs"
      service_type   = "api"
      deployment_type = "kubernetes"
      monitoring_suites = ["golden-signals", "infrastructure"]
      custom_tags = ["core-service"]
    }
  }

  # Alert routing for production
  alert_configs = {
    critical = ["@slack-oncall", "@pagerduty-critical"]
    important = ["@slack-alerts"]
    standard = ["@slack-alerts"]
  }
}

# Create monitoring for all services
module "service_monitoring" {
  source = "../../modules/complete-monitoring"
  
  for_each = local.services
  
  service_name      = each.key
  service_config    = each.value
  alert_channels    = local.alert_configs[each.value.tier]
  organization_name = var.organization_name
}
```

**outputs.tf:**
```hcl
output "monitoring_summary" {
  description = "Summary of created monitoring resources"
  value = {
    environment       = local.environment
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
    
    total_monitors = sum([
      for service_name in keys(local.services) :
      module.service_monitoring[service_name].monitor_count
    ])
  }
}
```

**terraform.tfvars.example:**
```hcl
# Copy this file to terraform.tfvars and fill in your values

# Datadog credentials (get from Datadog Organization Settings)
datadog_api_key = "your-datadog-api-key-here"
datadog_app_key = "your-datadog-app-key-here"

# Organization settings
organization_name = "YourCompany"
datadog_api_url   = "https://api.datadoghq.com/"  # Use datadoghq.eu for EU
```

### Step 3: Root Files

**.gitignore:**
```
# Terraform files
*.tfstate
*.tfstate.*
*.tfplan
.terraform/
.terraform.lock.hcl

# Variable files with secrets
terraform.tfvars
*.auto.tfvars

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Backup files
*.backup
*.bak

# Log files
*.log
```

**README.md:**
```markdown
# Datadog Monitoring Infrastructure

This repository contains Terraform configuration for managing Datadog monitors and dashboards across all services.

## Quick Start

1. Set environment variables:
   ```bash
   export TF_VAR_datadog_api_key="your-api-key"
   export TF_VAR_datadog_app_key="your-app-key"
   ```

2. Initialize and deploy to production:
   ```bash
   cd environments/production
   terraform init
   terraform plan
   terraform apply
   ```

## Adding a New Service

Edit `environments/production/main.tf` and add your service to the `services` local variable:

```hcl
"new-service" = {
  environment     = "production"
  tier           = "standard"
  team           = "backend"
  runtime        = "python"
  database_type  = ""
  queue_type     = ""
  service_type   = "api"
  deployment_type = "kubernetes"
  monitoring_suites = ["golden-signals", "infrastructure"]
  custom_tags = ["new-service"]
}
```

## Monitoring Suites

- `golden-signals`: Latency, traffic, errors, saturation
- `infrastructure`: CPU, memory, disk, network
- `database`: Connection pools, slow queries, replication lag
- `application`: Runtime-specific metrics (JVM, Node.js, etc.)
- `security`: Authentication failures, SSL certificates
- `business`: Revenue metrics, conversion rates
```

**Makefile:**
```makefile
.PHONY: help plan apply destroy validate format

# Default environment
ENV ?= production

help:
	@echo "Available commands:"
	@echo "  make plan ENV=production     - Plan changes for environment"
	@echo "  make apply ENV=production    - Apply changes for environment"
	@echo "  make validate               - Validate Terraform files"
	@echo "  make format                 - Format Terraform files"

validate:
	terraform -chdir=environments/$(ENV) validate

format:
	terraform fmt -recursive .

plan:
	terraform -chdir=environments/$(ENV) plan

apply:
	terraform -chdir=environments/$(ENV) apply

destroy:
	terraform -chdir=environments/$(ENV) destroy
```

## Implementation Instructions for Claude Code

1. **Create the project structure** as outlined above
2. **Start with the complete-monitoring module** and golden-signals module as they contain the core logic
3. **Create placeholder modules** for database, application, security, and business monitors (basic variables.tf and outputs.tf with empty main.tf)
4. **Set up the production environment** with the files specified
5. **Create terraform.tfvars** in environments/production/ with your Datadog credentials
6. **Test the deployment** with a simple service first

## Variables You Need to Set

Since you mentioned you have your Datadog variables set, create `environments/production/terraform.tfvars`:

```hcl
datadog_api_key = "your-actual-api-key"
datadog_app_key = "your-actual-app-key"
organization_name = "YourActualCompanyName"
```

## Deployment Commands

```bash
# Navigate to production environment
cd environments/production

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

This implementation will create:
- Datadog monitors for latency, traffic, errors, saturation, CPU, memory, disk, and host availability
- A comprehensive dashboard for each service
- Proper tagging and organization
- Modular structure for easy expansion

Start with this foundation and then expand by filling in the placeholder modules with the detailed monitor definitions from the earlier artifacts.