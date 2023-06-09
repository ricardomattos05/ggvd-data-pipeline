#### ROLE AND POLICIE

module "iam_policy" {
  source = "cloudposse/iam-policy/aws"
  # Cloud Posse recommends pinning every module to a specific version
  version = "0.4.0"

  iam_policy_statements = {
    LambdaBasicExec = {
      effect     = "Allow"
      actions    = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources  = ["*"]
      conditions = []
    }
    ListBronzeBucket = {
      effect     = "Allow"
      actions    = ["s3:ListBucket"]
      resources  = ["${module.s3.s3_bucket_arns["bronze"]}"]
      conditions = []
    }
    WriteBronzeBucket = {
      effect     = "Allow"
      actions    = ["s3:PutObject"]
      resources  = ["${module.s3.s3_bucket_arns["bronze"]}/*"]
      conditions = []
    }
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AWSLambdaRole_UFFIC_BronzeETL" {
  name               = "AWSLambdaRole_UFFIC_BronzeETL"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  inline_policy {
    name = "bronze_etl_policy"

    policy = module.iam_policy.json
  }
}


#### LAMBDA FUNCTION

module "Lambda_bronze_elt" {
  source = "./modules/lambda"

  filename      = "../data_pipeline/bronze/source/table/package.zip"
  function_name = "Lambda_bronze_elt"
  role          = aws_iam_role.AWSLambdaRole_UFFIC_BronzeETL.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  layers = [
  ]
  environment_vars = {

  }

  depends_on = [
    module.s3,
  ]
  tags = merge(module.tags.common_tags, module.tags.lambda_specific_tags)
}
