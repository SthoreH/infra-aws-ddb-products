resource "aws_dynamodb_table" "this" {

  # ── Identificação ─────────────────────────────────────────────────────────────
  name         = local.table_name
  billing_mode = "PAY_PER_REQUEST"

  # ── Chave primária ────────────────────────────────────────────────────────────
  hash_key  = "PK"
  range_key = "SK"

  # ── Proteção ──────────────────────────────────────────────────────────────────
  deletion_protection_enabled = var.deletion_protection_enabled

  # ── Atributos indexáveis ──────────────────────────────────────────────────────
  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
  attribute {
    name = "GSI1PK"
    type = "S"
  }
  attribute {
    name = "GSI1SK"
    type = "S"
  }
  attribute {
    name = "GSI2PK"
    type = "S"
  }
  attribute {
    name = "GSI2SK"
    type = "S"
  }
  attribute {
    name = "slug"
    type = "S"
  }
  attribute {
    name = "entity"
    type = "S"
  }

  # ── TTL ───────────────────────────────────────────────────────────────────────
  ttl {
    attribute_name = "expiresAt"
    enabled        = true
  }

  # ── Índices Globais Secundários ───────────────────────────────────────────────
  global_secondary_index {
    name            = "GSI1"
    projection_type = "ALL"
    key_schema {
      attribute_name = "GSI1PK"
      key_type       = "HASH"
    }
    key_schema {
      attribute_name = "GSI1SK"
      key_type       = "RANGE"
    }
  }

  global_secondary_index {
    name            = "GSI2"
    projection_type = "ALL"
    key_schema {
      attribute_name = "GSI2PK"
      key_type       = "HASH"
    }
    key_schema {
      attribute_name = "GSI2SK"
      key_type       = "RANGE"
    }
  }

  global_secondary_index {
    name            = "GSI3"
    projection_type = "ALL"
    key_schema {
      attribute_name = "slug"
      key_type       = "HASH"
    }
    key_schema {
      attribute_name = "entity"
      key_type       = "RANGE"
    }
  }

  # ── Tags ──────────────────────────────────────────────────────────────────────
  tags = local.tags
}
