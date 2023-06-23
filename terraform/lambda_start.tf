#### LAMBDA FUNCTION

module "start_lambda" {
  source = "./modules/lambda"

  filename      = "../data_pipeline/bronze/tmdb/start_extraction/package.zip"
  function_name = "start_lambda"
  role          = aws_iam_role.AWSLambdaRole_UFFIC_BronzeETL.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  memory_size   = 128
  environment_vars = {
    SQS_QUEUE_URL = aws_sqs_queue.myqueue.url
  }

  tags = merge(module.tags.common_tags, module.tags.lambda_specific_tags)
}
