locals {
  table_name = "table_name" # TODO: change to desired table name

  template_variables = {
    account_id  = data.aws_caller_identity.current.account_id
    environment = var.environment
    table_name  = local.table_name
  }

  tags = {
    ManagedBy  = "terraform"
    Repository = "github.com/SthoreH/infra-aws-ddb-table_name" # TODO: change to your repository
  }
}
