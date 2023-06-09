variable "group_name" {
  description = "IAM group name"
  type        = string
}

variable "policy_name" {
  description = "IAM Policy name"
  type        = string
}

variable "bucket_arns" {
  description = "List of ARNs of S3 buckets to which access will be allowed"
  type        = list(string)
}

variable "lambda_arns" {
  description = "List of Lambda functions ARNs to which access is allowed"
  type        = list(string)
}
