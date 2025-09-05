terraform {
  required_version = ">= 1.0"
  
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.45"
    }
  }
  
  # Configure remote state (recommended) - uncomment when ready to use
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "datadog-monitoring/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-locks"
  # }
}
