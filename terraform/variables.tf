variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "eu-central-1"
}

variable "aws_account" {
  type        = string
  description = "AWS account ID"
  default     = "473178649040"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile to be used"
  default     = "default"
}

variable "environment" {
  type        = string
  description = "Setup the environment"
  default     = "dev"

}

variable "backend_bucket_name" {
  type    = string
  default = "uffic-backend-eucentral1-473178649040-dev"
}

variable "company_name" {

  type        = string
  description = "Company name"
  default     = "uffic"

}

variable "bucket_names" {
  description = "Layer's names for the buckets."
  type        = list(string)
  default     = ["athena", "bronze", "silver", "gold"]
}

variable "force_destroy" {
  type    = bool
  default = true
}

variable "moniker" {
  description = "Moniker for all resources across the company"
  default     = "uffic-ec1"
}
