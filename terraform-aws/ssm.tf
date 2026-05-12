resource "aws_ssm_parameter" "dynamodb_table_name" {
  name  = lower("/${var.organization}/dynamodb/${local.table_name}/name")
  type  = "String"
  value = aws_dynamodb_table.this.name

  tags = local.tags
}
