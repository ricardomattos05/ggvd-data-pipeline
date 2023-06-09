variable "filename" {}
variable "function_name" {}
variable "role" {}
variable "handler" {}
variable "runtime" {}
variable "timeout" {}
variable "layers" {
  type    = list(string)
  default = []
}
variable "environment_vars" {
  type        = map(string)
  description = "Map of environment variables to pass to the Lambda function."
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to be added to the S3 resources"
  default     = {}
}