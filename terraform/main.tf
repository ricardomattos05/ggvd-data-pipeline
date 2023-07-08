provider "aws" {

  region = var.aws_region

  profile = var.aws_profile

}

terraform {
  required_providers {
    aws = {

      source = "hashicorp/aws"

      version = "~> 4.0"

    }
  }
}

module "tags" {
  source       = "./modules/tags"
  moniker      = var.moniker
  environment  = var.environment
  company_name = var.company_name
}

module "s3" {
  source = "./modules/s3"

  company_name  = var.company_name
  environment   = var.environment
  aws_account   = var.aws_account
  aws_region    = replace(var.aws_region, "-", "")
  bucket_names  = var.bucket_names
  force_destroy = var.force_destroy
  tags          = merge(module.tags.common_tags, module.tags.s3_specific_tags)
}

module "iam" {
  source      = "./modules/iam"
  group_name  = "ggvd-uff-ic"
  policy_name = "GGVDProjectAccessPolicy"
  bucket_arns = concat(formatlist("%s/*", values(module.s3.s3_bucket_arns)), values(module.s3.s3_bucket_arns))
  lambda_arns = [module.Lambda_bronze_elt.function_arn,
  module.start_lambda.function_arn]

}

resource "aws_glue_catalog_database" "uffic_glue_database_silver" {
  name = "uffic_silver_db"
}

resource "aws_athena_workgroup" "workgroup_analytics" {
  name = "wg_uffic_${var.environment}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.s3.s3_bucket_name["athena"]}/output/"
    }
  }
  tags = merge(module.tags.common_tags, module.tags.athena_workgroup_specific_tags)
}
