resource "aws_sqs_queue" "myqueue" {
  name                       = "myqueue"
  delay_seconds              = 0
  message_retention_seconds  = 86400
  visibility_timeout_seconds = 120
}

output "sqs_queue_url" {
  description = "URL da fila SQS"
  value       = aws_sqs_queue.myqueue.url
}
