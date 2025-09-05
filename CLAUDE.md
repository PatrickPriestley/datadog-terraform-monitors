# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
This is a Terraform-based Datadog monitoring infrastructure that provides modular, reusable monitoring suites for different services. The project uses a hierarchical module structure to compose monitoring configurations from smaller, specialized modules.

## Key Commands

### Terraform Operations
```bash
# Initialize Terraform (required before any operations)
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive .

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy
```

### Development Workflow
```bash
# Check for syntax errors
terraform fmt -check -recursive .

# Validate all modules
terraform validate

# Generate plan output for review
terraform plan -out=tfplan

# Apply specific targets
terraform apply -target=module.service_monitoring["web-app"]
```

## Architecture

### Module Hierarchy
The project follows a compositional pattern where the main configuration orchestrates multiple specialized monitoring modules:

1. **Root Module** (`main.tf`): Defines services and instantiates the complete-monitoring module for each
2. **Complete Monitoring Module** (`modules/complete-monitoring/`): Orchestrator that conditionally includes specialized modules based on `monitoring_suites` configuration
3. **Specialized Modules**: Individual monitoring concerns (golden-signals, infrastructure, database, application, security, business)

### Service Configuration Structure
Services are defined in `main.tf` with this schema:
- `environment`: deployment environment (production/staging/development)
- `tier`: criticality level (critical/important/standard) - determines alert routing
- `team`: owning team
- `runtime`: application runtime (node/jvm/python)
- `database_type`: database engine (postgresql/mysql/redis)
- `monitoring_suites`: list of monitoring modules to enable
- `custom_tags`: additional Datadog tags

### Alert Routing
Alerts are routed based on service tier and environment, defined in `local.alert_configs`. Critical production services route to PagerDuty and on-call channels.

## Module Implementation Status
- **Complete Monitoring**: Orchestrator module (needs implementation)
- **Golden Signals**: Latency, traffic, errors, saturation monitors (partially implemented)
- **Infrastructure**: CPU, memory, disk, host availability (has locals.tf structure)
- **Database**: PostgreSQL, MySQL, Redis specific monitors (has separate .tf files)
- **Application**: JVM, Node.js, queue monitoring (has runtime-specific files)
- **Security**: Auth, network, compliance monitoring (has category files)
- **Business**: Business metrics and synthetics (has synthetics.tf)

## Important Notes
- All module main.tf files are currently empty and need implementation
- The project structure is complete but modules lack monitor definitions
- Each specialized module should export a `monitor_ids` output for tracking
- Datadog provider credentials need to be set via environment variables or terraform.tfvars