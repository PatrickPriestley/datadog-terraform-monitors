# Datadog Terraform Monitors

A modular, composable Terraform framework for managing Datadog monitoring at scale. This repository provides a hierarchical module structure that makes it easy to deploy comprehensive monitoring across multiple services while maintaining consistency and reducing duplication.

## Features

- **Modular Architecture**: Compose monitoring from specialized modules (golden signals, infrastructure, database, application, security, business)
- **Service-Centric Configuration**: Define monitoring requirements per service with automatic alert routing
- **Tier-Based Alerting**: Intelligent alert routing based on service criticality and environment
- **Multi-Runtime Support**: Built-in support for Node.js, JVM, Python runtimes
- **Database Monitoring**: Specialized monitors for PostgreSQL, MySQL, and Redis
- **Golden Signals Out-of-the-Box**: Latency, traffic, errors, and saturation monitoring ready to deploy
- **Composable Design**: Enable only the monitoring suites you need per service

## Quick Start

### Prerequisites

- Terraform >= 1.0
- Datadog account with API and Application keys
- Access to Datadog API (default: US5 region)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd datadog-terraform-monitors
```

2. Set up your Datadog credentials:
```bash
export TF_VAR_datadog_api_key="your-api-key"
export TF_VAR_datadog_app_key="your-app-key"
```

Or create a `terraform.tfvars` file:
```hcl
datadog_api_key = "your-api-key"
datadog_app_key = "your-app-key"
organization_name = "YourCompany"
```

3. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

## Architecture

### Module Hierarchy

```
Root Configuration (main.tf)
    └── Complete Monitoring Module (per service)
            ├── Golden Signals Module
            ├── Infrastructure Monitors Module
            ├── Database Monitors Module
            ├── Application Monitors Module
            ├── Security Monitors Module
            └── Business Monitors Module
```

### How It Works

1. **Services are defined** in `main.tf` with their configuration (runtime, database, tier, monitoring suites)
2. **Complete Monitoring orchestrates** the specialized modules based on each service's `monitoring_suites` setting
3. **Specialized modules create** targeted monitors for their domain (e.g., golden signals, infrastructure)
4. **Alert routing is automatic** based on service tier and environment configuration

## Configuration

### Service Definition

Services are configured in `main.tf` under `locals.services`:

```hcl
services = {
  "web-app" = {
    environment       = "production"        # production/staging/development
    tier             = "critical"          # critical/important/standard
    team             = "frontend"          # owning team
    runtime          = "node"              # node/jvm/python
    database_type    = "postgresql"        # postgresql/mysql/redis
    queue_type       = "sqs"               # sqs/rabbitmq/kafka
    service_type     = "web"               # web/api/worker
    deployment_type  = "kubernetes"        # kubernetes/ecs/ec2
    monitoring_suites = [                  # enabled monitoring modules
      "golden-signals",
      "infrastructure",
      "database",
      "application"
    ]
    custom_tags = ["customer-facing"]      # additional Datadog tags
  }
}
```

### Alert Routing

Alert destinations are configured based on service tier and environment in `local.alert_configs`:

```hcl
alert_configs = {
  critical = {
    production = ["@slack-oncall", "@pagerduty-critical"]
    staging    = ["@slack-dev-alerts"]
  }
  important = {
    production = ["@slack-alerts", "@pagerduty-high"]
    staging    = ["@slack-dev"]
  }
  standard = {
    production = ["@slack-alerts"]
    staging    = ["@slack-dev"]
  }
}
```

## Available Monitoring Suites

### Golden Signals (Implemented)
The Four Golden Signals from Google's SRE book:
- **Latency**: P95/P99 response time monitors
- **Traffic**: Request rate and traffic drop detection
- **Errors**: Error rate percentage monitoring
- **Saturation**: CPU and memory utilization alerts

**Usage**: Add `"golden-signals"` to `monitoring_suites`

### Infrastructure Monitors (Structure Ready)
System-level resource monitoring:
- CPU utilization
- Memory usage and pressure
- Disk space and I/O
- Host availability checks

**Usage**: Add `"infrastructure"` to `monitoring_suites`

### Database Monitors (Structure Ready)
Database-specific monitoring for:
- **PostgreSQL**: Connection pools, query performance, replication lag
- **MySQL**: Query performance, replication, InnoDB metrics
- **Redis**: Memory usage, evictions, key space statistics

**Usage**: Add `"database"` to `monitoring_suites` and set `database_type`

### Application Monitors (Structure Ready)
Runtime-specific application monitoring:
- **JVM**: Heap usage, GC pauses, thread pools
- **Node.js**: Event loop lag, memory leaks
- **Python**: Memory usage, exception rates
- Queue monitoring for async workloads

**Usage**: Add `"application"` to `monitoring_suites` and set `runtime`

### Security Monitors (Structure Ready)
Security and compliance monitoring:
- Authentication failures
- Network anomalies
- Compliance checks

**Usage**: Add `"security"` to `monitoring_suites`

### Business Monitors (Structure Ready)
Business metrics and user experience:
- Synthetic tests for critical user flows
- Business KPI tracking
- Custom metric monitoring

**Usage**: Add `"business"` to `monitoring_suites`

## Outputs

After applying, Terraform outputs useful information:

```hcl
monitoring_summary = {
  services_monitored = ["web-app", "api-service"]
  total_services     = 2
  monitor_links = {
    web-app = "https://app.datadoghq.com/monitors/manage?q=service%3Aweb-app"
  }
  dashboard_links = {
    web-app = "<dashboard-url>"
  }
}
```

## Development

### Adding a New Service

1. Add service configuration to `local.services` in `main.tf`
2. Choose appropriate monitoring suites for the service
3. Set tier level for proper alert routing
4. Run `terraform plan` to preview changes
5. Apply with `terraform apply`

### Adding New Monitors to a Module

1. Navigate to the appropriate module (e.g., `modules/golden-signals/`)
2. Add monitor resources to `main.tf` or create new specialized files
3. Update `outputs.tf` to export new monitor IDs
4. Test with a single service first using `-target`

### Module Structure

Each specialized module follows this structure:
```
module-name/
├── main.tf          # Monitor definitions
├── variables.tf     # Input variables
├── outputs.tf       # Exported values (monitor IDs, URLs)
├── versions.tf      # Terraform/provider version constraints
└── locals.tf        # Local helper variables
```

## Terraform Commands

```bash
# Format code
terraform fmt -recursive .

# Validate configuration
terraform validate

# Plan specific service
terraform plan -target=module.service_monitoring["web-app"]

# Apply specific service
terraform apply -target=module.service_monitoring["web-app"]

# Show outputs
terraform output monitoring_summary

# Destroy all monitoring
terraform destroy
```

## Current Status

This is a **proof-of-concept repository** demonstrating a scalable approach to Datadog monitoring with Terraform.

**Implemented:**
- ✅ Root module orchestration
- ✅ Golden Signals monitoring suite (fully implemented)
- ✅ Complete monitoring orchestrator structure
- ✅ Service-based configuration model
- ✅ Tier-based alert routing

**In Progress:**
- 🔨 Infrastructure monitors module implementation
- 🔨 Database monitors module implementation
- 🔨 Application monitors module implementation
- 🔨 Security monitors module implementation
- 🔨 Business monitors module implementation

Module structures are in place, but monitor definitions need to be implemented.

## Best Practices

1. **Start Small**: Enable `golden-signals` first, then add specialized modules
2. **Test in Staging**: Always test new monitors in staging before production
3. **Use Descriptive Names**: Service names should match your actual service identifiers
4. **Tune Thresholds**: Default thresholds are starting points; adjust based on your SLOs
5. **Tag Consistently**: Use custom_tags to support cross-service queries
6. **Version Control**: Commit threshold changes with context in commit messages

## Roadmap

- [ ] Implement remaining monitor modules
- [ ] Add SLO/SLI definitions alongside monitors
- [ ] Create shared dashboard templates
- [ ] Add cost monitoring suite
- [ ] Support for multi-region deployments
- [ ] Module versioning and release process
- [ ] Examples directory with common patterns

## Contributing

This is a POC repository. For production use:

1. Fork and adapt to your organization's needs
2. Implement remaining monitor modules based on your requirements
3. Adjust alert thresholds to match your SLOs
4. Customize alert routing to match your incident response workflow

## License

[Your License Here]

## Support

For issues specific to this repository structure, please open an issue. For Datadog-specific questions, refer to [Datadog Documentation](https://docs.datadoghq.com/).
