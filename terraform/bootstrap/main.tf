# The S3 bucket that stores the Terraform state of the whole lab.
# Bucket names are shared by all AWS customers in the world, so the name starts with my GitHub username.
resource "aws_s3_bucket" "tfstate" {
  bucket = "nsatge1-aws-guardrails-lab-tfstate"

  # Terraform refuses to delete this bucket, even with "terraform destroy".
  lifecycle {
    prevent_destroy = true
  }
}

# Keep the old versions of the state, so a broken state can be restored.
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Encrypt every object with KMS, using the AWS managed key for S3 (no monthly key cost).
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    # A bucket key reduces the number of calls to KMS, so it reduces the cost.
    bucket_key_enabled = true
  }
}

# Block every kind of public access.
# New buckets already do this by default. Writing it in code makes it visible and checkable.
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# The bucket owner owns every object. ACLs (an old access system) are turned off.
resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Delete old state versions after 90 days, so the bucket does not grow forever.
resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire-old-state-versions"
    status = "Enabled"

    # An empty filter means: the rule applies to every object in the bucket.
    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Versioning must be on before this rule can work.
  depends_on = [aws_s3_bucket_versioning.tfstate]
}

# Bucket policy: refuse every request that does not use HTTPS.
data "aws_iam_policy_document" "tfstate" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.tfstate.arn,
      "${aws_s3_bucket.tfstate.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  policy = data.aws_iam_policy_document.tfstate.json

  # The public access block must exist before a policy is added.
  depends_on = [aws_s3_bucket_public_access_block.tfstate]
}
