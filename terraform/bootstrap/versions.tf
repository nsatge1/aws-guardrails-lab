# Versions this stack needs.
# "~> 1.17" means: 1.17 or newer, but never 2.0 (a major version can break the code).
terraform {
  required_version = "~> 1.17"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73"
    }
  }
}

# Credentials come from your AWS CLI profile: run "export AWS_PROFILE=lab" first.
# No access key is written in the code.
provider "aws" {
  region = "eu-west-3" # Paris

  # Terraform adds these tags to every resource of this stack.
  default_tags {
    tags = {
      Project   = "aws-guardrails-lab"
      Stack     = "bootstrap"
      ManagedBy = "terraform"
      Owner     = "nathan"
    }
  }
}
