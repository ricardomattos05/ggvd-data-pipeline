resource "aws_lambda_function" "lambda" {
  filename      = var.filename
  function_name = var.function_name
  role          = var.role
  handler       = var.handler
  runtime       = var.runtime
  layers        = var.layers
  timeout       = var.timeout
  memory_size   = var.memory_size
  dynamic "environment" {
    for_each = length(keys(var.environment_vars)) > 0 ? [1] : []
    content {
      variables = var.environment_vars
    }
  }
  tags = var.tags
}
