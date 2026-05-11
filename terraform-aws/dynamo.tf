

module "dynamodb_table" { # TODO: change module name if you want to create multiple tables in the same stack
  source = "github.com/DanHenrique/terraform-aws-dynamodb?ref=v1.2.3"

  table_name = local.table_name
  hash_key   = "PK" # TODO: change to desired hash key
  range_key  = "SK" # TODO: change to desired range key

  billing_mode                = "PAY_PER_REQUEST" # TODO: change to PROVISIONED if you want to specify read/write capacity units
  deletion_protection_enabled = var.deletion_protection_enabled

  attributes = [ # TODO: change to desired attributes based on your access patterns
    { name = "PK", type = "S" },
    { name = "SK", type = "S" },
    { name = "GSI1PK", type = "S" },
    { name = "GSI1SK", type = "S" },
    { name = "GSI2PK", type = "S" },
    { name = "GSI2SK", type = "S" },
    { name = "entityType", type = "S" },
    { name = "createdAt", type = "S" },
  ]

  ttl_attribute = "expiresAt" # TODO: change to desired TTL attribute or set to null if not using TTL

  global_secondary_indexes = [ # TODO: change to desired GSIs based on your access patterns
    {
      name            = "GSI1"
      hash_key        = "GSI1PK"
      range_key       = "GSI1SK"
      projection_type = "ALL"
    },
    {
      name            = "GSI2"
      hash_key        = "GSI2PK"
      range_key       = "GSI2SK"
      projection_type = "ALL"
    },
    {
      name            = "GSI3"
      hash_key        = "entityType"
      range_key       = "createdAt"
      projection_type = "ALL"
    },
  ]

  tags = local.tags
}