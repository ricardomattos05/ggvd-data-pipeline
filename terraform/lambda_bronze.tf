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
    SQSSendMessage = {
      effect = "Allow"
      actions = [
        "sqs:SendMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = ["${aws_sqs_queue.myqueue.arn}"]
    }
    SQSReceiveAndDelete = {
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage"
      ]
      resources = ["${aws_sqs_queue.myqueue.arn}"]
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

  filename      = "../data_pipeline/bronze/tmdb/movies/package.zip"
  function_name = "Lambda_bronze_elt"
  role          = aws_iam_role.AWSLambdaRole_UFFIC_BronzeETL.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 120
  memory_size   = 1024
  layers = [
    "arn:aws:lambda:eu-central-1:473178649040:layer:request:1"
  ]
  environment_vars = {
    SQS_QUEUE_URL = aws_sqs_queue.myqueue.id
    BRONZE_BUCKET = module.s3.s3_bucket_name["bronze"]
    API_KEY       = var.api_key
  }

  depends_on = [
    module.s3,
  ]
  tags = merge(module.tags.common_tags, module.tags.lambda_specific_tags)
}

##### SQS TRIGGER

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn  = aws_sqs_queue.myqueue.arn
  function_name     = module.Lambda_bronze_elt.function_name
  batch_size        = 1
}
