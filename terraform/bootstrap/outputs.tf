# Values printed after "terraform apply". The other stacks need the bucket name.
output "state_bucket_name" {
  description = "Name of the S3 bucket that stores the Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}
