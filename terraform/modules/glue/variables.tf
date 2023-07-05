variable "glue_job_name" {
  description = "Name of the Glue Job"
  type        = string
}

variable "role" {
  description = "role for glue job"
}

variable "database_name" {
  description = "Name of the Glue Catalog Database"
  type        = string
}

variable "script_location" {
  description = "S3 path to the Glue Job script"
  type        = string
}

variable "glue_version" {
  description = "Glue version"
  type        = string
  default     = "3.0"
}

variable "max_capacity" {
  description = "Max DPU capacity of the job"
  type        = number
  default     = 10
}

variable "timeout" {
  description = "Max timeout of the job"
  type        = number
  default     = 60
}

variable "worker_type" {
  description = "The Worker type cluster"
  type        = string
  default     = "G.1X"
}

variable "number_of_workers" {
  description = "Number of cluster workers"
  type        = number
  default     = 2
}

variable "max_retries" {
  description = "Number of retries"
  type        = number
  default     = 2
}
