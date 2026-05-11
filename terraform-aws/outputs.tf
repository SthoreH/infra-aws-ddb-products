output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb_table.table_arn
}

output "table_id" {
  description = "Name (ID) of the DynamoDB table"
  value       = module.dynamodb_table.table_id
}