# Where Terraform keeps the state of THIS stack: in the bucket it just created.
# Add this file only AFTER the first "terraform apply" (step 4 of the guide).
terraform {
  backend "s3" {
    bucket       = "nsatge1-aws-guardrails-lab-tfstate"
    key          = "bootstrap/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true # encrypt the state and the lock file
    use_lockfile = true # S3 native locking: two runs can't write the state at the same time
  }
}
