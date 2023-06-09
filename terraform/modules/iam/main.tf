resource "aws_iam_group" "group" {
  name = var.group_name
}

resource "aws_iam_group_policy" "policy" {
  name  = var.policy_name
  group = aws_iam_group.group.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:ListBucket"
        ]
        Resource = var.bucket_arns
      },
      {
        Effect   = "Allow"
        Action   = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:InvokeFunction",
          "lambda:GetFunction"
        ]
        Resource = var.lambda_arns
      },
      {
        Effect   = "Allow"
        Action   = [
          "lambda:GetAccountSettings",
          "lambda:ListFunctions"
        ]
        Resource = "*"
      },
    ]
  })
}
