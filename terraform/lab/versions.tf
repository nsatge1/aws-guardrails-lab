# Versions this stack needs (same rules as terraform/bootstrap).
terraform {
  required_version = "~> 1.17"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73"
    }
  }

  # The state of this stack lives in the bucket created by terraform/bootstrap.
  # Each stack has its own "key" (file path) in the bucket.
  backend "s3" {
    bucket       = "nsatge1-aws-guardrails-lab-tfstate"
    key          = "lab/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}

# Credentials come from your AWS CLI profile ("export AWS_PROFILE=lab").
provider "aws" {
  region = "eu-west-3" # Paris

  default_tags {
    tags = {
      Project   = "aws-guardrails-lab"
      Stack     = "lab"
      ManagedBy = "terraform"
      Owner     = "nathan"
    }
  }
}
