variable "company_name" {
  description = "Company name"
}

variable "aws_account" {
  description = "AWS account ID"
}

variable "bucket_names" {
  description = "Layer's names for the buckets."
  type        = list(string)
}

variable "environment" {
  description = "Setup the environment"
}

variable "aws_region" {
  description = "AWS region"
}

variable "force_destroy" {
  default = false
}

variable "tags" {
  type        = map(string)
  description = "Tags to be added to the S3 resources"
  default     = {}
}
