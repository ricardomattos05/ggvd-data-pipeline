output "s3_bucket_arns" {
  value = {
    for key, bucket in aws_s3_bucket.s3-bucket : key => bucket.arn
  }
  description = "The arns of the created S3 buckets."
}

output "s3_bucket_name" {
  value = {
    for key, bucket in aws_s3_bucket.s3-bucket : key => bucket.id
  }
  description = "The names of the created S3 buckets."
}
