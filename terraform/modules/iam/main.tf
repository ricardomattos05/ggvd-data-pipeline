resource "aws_iam_group" "group" {
  name = var.group_name
}

resource "aws_iam_group_policy" "group_policy" {
  for_each = { for idx, policy in var.policies : idx => policy }

  name  = each.value.name
  group = aws_iam_group.group.id

  policy = templatefile(each.value.path, each.value.vars)
}
