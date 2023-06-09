output "common_tags" {
  value = {
    "dlnews:moniker" = var.moniker
    "environment"    = var.environment
    "company"        = var.company_name
    "owner"          = "product-data"
  }
}

output "s3_specific_tags" {
  value = {
    "service" = "s3"
  }
}

output "redshift_specific_tags" {
  value = { "service" = "redshift"
  }
}

output "athena_workgroup_specific_tags" {
  value = { "service" = "athena"
  }
}

output "lambda_specific_tags" {
  value = { "service" = "lambda"
  }
}

output "dynamo_specific_tags" {
  value = { "service" = "dynamo"
  }
}
