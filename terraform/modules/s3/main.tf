resource "aws_s3_bucket" "s3-bucket" {
  for_each = toset(var.bucket_names)

  bucket        = "${var.company_name}-${each.key}-${var.aws_region}-${var.aws_account}-${var.environment}"
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  for_each = aws_s3_bucket.s3-bucket

  bucket = each.value.bucket

  rule {
    id     = "expire_noncurrent_versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 730
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    dynamic "transition" {
      for_each = contains(split("-", each.value.bucket), "bronze") ? [1] : []
      content {
        days          = 60
        storage_class = "GLACIER"
      }
    }
  }
}

resource "aws_s3_bucket_versioning" "bucket-versioning" {
  for_each = aws_s3_bucket_lifecycle_configuration.bucket_lifecycle

  bucket = each.value.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-encryption" {
  for_each = aws_s3_bucket_lifecycle_configuration.bucket_lifecycle

  bucket = each.value.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  for_each = aws_s3_bucket_lifecycle_configuration.bucket_lifecycle

  bucket = each.value.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
