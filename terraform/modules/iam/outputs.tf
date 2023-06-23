output "group_name" {
  description = "O nome do grupo IAM"
  value       = aws_iam_group.group.name
}
