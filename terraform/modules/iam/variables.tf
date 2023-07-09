variable "group_name" {
  description = "The name of the IAM group"
  type        = string
}

variable "policies" {
  description = "List of policy configurations"
  type = list(object({
    name = string
    path = string
    vars = map(string)
  }))
}
